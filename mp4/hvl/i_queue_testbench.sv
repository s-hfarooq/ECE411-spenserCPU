// any verifiers 
// O/

// Copied from MP1 fifo

`ifndef i_queue_testbench
`define i_queue_testbench

import i_queue_types::*;

module testbench(i_queue_itf itf);

// Clock Synchronizer for Student Use
default clocking tb_clk @(negedge itf.clk); endclocking

instruction_queue dut(
    // Inputs
    .clk(itf.clk),
    .rst(itf.reset_n),
    .flush(itf.flush_i),
    .read(itf.read_i),
    .write(itf.write_i),
    .pc_in(itf.data_i[width_p-1 -: 32]),
    .next_pc_in(itf.data_i[width_p-1-32 -: 32]),
    .instr_in(itf.data_i[31:0]),
    
    // Outputs to decoder
    .pc_out(itf.data_o[width_p-1 -: 32]),
    .next_pc_out(itf.data_o[width_p-1-32 -: 32]),
    .instr_out(itf.data_o[31:0]),
    .empty(itf.empty_o),
    .full(itf.full_o)
);

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
    // Write to queue until full, check data
    // dut.write = 1'b1;

    // for (int i = 0; i < 8; ++i) begin
    //     itf.data_i[width_p-1 -: 32] = i;
    //     itf.data_i[width_p-1-32 -: 32] = 2 * i;
    //     itf.data_i[31:0] = 3 * i;
    // end

    // dut.write = 1'b0;

    // // Read from queue until empty, make sure it's empty
    // for (int i = 0; i < 8; ++i) begin
    //     dut.read = 1'b1;
    //     assert (itf.data_o[width_p-1 -: 32] == i &&
    //             itf.data_o[width_p-1-32 -: 32] == 2 * i &&
    //             itf.data_o[31:0] == 3 * i) else begin
    //         report_error(READ_ERROR)
    //     end
    //     dut.read = 1'b0;
    // end

    // dut.read = 1'b0;

    // Simultaneously read and write

    // Ensure reset works as intended
    // Expected behavior: data = 0; empty = 1, full = 0
    reset();
    
    if (dut.pc_out != 0 || dut.next_pc_out != 0 || dut.instr_out != 0 || 
        dut.tail_ptr != 0 || dut.head_ptr != 0 || dut.counter != 0 || 
        dut.empty != 1 || dut.full != 0)
        $error("Invalid data out!")

    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    itf.finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule : testbench
`endif