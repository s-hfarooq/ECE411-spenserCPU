import rv32i_types::*;
import structs::*;
import macros::*;

module reservation_station (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic read,
    input logic load,
    input alu_rs_t alu_o,
    input rs_data_t datain,

    // Comes from ROB
    input logic [$clog2(RO_BUFFER_ENTRIES)-1:0] rs_idx_in,
    input logic is_valid,

    output rs_data_t dataout,
    output logic alu_rs_full
);

// localparam num_sets = 2**RS_S_INDEX;

rs_data_t data [ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic [ALU_RS_SIZE:0] free_idx;

always_ff @(posedge clk)
begin
    if(rst || flush) begin
        for(int i = 0; i < ALU_RS_SIZE; ++i)
            data[i] <= '{default: 0};
        free_idx <= {(ALU_RS_SIZE){1'b0}};
    end else begin
        if(read) begin
            dataout <= data[rindex];
        end

        if(load) begin
            if() begin // make sure its not full
                data[free_idx] <= datain;
            end
        end
    end
end

always_comb begin
    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        if(data[i].rs1.idx == rs_idx_in)
            data[i].rs1.valid <= 1'b1;
        if(data[i].rs2.idx == rs_idx_in)
            data[i].rs2.valid <= 1'b1;

        // Set valid bit on entry is both inputs are valid
        if(data[i].rs1.valid == 1'b1  && data[i].rs2.valid == 1'b1)
            data[i].valid == 1'b1;
    end

    // check if entry is valid - save to another array? find one with lowest idx to send to ALU/set busy bit
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin

    end
end

endmodule : reservation_station


// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS
