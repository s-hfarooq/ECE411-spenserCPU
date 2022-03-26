// any verifiers 
// O/

// Copied from MP1 fifo

import rv32i_types::*;

module i_queue_testbench();
    timeunit 10ns;
    timeprecision 1ns;

    // Inputs
    logic clk;
    logic rst;
    logic flush;
    logic read;
    logic write;
    rv32i_word pc_in;
    rv32i_word next_pc_in;
    rv32i_word instr_in;
    
    // Outputs
    rv32i_word pc_out;
    rv32i_word next_pc_out;
    rv32i_word instr_out;
    logic empty;
    logic full;

    instruction_queue dut(.*);

    // Clock Synchronizer for Student Use
    default clocking tb_clk @(negedge clk); endclocking

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
    end

    task reset();
        ##1;
        rst <= 1'b1;
        read <= 1'b0;
        write <= 1'b0;
        flush <= 1'b0;
        pc_in <= 32'b0;
        next_pc_in <= 32'b0;
        instr_in <= 32'b0;
        ##1;
        rst <= 1'b0;
        ##1;
    endtask : reset

    initial begin : TESTS
        $display("Starting i_queue tests...");
        reset();
        ##1;
        $display("Reset");
        ##1;

        // Write values to queue
        write <= 1'b1;
        for (int i = 0; i < 8; ++i) begin
            pc_in <= i;
            next_pc_in <= 2 * i;
            instr_in <= 3 * i;
            ##1;
        end
        write <= 1'b0;

        // Read from queue until empty, make sure it's empty
        read <= 1'b1;
        for (int i = 0; i < 8; ++i) begin
            if(pc_out != i || next_pc_out != 2 * i || instr_out != 3 * i)
                $display("Value dequeued not correct");
            ##1;
        end
        read <= 1'b0;

        // Simultaneously read and write

        // Ensure reset works as intended
        // Expected behavior: data = 0; empty = 1, full = 0
        // reset();
        
        // if (dut.pc_out != 0 || dut.next_pc_out != 0 || dut.instr_out != 0 || 
        //     dut.tail_ptr != 0 || dut.head_ptr != 0 || dut.counter != 0 || 
        //     dut.empty != 1 || dut.full != 0)
        //     $error("Invalid data out!")

        /***************************************************************/
        // Make sure your test bench exits by calling itf.finish();
        $finish();
        $error("TB: Illegal Exit ocurred");
    end
endmodule
