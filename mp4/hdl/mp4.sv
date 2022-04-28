`include "macros.sv"

import rv32i_types::*;
import structs::*;

module mp4 (
    input logic clk,
    input logic rst,

    input logic [63:0] mem_rdata,
    output rv32i_word mem_addr,
    input logic mem_resp,
    output logic mem_read,
    output logic mem_write,
    output logic [63:0] mem_wdata
);

// 0: ldst load_res
// 1-4: alu_vals_o
// 5-8: cmp_vals_o
cdb_t cdb;

// i-queue signals
logic i_queue_read;
logic i_queue_empty;
i_queue_data_t i_queue_o;

// decoder signals
logic load_tag;                     // From Decoder to Regfile
regfile_data_out_t regfile_data_o;  // From regfile to Decoder
logic [3:0] tag_decoder;
rv32i_reg rd_from_decoder;          // to Regfile
rv32i_reg rs1_from_decoder, rs2_from_decoder;
logic rob_write;                    // From Decoder to ROB
rob_arr_t rob_arr;                  // From ROB to Decoder
logic [3:0] rob_free_tag;
i_decode_opcode_t pc_and_rd;
rv32i_word branch_pred_new_pc;
logic curr_is_branch;

// ROB signals
rob_values_t rob_o;
logic flush;
logic rob_is_committing;
logic rob_store_complete;
logic rob_curr_is_store;
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] rob_head_tag;
logic rob_is_full;
logic take_br;
rv32i_word next_pc;
logic branch_prediction;

// ALU/CMP signals
logic alu_rs_full;
logic cmp_rs_full;
cmp_rs_t cmp_o;
alu_rs_t alu_o;
lsb_t lsb_decode_o;
logic ldst_full, ldst_almost_full;

// i-cache signals
logic i_cache_arbiter_resp;
logic [255:0] i_cache_arbiter_rdata;
logic [255:0] i_cache_arbiter_wdata;
rv32i_word i_cache_arbiter_address;
logic i_cache_arbiter_read;
logic i_cache_arbiter_write;
rv32i_word i_cache_mem_addr;
logic i_cache_mem_read;
logic i_cache_mem_resp;
logic [255:0] i_cache_mem_rdata;

// d-cache signals
logic [255:0] d_cache_mem_rdata;
logic d_cache_mem_resp;
logic d_cache_mem_write;
logic d_cache_mem_read;
logic [3:0] d_cache_byte_enable;
logic d_cache_arbiter_resp;
logic [255:0] d_cache_arbiter_rdata;
logic [31:0] d_cache_arbiter_address;
logic [255:0] d_cache_arbiter_wdata;
logic d_cache_arbiter_read;
logic d_cache_arbiter_write;
logic [31:0] d_cache_mem_wdata;
logic [31:0] d_cache_mem_addr;

// arbiter signals
logic arbiter_mem_resp;
logic [255:0] arbiter_mem_rdata;
logic arbiter_mem_write;
logic arbiter_mem_read;
logic [255:0] arbiter_mem_wdata;
rv32i_word arbiter_mem_address;

cache i_cache (
    .clk(clk),
    // Signals to arbiter
    .pmem_resp(i_cache_arbiter_resp),
    .pmem_rdata(i_cache_arbiter_rdata),
    .pmem_address(i_cache_arbiter_address),
    .pmem_wdata(i_cache_arbiter_wdata),     // i-cache never writes but still need signal here
    .pmem_read(i_cache_arbiter_read),
    .pmem_write(i_cache_arbiter_write),     // i-cache never writes but still need signal here
    // CPU memory signals
    .mem_read(i_cache_mem_read),
    .mem_write(1'b0),                       // i-cache never writes
    .mem_byte_enable_cpu(4'b0),             // i-cache never writes
    .mem_address(i_cache_mem_addr),
    .mem_wdata_cpu(32'b0),                  // i-cache never writes
    .mem_resp(i_cache_mem_resp),
    .mem_rdata_cpu(i_cache_mem_rdata)
);

cache d_cache (
    .clk(clk),
    // Signals to arbiter
    .pmem_resp(d_cache_arbiter_resp),
    .pmem_rdata(d_cache_arbiter_rdata),
    .pmem_address(d_cache_arbiter_address),
    .pmem_wdata(d_cache_arbiter_wdata),
    .pmem_read(d_cache_arbiter_read),
    .pmem_write(d_cache_arbiter_write),
    // CPU memory signals
    .mem_read(d_cache_mem_read),
    .mem_write(d_cache_mem_write),
    .mem_byte_enable_cpu(d_cache_byte_enable),
    .mem_address(d_cache_mem_addr),
    .mem_wdata_cpu(d_cache_mem_wdata),
    .mem_resp(d_cache_mem_resp),
    .mem_rdata_cpu(d_cache_mem_rdata)
);

arbiter arbiter (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // To/from cacheline adaptor
    .cacheline_adaptor_mem_rdata(arbiter_mem_rdata),
    .cacheline_adaptor_mem_addr(arbiter_mem_address),
    .cacheline_adaptor_mem_resp(arbiter_mem_resp),
    .cacheline_adaptor_mem_read(arbiter_mem_read),
    .cacheline_adaptor_mem_write(arbiter_mem_write),
    .cacheline_adaptor_mem_wdata(arbiter_mem_wdata),
    // Instruction Cache
    .i_cache_arbiter_read(i_cache_arbiter_read),
    .i_cache_arbiter_address(i_cache_arbiter_address),
    .i_cache_arbiter_resp(i_cache_arbiter_resp),
    .i_cache_arbiter_rdata(i_cache_arbiter_rdata),
    // Data Cache
    .d_cache_arbiter_read(d_cache_arbiter_read),
    .d_cache_arbiter_write(d_cache_arbiter_write),
    .d_cache_arbiter_address(d_cache_arbiter_address),
    .d_cache_arbiter_wdata(d_cache_arbiter_wdata),
    .d_cache_arbiter_resp(d_cache_arbiter_resp),
    .d_cache_arbiter_rdata(d_cache_arbiter_rdata)
);

cacheline_adaptor cacheline_adaptor (
    .clk(clk),
    .reset_n(~rst),
    // Signals to arbiter
    .line_i(arbiter_mem_wdata),
    .line_o(arbiter_mem_rdata),
    .address_i(arbiter_mem_address),
    .read_i(arbiter_mem_read),
    .write_i(arbiter_mem_write),
    .resp_o(arbiter_mem_resp),
    // Signals to physical memory
    .burst_i(mem_rdata),
    .burst_o(mem_wdata),
    .address_o(mem_addr),
    .read_o(mem_read),
    .write_o(mem_write),
    .resp_i(mem_resp)
);

i_fetch i_fetch (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .i_cache_mem_resp(i_cache_mem_resp),
    .i_cache_mem_rdata(i_cache_mem_rdata), // 32-bit instruction input
    .i_queue_data_out(i_queue_o),
    .mem_read(i_cache_mem_read),
    .pc_out(i_cache_mem_addr),
    .i_queue_read(i_queue_read),
    .next_pc(next_pc),
    .i_queue_empty(i_queue_empty),
    .branch_pred_new_pc(branch_pred_new_pc),
    .curr_is_branch(curr_is_branch),
    .take_br(take_br),
    .branch_prediction(branch_prediction)
);

i_decode decode (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .d_in(i_queue_o),
    .i_queue_empty(i_queue_empty),
    .i_queue_read(i_queue_read),
    .branch_pred_new_pc(branch_pred_new_pc),
    .curr_is_branch(curr_is_branch),
    .regfile_entry_i(regfile_data_o),
    .rs1_o(rs1_from_decoder),
    .rs2_o(rs2_from_decoder),
    .rd_o(rd_from_decoder),
    .tag(tag_decoder),
    .load_tag(load_tag),
    .rob_free_tag(rob_free_tag),
    .rob_in(rob_arr),
    .rob_write(rob_write),
    .rob_is_full(rob_is_full),
    .pc_and_rd(pc_and_rd),
    .alu_rs_full(alu_rs_full),
    .alu_o(alu_o),
    .cmp_rs_full(cmp_rs_full),
    .cmp_o(cmp_o),
    .lsb_full(ldst_full),
    .lsb_almost_full(ldst_almost_full),
    .lsb_o(lsb_decode_o)
);

regfile reg_file (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .load_tag(load_tag),
    .tag_decoder(tag_decoder),
    .reg_id_decoder(rd_from_decoder),
    .rs1_i(rs1_from_decoder),
    .rs2_i(rs2_from_decoder),
    .d_out(regfile_data_o),
    .rob_o(rob_o),
    .rob_is_committing(rob_is_committing)
);

load_store_queue ldstbuf (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // To/from CDB
    .cdb(cdb),
    .load_res(cdb[0]),
    // To/from ROB
    .ldst_full(ldst_full),
    .almost_full(ldst_almost_full),
    .lsb_entry(lsb_decode_o),
    .rob_store_complete(rob_store_complete),
    .curr_is_store(rob_curr_is_store),
    .head_tag(rob_head_tag),
    // To/from d-cache
    .data_read(d_cache_mem_read),
    .data_write(d_cache_mem_write),
    .data_mbe(d_cache_byte_enable), // mem byte enable
    .data_addr(d_cache_mem_addr),
    .data_wdata(d_cache_mem_wdata),
    .data_resp(d_cache_mem_resp),
    .data_rdata(d_cache_mem_rdata)
);

ro_buffer rob (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .load_rob(rob_write),
    .cdb(cdb),
    .decoder_instr_i(pc_and_rd),
    .rob_arr_o(rob_arr),
    .rob_free_tag(rob_free_tag),
    .full(rob_is_full),
    .rob_o(rob_o),
    .is_committing(rob_is_committing),
    .rob_store_complete(rob_store_complete),
    .curr_is_store(rob_curr_is_store),
    .head_ptr(rob_head_tag),
    .branch_taken(take_br),
    .target_pc(next_pc),
    .mem_resp(i_cache_mem_resp),
    .mem_read(i_cache_mem_read),
    .branch_prediction(branch_prediction)
);

alu_rs alu_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // From ROB
    .rob_arr_o(rob_arr),
    // To/from CDB
    .cdb_vals_i(cdb),
    .cdb_alu_vals_o(cdb[`ALU_RS_SIZE-1+1 -: `ALU_RS_SIZE]),
    // To/from decoder
    .alu_o(alu_o),
    .alu_rs_full(alu_rs_full)
);

cmp_rs cmp_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // From ROB
    .rob_arr_o(rob_arr),
    // To/from CDB
    .cdb_vals_i(cdb),
    .cdb_cmp_vals_o(cdb[(2*(`CMP_RS_SIZE-1))+2 -: `CMP_RS_SIZE]),
    // To/from decoder
    .cmp_o(cmp_o),
    .cmp_rs_full(cmp_rs_full)
);

endmodule : mp4
