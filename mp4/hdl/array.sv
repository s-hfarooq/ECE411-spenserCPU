/* Copied from MP3 given code.
A register array to be used for tag arrays, LRU array, etc. */

`include "macros.sv"

module array (
    clk,
    rst,
    read,
    load,
    rindex,
    windex,
    datain,
    dataout
);

localparam num_sets = 2**ARRAY_S_INDEX;

input clk;
input rst;
input read;
input load;
input [ARRAY_S_INDEX-1:0] rindex;
input [ARRAY_S_INDEX-1:0] windex;
input [ARRAY_WIDTH-1:0] datain;
output logic [ARRAY_WIDTH-1:0] dataout;

logic [ARRAY_WIDTH-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
logic [ARRAY_WIDTH-1:0] _dataout;
assign dataout = _dataout;

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
        if (read)
            _dataout <= (load  & (rindex == windex)) ? datain : data[rindex];

        if(load)
            data[windex] <= datain;
    end
end

endmodule : array
