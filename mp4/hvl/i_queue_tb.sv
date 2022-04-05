// Testbench for i_queue
// Similar to 385 testbenches

import rv32i_types::*;
import structs::*;

module i_queue_testbench();
    timeunit 10ns;
    timeprecision 1ns;

    // Inputs
    logic clk;
    logic rst;
    logic flush;
    logic read;
    logic write;
    i_queue_data_t data_in;
    
    // Outputs
    i_queue_data_t data_out;
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
        data_in <= '{default: 0};
        ##1;
        rst <= 1'b0;
        ##1;
    endtask : reset

    task readValsFromQueue(input int i);
        read <= 1'b1;
        ##1;
        read <= 1'b0;

        if(data_out.pc != i || data_out.next_pc != 2 * i || data_out.instr != 3 * i) begin
            $error("Value dequeued not correct");
            $error("i: %b, data_out.pc: %b, data_out.next_pc: %b, data_out.instr: %b, counter: %b", 
                    i, data_out.pc, data_out.next_pc, data_out.instr, dut.counter);
        end
        ##1;
    endtask : readValsFromQueue

    task addNToQueue(input int n);
        for(int i = 0; i < n; ++i) begin
            write <= 1'b1;
            data_in <= '{i, 2 * i, 3 * i};
            ##1;
            write <= 1'b0;
            ##1;
        end
    endtask : addNToQueue

    task checkReset();
        if(data_out.pc != 0 || data_out.next_pc != 0 || data_out.instr != 0 || 
            dut.tail_ptr != 0 || dut.head_ptr != 0 || dut.counter != 0 || 
            dut.empty != 1 || dut.full != 0)
            $error("Queue did not reset as expected");
    endtask : checkReset

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
        checkReset();

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
