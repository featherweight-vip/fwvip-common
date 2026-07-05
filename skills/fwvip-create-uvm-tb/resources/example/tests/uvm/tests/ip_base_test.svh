// ---- example base test: build env, report pass/fail ----------------------
class ip_base_test extends uvm_test;
    `uvm_component_utils(ip_base_test)
    ip_env env;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ip_env::type_id::create("env", this);
    endfunction

    function void report_phase(uvm_phase phase);
        if (env.sb.errors == 0)
            `uvm_info("RESULT", "** TEST PASSED **", UVM_LOW)
        else
            `uvm_error("RESULT", $sformatf("** TEST FAILED (%0d errors) **", env.sb.errors))
    endfunction
endclass
