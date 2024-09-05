
package fwvip_pkg;

typedef enum {
    BfmKind_Initiator
} bfm_kind_e;

class fwvip_bfm_base;
    bfm_kind_e      kind;
    string          tname;
    string          iname;

    function new(
        bfm_kind_e      kind,
        string          tname,
        string          iname);
        this.kind = kind;
        this.tname = tname;
        this.iname = iname;
    endfunction

endclass

interface class fwvip_mem_api;

    pure virtual task read8(
        output bit[7:0]     data,
        input bit[63:0]     addr);

    pure virtual task read16(
        output bit[15:0]    data,
        input bit[63:0]     addr);

    pure virtual task read32(
        output bit[31:0]    data,
        input bit[63:0]     addr);

    pure virtual task read64(
        output bit[63:0]    data,
        input bit[63:0]     addr);

    pure virtual task write8(
        input bit[7:0]      data,
        input bit[63:0]     addr);

    pure virtual task write16(
        input bit[15:0]     data,
        input bit[63:0]     addr);

    pure virtual task write32(
        input bit[31:0]     data,
        input bit[63:0]     addr);

    pure virtual task write64(
        input bit[63:0]    data,
        input bit[63:0]     addr);


endclass



endpackage