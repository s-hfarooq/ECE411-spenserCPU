/*
I-Queue entry bit field:
    PC
    next PC
    instruction
*/
import rv32i_types::*;

module instruction_queue #(
    parameter entries = 8
)
(
    // Inputs
    input logic clk,
    input logic rst,
    input logic flush,
    input logic shift,
    input rv32i_word pc_in,
    input rv32i_word next_pc_in,
    input rv32i_word instr_in,
    
    // Outputs to decoder
    output rv32i_word pc_out,
    output rv32i_word next_pc_out,
    output rv32i_word instr_out,
    output logic empty,
    output logic full
);

// Array of I-Queue entries


always_ff @ (posedge clk) begin
    // stuff
    if (rst) begin
    end
    else begin
    end
end


endmodule
