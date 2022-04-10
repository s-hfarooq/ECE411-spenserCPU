/* Copied from MP2 given code. */

import rv32i_types::*;

module alu (
    input logic clk,
    input alu_ops aluop,
    input logic [31:0] a, b,
    input logic load_alu,
    output logic [31:0] f,
    output logic ready
);

always_ff @(posedge clk) begin
    if(load_alu == 1'b1)
        ready = 1'b1;
    else 
        ready <= 1'b0;
end

always_comb
begin
    unique case (aluop)
        alu_add:  f = a + b;
        alu_sll:  f = a << b[4:0];
        alu_sra:  f = $signed(a) >>> b[4:0];
        alu_sub:  f = a - b;
        alu_xor:  f = a ^ b;
        alu_srl:  f = a >> b[4:0];
        alu_or:   f = a | b;
        alu_and:  f = a & b;
    endcase
end

endmodule : alu
