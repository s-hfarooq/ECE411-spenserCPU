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

    task addNToROB(input int n);
        for(int i = 0; i < n; ++i) begin
            write <= 1'b1;
            input_i.instr_pc <= i;
            input_i.funct3 <= i;
            input_i.funct7 <= i;
            input_i.opcode <= i;
            input_i.i_imm <= i;
            input_i.s_imm <= i;
            input_i.b_imm <= i;
            input_i.u_imm <= i;
            input_i.j_imm <= i;
            input_i.rs1 <= i;
            input_i.rs2 <= i;
            input_i.rd <= i;
            instr_pc_in <= i;
            ##1;
            write <= 1'b0;
        end
    endtask : addNToROB
    
    task ensureCorrectVals(input int n):
        for(int i = 0; i < n; ++i) begin
            read <= 1'b1;
            ##1;

            if(rob_o.op.instr_pc != i ||
                rob_o.op.funct3 != i ||
                rob_o.op.funct7 != i ||
                rob_o.op.opcode != i ||
                rob_o.op.i_imm != i ||
                rob_o.op.s_imm != i ||
                rob_o.op.b_imm != i ||
                rob_o.op.u_imm != i ||
                rob_o.op.j_imm != i ||
                rob_o.op.rs1 != i ||
                rob_o.op.rs2 != i ||
                rob_o.op.rd != i)
                $error("Values in ROB for %d are incorrect", i);
            read <= 1'b0;
        end
    endtask : ensureCorrectVals

    initial begin : TESTS
        $display("Starting ro_buffer tests...");
        reset();
        ##1;

        // test insert single element, test dequeue single element
        addNToROB(1);
        ensureCorrectVals(1);
        reset();

        // test insert many elements (not fill), test continuous dequeue
        addNToROB(4);
        ensureCorrectVals(4);
        reset();

        // test insert all elements (fill), test continuous dequeue
        addNToROB(8);
        ensureCorrectVals(8);
        reset();

        // test overfill
        addNToROB(100);
        ensureCorrectVals(8);
        reset();

        // test dequeue when empty
        read <= 1'b1;
        ##1;
        read <= 1'b0;
        ##1;

        // test reset
        reset();
        if(empty != 1'b1 || full != 1'b0)
            $error("ROB did not reset as expected");

        /***************************************************************/
        $display("Finished ro_buffer tests");
        $finish();
        $error("TB: Illegal Exit ocurred");
    end
endmodule
