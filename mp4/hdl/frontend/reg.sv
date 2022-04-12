/* Copied from MP2 given code. */

`include "../macros.sv"

module register (
    input logic clk,
    input logic rst,
    input logic load,
    input logic [`REGISTER_WIDTH-1:0] in,
    output logic [`REGISTER_WIDTH-1:0] out
);

logic [`REGISTER_WIDTH-1:0] data = 1'b0;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= '0;
    end
    else if (load)
    begin
        data <= in;
    end
    else
    begin
        data <= data;
    end
end

always_comb
begin
    out = data;
end

endmodule : register
