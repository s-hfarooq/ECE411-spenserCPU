// Testbench for ro_buffer
// Similar to 385 testbenches

import rv32i_types::*;
import structs::*;

module ro_buffer_testbench();
    timeunit 10ns;
    timeprecision 1ns;

    // Inputs
    logic clk;
    logic rst;
    logic flush;
    logic read;
    logic write;

    // From decoder
    i_decode_opcode_t input_i;
    rv32i_word instr_pc_in;

    // From reservation station
    rv32i_word value_in_reg;

    // Outputs
    // To decoder
    rv32i_word reg_val_o;
    rv32i_reg reg_o;
    logic empty;
    logic full;

    // To regfile/reservation station
    rob_values_t rob_o;

    reorder_buffer dut(.*);

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
        flush <= 1'b0;
        read <= 1'b0;
        write <= 1'b0;
        input_i <= '{default: 0};
        instr_pc_in <= 32'b0;
        value_in_reg <= 32'b0;
        ##1;
        rst <= 1'b0;
        ##1;
    endtask : reset

    initial begin : TESTS
        $display("Starting ro_buffer tests...");
        reset();
        ##1;

        

        /***************************************************************/
        $display("Finished ro_buffer tests");
        $finish();
        $error("TB: Illegal Exit ocurred");
    end
endmodule
