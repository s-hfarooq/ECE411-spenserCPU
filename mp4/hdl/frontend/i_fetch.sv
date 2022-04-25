import rv32i_types::*;
import structs::*;

module i_fetch (
    input logic clk,
    input logic rst,

    input logic flush,

    input logic mem_resp,
    input rv32i_word mem_rdata,

    output i_queue_data_t i_queue_data_out,

    // From Decoder
    input logic iqueue_read,

    output logic mem_read,
    output rv32i_word pc_o,

    input logic take_br,
    input rv32i_word next_pc,

    // To Decoder
    output logic i_queue_empty
);

// i_queue signals
logic i_queue_full, i_queue_write;
i_queue_data_t i_queue_data_in;

// PC signals
logic pc_load, branch_pred_pc_sel;
rv32i_word pc_in, pc_out, alu_out;

assign pc_o = pc_out;
assign mem_read = ~i_queue_full;
assign i_queue_write = ~i_queue_full;

pc_register pc (
    .clk(clk),
    .rst(rst),
    .load(pc_load),
    .in(pc_in),
    .out(pc_out)
);

br_pred predictor (
    .clk(clk),
    .rst(rst),
    .i_queue_full(i_queue_full),
    .take_br(take_br),
    .branch_pred_pc_sel(branch_pred_pc_sel),
    .pc_load(pc_load),
    .mem_resp(mem_resp)
);

i_queue i_queue (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .read(iqueue_read),
    .write(i_queue_write),
    .data_in(i_queue_data_in),
    .data_out(i_queue_data_out),
    .empty(i_queue_empty),
    .full(i_queue_full),
    .mem_resp(mem_resp)
);

always_comb begin
    i_queue_data_in.pc = pc_out;
    i_queue_data_in.next_pc = pc_out + 4; // branching will be different
    i_queue_data_in.instr = mem_rdata;
end

always_comb begin : MUXES
    case (take_br)
        1'b0: pc_in = pc_out + 4;
        1'b1: pc_in = next_pc;
        // default: `BAD_MUX_SEL;
    endcase
end

endmodule : i_fetch