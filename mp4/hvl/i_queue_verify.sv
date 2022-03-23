// any verifiers 
// O/

// Copied from MP1 fifo

`ifndef testbench
`define testbench

import fifo_types::*;

module testbench(fifo_itf itf);

instruction_queue inst_queue(
    // Inputs
    .clk(),
    .rst(),
    .flush(),
    .shift(),
    .load(),
    .pc_in(),
    .next_pc_in(),
    .instr_in(),
    
    // Outputs to decoder
    .pc_out(),
    .next_pc_out(),
    .instr_out(),
    .empty(),
    .full()
);

// Clock Synchronizer for Student Use
default clocking tb_clk @(negedge itf.clk); endclocking

task reset();
    itf.reset_n <= 1'b0;
    ##(10);
    itf.reset_n <= 1'b1;
    ##(1);
endtask : reset

function automatic void report_error(error_e err); 
    itf.tb_report_dut_error(err);
endfunction : report_error

// DO NOT MODIFY CODE ABOVE THIS LINE

initial begin
    reset();
    /************************ Your Code Here ***********************/
    // Feel free to make helper tasks / functions, initial / always blocks, etc.


    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif