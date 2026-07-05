// ======================================================================
// Example scenario + test package. Same convention as env/: one class per
// .svh, included below in dependency order (sequences first, then the base
// test, then the concrete tests). No `ifndef/`define guards.
// ======================================================================
`include "uvm_macros.svh"

package ip_tests_pkg;
    import uvm_pkg::*;
    import ip_env_pkg::*;

    // package-scope constants shared by the scenarios stay inline
    localparam logic [31:0] BASE = 32'h0000_0000;

    // sequences
    `include "ip_smoke_seq.svh"

    // base test + concrete tests
    `include "ip_base_test.svh"
    `include "ip_smoke_test.svh"
endpackage
