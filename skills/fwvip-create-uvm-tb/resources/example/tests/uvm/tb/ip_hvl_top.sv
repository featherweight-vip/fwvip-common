// Example HVL top: import the env + tests packages, build the env, publish its
// config into the uvm_config_db, then run the selected +UVM_TESTNAME. The tops
// are ordinary modules -- one file each, NOT split into .svh (only classes are).
`include "uvm_macros.svh"

module ip_hvl_top;
    import uvm_pkg::*;
    import ip_env_pkg::*;
    import ip_tests_pkg::*;

    initial begin
        automatic ip_env_cfg cfg = ip_env_cfg::type_id::create("cfg");
        // seat vifs / VIP config handles into cfg here (see fwvip-<proto> usage skill)
        uvm_config_db #(ip_env_cfg)::set(null, "*", "cfg", cfg);
        run_test();
    end

    // Sim-time watchdog: a stuck interrupt/handshake fails loudly instead of hanging.
    initial begin
        #5ms;
        $fatal(1, "[ip_hvl_top] TIMEOUT");
    end
endmodule
