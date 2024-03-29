import rv32i_types::*;
import structs::*;

module i_fetch (
    input logic clk,
    input logic rst,
    input logic flush,

    // From/to i-cache
    input logic i_cache_mem_resp,
    input rv32i_word i_cache_mem_rdata,
    output i_queue_data_t i_queue_data_out,
    output logic mem_read,
    output rv32i_word pc_out,

    // From/to Decoder
    input logic i_queue_read,
    input rv32i_word next_pc,
    output logic i_queue_empty,
    input logic resolve_jal,
    input rv32i_word jal_target_pc,

    // From ROB
    input logic take_br
);

// i_queue signals
logic i_queue_full, i_queue_write;
i_queue_data_t i_queue_data_in;

// PC signals
logic pc_load, branch_pred_pc_sel;
rv32i_word pc_in;

assign mem_read = 1'b1;
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
    .branch_pred_pc_sel(branch_pred_pc_sel),
    .pc_load(pc_load),
    .mem_resp(i_cache_mem_resp),
    .flush(flush),
    .resolve_jal(resolve_jal)
);

i_queue i_queue (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .read(i_queue_read),
    .write(i_queue_write),
    .data_in(i_queue_data_in),
    .mem_resp(i_cache_mem_resp),
    .data_out(i_queue_data_out),
    .empty(i_queue_empty),
    .full(i_queue_full)
);

// logic going to i-queue and pc_in
always_comb begin
    case ({take_br, resolve_jal})  
        2'b00: begin
            pc_in = pc_out + 4;
            i_queue_data_in.pc = pc_out;
            i_queue_data_in.next_pc = pc_out + 4;
            i_queue_data_in.instr = i_cache_mem_rdata;
        end
        2'b01: begin
            pc_in = jal_target_pc; // pc from jal instruction
            i_queue_data_in.pc = jal_target_pc;
            i_queue_data_in.next_pc = jal_target_pc + 4;
            i_queue_data_in.instr = i_cache_mem_rdata;
        end
        2'b10: begin
            pc_in = next_pc;
            i_queue_data_in.pc = next_pc;
            i_queue_data_in.next_pc = next_pc + 4;
            i_queue_data_in.instr = 32'd0;
        end
        2'b11: begin // should hopefully never happen
            pc_in = jal_target_pc; // pc from jal instruction
            i_queue_data_in.pc = jal_target_pc;
            i_queue_data_in.next_pc = jal_target_pc + 4;
            i_queue_data_in.instr = i_cache_mem_rdata;
        end
    endcase
end

endmodule : i_fetch
