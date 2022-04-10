/* Copied from MP2 given code. */

import rv32i_types::*;

module cmp (
    input branch_funct3_t cmpop,
    input logic [31:0] a, b,
    input logic load_cmp,

    output logic f
    output logic ready
);


always_ff @(posedge clk) begin
    if(load_cmp == 1'b1)
        ready = 1'b1;
    else 
        ready <= 1'b0;
end


always_comb
begin
    unique case (cmpop)
        beq : f = (a == b);
        bne : f = (a != b);
        blt : f = $signed(a) < $signed(b);
        bge : f = $signed(a) >= $signed(b);
        bltu: f = (a < b);
        bgeu: f = (a >= b);
        default: f = 1'b0;
    endcase
end

endmodule : cmp
