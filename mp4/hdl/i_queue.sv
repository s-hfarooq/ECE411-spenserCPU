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
    input logic load,
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


// Array of I-Queue entries (Make our own array entries?)
logic [95:0] entry [entries-1:0];

// array #(.s_index(entries), .width(96)) tag0
// (
//     .clk(clk),
//     .rst(rst || flush),
//     .read(1'b1),
//     .load(load),
//     .rindex(),
//     .windex(),
//     .datain({pc_in, next_pc_in, instr_in}),
//     .dataout({pc_out, next_pc_out, instr_out})
// );

always_ff @ (posedge clk) begin
    if (rst || flush) begin
        for (int i = 0; i < entries; ++i)
            entry[i] = 96'b0;
    end else begin

    end
end


endmodule : instruction_queue
