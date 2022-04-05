import rv32i_types::*;
import structs::*;

module i_fetch (
    input logic clk,
    input logic rst,

    input logic mem_resp,
    input rv32i_word mem_rdata,

    output i_queue_data_t i_queue_data_out,

    output logic mem_read,
    output logic mem_write
);

// i_queue signals
logic i_queue_empty, i_queue_full, i_queue_flush, i_queue_read, i_queue_write;
i_queue_data_t i_queue_data_in;

// PC signals
logic pc_load, branch_pred_pc_sel;
rv32i_word pc_in, pc_out, alu_out;

pc_register pc(
    .clk(clk),
    .rst(rst),
    .load(pc_load),
    .in(pc_in),
    .out(pc_out)
);

// TODO later
br_pred predictor(
    .clk(clk),
    .rst(rst),
    .branch_pred_pc_sel(branch_pred_pc_sel)
);

// TODO later
// cache i_cache(

// );

i_queue i_queue(
    .clk(clk),
    .rst(rst),
    .flush(i_queue_flush),
    .read(i_queue_read),
    .write(i_queue_write),
    .data_in(i_queue_data_in),
    .data_out(i_queue_data_out),
    .empty(i_queue_empty),
    .full(i_queue_full)
);


always_comb begin : MUXES
    case (branch_pred_pc_sel)
        1'b0: pc_in = pc_out + 4;
        1'b1: pc_in = alu_out;
        // default: `BAD_MUX_SEL;
    endcase
end

endmodule : i_fetch
