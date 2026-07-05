// ---- example smoke test: run the smoke sequence --------------------------
class ip_smoke_test extends ip_base_test;
    `uvm_component_utils(ip_smoke_test)

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    task run_phase(uvm_phase phase);
        ip_smoke_seq seq = ip_smoke_seq::type_id::create("seq");
        phase.raise_objection(this);
        // seq.start(env.agent.m_seqr);
        phase.drop_objection(this);
    endtask
endclass
