import rv32i_types::*;
import structs::*;

module reservation_station #(
    parameter s_index = 3,
)
(
    clk,
    rst,
    read,
    load,
    rindex,
    windex,
    datain,
    dataout
);

localparam num_sets = 2**s_index;

input clk;
input rst;
input read;
input load;
input [s_index-1:0] rindex;
input [s_index-1:0] windex;
input rs_data_t [width-1:0] datain;
output rs_data_t [width-1:0] dataout;

rs_data_t [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
rs_data_t [width-1:0] _dataout;
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
