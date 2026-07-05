---
name: fwvip-create-uvm-tb
description: Structure a UVM testbench (the tests/uvm/ tree) around a fwvip-<proto> VIP and/or a
  fw-hdl class model — the env package(s), scenario/test package, HDL/HVL tops, and the
  dv-flow flow.yaml. Enforces the project convention that every UVM/fw-hdl class lives in its
  own .svh file, `include`d by a thin package .sv (no `ifndef/`define guards). Use when asked
  to create, scaffold, refactor, or add classes to a UVM testbench for a Featherweight design.
tools: Read, Write, Edit, Bash, Grep, Glob
---

# fwvip-create-uvm-tb — structure a UVM testbench

This skill builds/maintains the **testbench tree** (`tests/uvm/`) that exercises a design
through a `fwvip-<proto>` VIP and/or a `fw-hdl` class model. It assumes the VIP and/or the
model already exist (build the VIP with `fwvip-create`). It is calibrated on the validated
`fw-wb-dma` UVM environment.

## Directory layout

```
tests/uvm/
  env/    <one package .sv per env layer> + <one .svh per class>
  tests/  wb_<dsn>_tests_pkg.sv          + <one .svh per sequence/test class>
  tb/     hvl_top_*.sv / hdl_top_*.sv / RAM & helper modules
  flow.yaml
```

`env/` typically holds several package layers that build on each other, e.g. the `fw-wb-dma`
env has: `<dsn>_model_pkg` (the fw-hdl "DUT" side), `<dsn>_uvm_pkg` (reg agent + scoreboard +
env + base sequence), and one package per signal-level flavour (`<dsn>_wb_model_pkg`,
`<dsn>_rtl_model_pkg`). Each flavour reuses the shared env through an abstract model base.

## THE convention: one class per `.svh`, no guards

Every UVM / fw-hdl **class** (and each UVM-object / component) lives in its **own `.svh`
file**, named exactly after the class. A **thin package `.sv`** does the `import`s and
`` `include ``s the `.svh` files **in dependency order**. This mirrors the VIP package
convention (`fwvip-create` Phase 5).

**Rules:**

- **No `` `ifndef ``/`` `define `` include guards.** The `.svh` files are `include`d exactly
  once, from their package `.sv`, in a controlled order. Guards are noise and hide
  double-include mistakes — omit them.
- **One class per file**, file name == class name + `.svh` (e.g. `wb_dma_scoreboard.svh`).
- **Package-scope non-class items stay in the `.sv`**: `import`s, `typedef`s, `localparam`s,
  package `function`s, and any `typedef` that names a class (e.g.
  `typedef uvm_sequencer #(item) ..._sequencer;`) live inline in the package file, placed
  before the `` `include ``s that need them.
- **Include order = dependency order**: a base class before its derived classes; a type
  before the class that references it. The `.svh` files themselves contain *only* the class
  (plus its leading comment) — no `import`, no `package`, no guard.
- **Macro includes** (`` `include "uvm_macros.svh" ``, design macro headers) go **above** the
  `package` keyword in the `.sv`, as before.

### Package skeleton (from `env/wb_dma_uvm_pkg.sv`)

```sv
// wb_dma_uvm_pkg.sv — thin package: imports, package-scope helpers, then per-class includes.
`include "uvm_macros.svh"

package wb_dma_uvm_pkg;
    import uvm_pkg::*;
    import wb_dma_model_pkg::*;

    // package-scope helpers/typedefs/localparams stay inline, BEFORE the includes
    localparam logic [31:0] REG_INT_SRCA = 32'h0c;
    function automatic logic [31:0] mk_sz(int chunk, int tot); /* ... */ endfunction

    `include "wb_dma_reg_item.svh"                       // base item first

    typedef uvm_sequencer #(wb_dma_reg_item) wb_dma_reg_sequencer;   // class-typedef inline

    `include "wb_dma_reg_driver.svh"                     // depends on reg_item
    `include "wb_dma_reg_agent.svh"                       // depends on driver + sequencer
    `include "wb_dma_scoreboard.svh"
    `include "wb_dma_env.svh"
    `include "wb_dma_base_seq.svh"
endpackage
```

### A `.svh` file (from `env/wb_dma_env.svh`)

```sv
// ---- env -----------------------------------------------------------------
class wb_dma_env extends uvm_env;
    `uvm_component_utils(wb_dma_env)
    wb_dma_reg_agent  agent;
    wb_dma_scoreboard sb;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    // ...
endclass
```

No guard, no `package`, no `import` — just the class. Its dependencies are guaranteed by the
`` `include `` order in the package `.sv`.

## flow.yaml: incdirs must reach the `.svh`

The `.svh` files are pulled in by the compiler's `` `include `` search path, **not** the DFM
`include:` list. `include:` still names only the package `.sv` files. But the incdir must
cover the directory the `.svh` files live in.

`incdirs` are resolved **relative to the flow.yaml directory**, and `base` only affects the
`include:` file globs — so with `base: env` you must add `env` to `incdirs` (it does not
inherit `base`):

```yaml
- name: uvm-env-src
  uses: std.FileSet
  needs: [spl]
  with:
    type: systemVerilogSource
    base: env
    incdirs: [".", "env"]      # 'env' so the per-class .svh includes resolve
    include:
    - wb_dma_model_pkg.sv
    - wb_dma_uvm_pkg.sv
```

Likewise the tests FileSet uses `base: tests` + `incdirs: [".", "tests"]`. Only the package
`.sv` files are listed under `include:`; the `.svh` files are not (they are `` `include ``d,
not compiled as roots).

## Tops (tb/)

The HDL/HVL tops are ordinary modules (one file each, no split needed). An HVL top imports the
env + tests packages, brings up the model / VIP env, publishes handles into `uvm_config_db`,
and calls `run_test()`. See `tb/hvl_top_spl.sv` for the fw-hdl (class-model) flavour and
`tb/hvl_top_spl_wb.sv` / `tb/hvl_top_rtl.sv` for the signal-level flavours (factory override of
the shared env to add a monitor, transactor vif seating, forked service loops).

## Workflow to add a class or refactor an existing package

1. Create `env/<class>.svh` (or `tests/<class>.svh`) containing exactly the class + its
   comment. No guard.
2. Add a `` `include "<class>.svh" `` to the owning package `.sv`, positioned after everything
   it depends on.
3. Ensure the FileSet feeding that package has the base subdir on `incdirs`
   (`[".", "env"]` / `[".", "tests"]`).
4. Build + run a smoke test: `UVM_HOME=$IVPM_PACKAGES/uvm dfm run uvm-smoke` (adjust the run
   task name). The split is purely mechanical — behavior must be byte-identical; verify the
   scoreboard still reports `** TEST PASSED **`.

## Gotchas

- **`env/` may be gitignored.** The default `.gitignore`'s Python-venv block lists `env/`
  with no leading slash, so git ignores **any** directory named `env` at any depth — including
  `tests/uvm/env/`, making the per-class `.svh` split invisible to git. Fix it at the source:
  **anchor the venv patterns to the repo root** (`/env/`, `/venv/`, `/ENV/`, …) so they only
  match a top-level virtualenv, not HDL source dirs. Verify with
  `git check-ignore tests/uvm/env/` (no output = tracked).
- **Do not add `` `ifndef `` guards** "just in case" — the single-include-from-package
  discipline makes them unnecessary and they mask ordering bugs.
- **Class-typedefs are not classes** — keep `typedef uvm_sequencer #(item) ..._sequencer;` in
  the package `.sv` (right after the item's include), not in its own `.svh`.
