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

    i_queue dut(.*);

    // Clock Synchronizer for Student Use
    default clocking tb_clk @(negedge clk); endclocking

    always begin
        #1 clk = ~clk;
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

    task readValsFromQueue(input int i);
        read <= 1'b1;
        ##1;
        read <= 1'b0;

        if(pc_out != i || next_pc_out != 2 * i || instr_out != 3 * i) begin
            $error("Value dequeued not correct");
            $error("i: %b, pc_out: %b, next_pc_out: %b, instr_out: %b, counter: %b", 
                    i, pc_out, next_pc_out, instr_out, dut.counter);
        end
        ##1;
    endtask : readValsFromQueue

    task addNToQueue(input int n);
        for(int i = 0; i < n; ++i) begin
            write <= 1'b1;
            pc_in <= i;
            next_pc_in <= 2 * i;
            instr_in <= 3 * i;
            ##1;
            write <= 1'b0;
            ##1;
        end
    endtask : addNToQueue

    initial begin : TESTS
        $display("Starting i_queue tests...");
        reset();
        ##1;

        // Write values to queue
        addNToQueue(8);

        // Read from queue until empty, make sure it's empty
        for(int i = 0; i < 8; ++i)
            readValsFromQueue(i);

        ##1;
        // Ensure queue is empty
        if(empty != 1'b1 || full != 1'b0)
            $error("Queue not empty after dequeuing all values");
        
        // Ensure reset works as intended
        // Expected behavior: data = 0; empty = 1, full = 0
        reset();
        if(dut.pc_out != 0 || dut.next_pc_out != 0 || dut.instr_out != 0 || 
            dut.tail_ptr != 0 || dut.head_ptr != 0 || dut.counter != 0 || 
            dut.empty != 1 || dut.full != 0)
            $error("Queue did not reset as expected");

        // Enqueue then dequeue - check to make sure circular queue pointers work as intended
        // Fill queue 
        addNToQueue(8);

        // Read 2 values, ensure they are correct
        for(int i = 0; i < 2; ++i)
            readValsFromQueue(i);

        // Write two values to replace old ones that were removed
        addNToQueue(2);

        // Read next two values, ensure they are correct
        for(int i = 2; i < 4; ++i)
            readValsFromQueue(i);

        /***************************************************************/
        $display("Finished i_queue tests");
        $finish();
        $error("TB: Illegal Exit ocurred");
    end
endmodule
