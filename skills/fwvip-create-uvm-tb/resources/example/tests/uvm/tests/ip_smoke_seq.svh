// ---- example smoke sequence ----------------------------------------------
class ip_smoke_seq extends ip_base_seq;
    `uvm_object_utils(ip_smoke_seq)

    function new(string name = "ip_smoke_seq"); super.new(name); endfunction

    task body();
        write(BASE, 32'hdead_beef);
    endtask
endclass
