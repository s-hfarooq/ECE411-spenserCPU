import rv32i_types::*;
import structs::*;
import macros::*;

module reservation_station (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic load,
    // input alu_rs_t alu_o,
    input rs_data_t data_in,

    // From ROB
    input logic [$clog2(RO_BUFFER_ENTRIES)-1:0] rs_idx_in, // index of register to set valid bit
    input logic is_valid,

    // From CDB/ALU
    // need signals to know when ALU has finished/when to remove entry from RS
    

    // To ALU
    output alu_rs_t data_out,

    // To decoder
    output logic alu_rs_full
);

// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS

rs_data_t data [ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic [$clog2(ALU_RS_SIZE):0] [ALU_RS_SIZE-1:0] order_history;
logic [$clog2(ALU_RS_SIZE)-1:0] free_idx;
logic [$clog2(ALU_RS_SIZE):0] num_entries = 0;

assign alu_rs_full = (num_entries == ALU_RS_SIZE);

always_ff @(posedge clk) begin
    if(rst || flush) begin
        for(int i = 0; i < ALU_RS_SIZE; ++i)
            data[i] <= '{default: 0};
        free_idx <= {(ALU_RS_SIZE){1'b0}};
    end else begin
        if(load) begin
            if(num_entries < ALU_RS_SIZE) begin
                data[free_idx] <= data_in;
                num_entries <= num_entries + 1;
                // TODO: update order_history array and free_idx
            end
        end
    end
end

always_ff @(posedge clk) begin
    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        if(data[i].rs1.idx == rs_idx_in)
            data[i].rs1.valid <= 1'b1;
        if(data[i].rs2.idx == rs_idx_in)
            data[i].rs2.valid <= 1'b1;

        // Set valid bit on entry if both inputs are valid
        if(data[i].rs1.valid == 1'b1 && data[i].rs2.valid == 1'b1)
            data[i].valid <= 1'b1;

        // TODO: should also probaby update rs1/rs2.value.value here
    end

    // check if entry is valid/not busy - find one with lowest idx to send to ALU/set busy bit
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        // Don't need to check if ALU is busy since it only takes 1 clock cycle (same with cmp)
        if(data[order_history[i]].valid == 1'b1 && data[order_history[i]].busy == 1'b0) begin
            data[order_history[i]].busy <= 1'b1;
            num_entries <= num_entries - 1;
            // TODO: update free_idx? set to i? update order_history

            // Send data to ALU
            data_out.alu_vj <= data[order_history[i]].rs1.value.value;
            data_out.alu_vk <= data[order_history[i]].rs2.value.value;
            data_out.alu_qj <= data[order_history[i]].rs1.tag;
            data_out.alu_qk <= data[order_history[i]].rs2.tag;
            data_out.alu_op <= data[order_history[i]].alu_op;
            data_out.rob_idx <= data[order_history[i]].res.idx;

            // TODO: replace the break?
            break; // might not synthesize
        end
    end
end

endmodule : reservation_station
