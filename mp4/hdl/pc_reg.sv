/* Copied from MP2 given code. */

module pc_register #(parameter width = 32) (
    input logic clk,
    input logic rst,
    input logic load,
    input logic [width-1:0] in,
    output logic [width-1:0] out
);

/*
* PC needs to start at 0x60
 */
logic [width-1:0] data;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= 32'h00000060;
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

endmodule : pc_register
