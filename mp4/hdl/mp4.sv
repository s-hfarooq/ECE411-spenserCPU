`include "macros.sv"

import rv32i_types::*;
import structs::*;

module mp4 (
    input logic clk,
    input logic rst,

    // input rv32i_word mem_rdata,
    // output rv32i_word mem_addr,
    // input logic mem_resp,
    // output logic mem_read,
    // output logic mem_write,
    // output rv32i_word mem_wdata,
    
    // I-Cache signals
    output logic inst_read,
    output rv32i_word inst_addr,
    input logic inst_resp,
    input rv32i_word inst_rdata,    // 32-bit instruction

    // D-Cache signals
    output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe,
    output rv32i_word data_addr,
    output rv32i_word data_wdata,
    input logic data_resp,
    input rv32i_word data_rdata
);

logic iqueue_read;
i_queue_data_t iqueue_o;
logic load_tag;                     // From Decoder to Regfile
regfile_data_out_t regfile_data_o;  // From regfile to Decoder
logic [3:0] tag_decoder;
rv32i_reg rd_from_decoder;          // to Regfile
rv32i_reg rs1_from_decoder, rs2_from_decoder;
logic rob_write;                    // From Decoder to ROB
rob_arr_t rob_arr;                  // From ROB to Decoder
logic [3:0] rob_free_tag;
i_decode_opcode_t pc_and_rd;

regfile_data_out_t regfile_d_out, alu_rs_d_out;
logic load_reg;
logic load_ldst;

logic rob_read;
logic flush = 1'b0;

rob_values_t rob_o;
logic rob_is_committing;

// 0: ldst store_res
// 1: ldst load_res
// 2-5: alu_vals_o
// 6-9: cmp_vals_o
cdb_t cdb;

logic alu_rs_full;
logic cmp_rs_full;
cmp_rs_t cmp_o;
alu_rs_t alu_o;
lsb_t lsb_decode_o;
logic ldst_full;

logic rob_store_complete;
logic rob_curr_is_store;
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] rob_head_tag;

logic rob_is_empty;
logic rob_is_full;

rv32i_reg rs1_alu_rs_i, rs2_alu_rs_i;
regfile_data_out_t alu_rs_d_outl;
rv32i_reg rs1_cmp_rs_i, rs2_cmp_rs_i;
regfile_data_out_t cmp_rs_d_out;

i_fetch i_fetch (
    .clk(clk),
    .rst(rst),
    .mem_resp(inst_resp),
    .mem_rdata(inst_rdata), // 32-bit instruction input
    .i_queue_data_out(iqueue_o),
    .iqueue_read(iqueue_read),
    .mem_read(inst_read),
    .mem_write(),
    .pc_o(inst_addr)
);

i_decode decode (
    .clk(clk),
    .rst(rst),
    .d_in(iqueue_o),
    .iqueue_read(iqueue_read),
    .regfile_entry_i(regfile_data_o),
    .rs1_o(rs1_from_decoder),
    .rs2_o(rs2_from_decoder),
    .rd_o(rd_from_decoder),
    .tag(tag_decoder),
    .load_tag(load_tag),
    .rob_free_tag(rob_free_tag),
    .rob_in(rob_arr),
    .rob_write(rob_write),
    // I'm going to use the i_decode_opcode_t version
    // .rob_dest(),           // dest_reg, send to ROB to load it in
    .pc_and_rd(pc_and_rd),
    .alu_rs_full(alu_rs_full),
    .alu_o(alu_o),
    .cmp_rs_full(cmp_rs_full),
    .cmp_o(cmp_o),
    .lsb_full(ldst_full),
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
    .rob_o(rob_o),
    .rob_is_committing(rob_is_committing),
    .d_out(regfile_data_o),
    // To/from RS
    .rs1_alu_rs_i(rs1_alu_rs_i),
    .rs2_alu_rs_i(rs2_alu_rs_i),
    .alu_rs_d_out(alu_rs_d_out),
    .rs1_cmp_rs_i(rs1_cmp_rs_i),
    .rs2_cmp_rs_i(rs2_cmp_rs_i),
    .cmp_rs_d_out(cmp_rs_d_out)
);

load_store_queue ldstbuf (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .load(load_ldst),
    .cdb(cdb),
    .lsb_entry(lsb_decode_o), // from ROB/decode
    .store_res(cdb[0]),
    .load_res(cdb[1]),
    .ldst_full(ldst_full),

    //() To/from ROB
    .rob_store_complete(rob_store_complete),
    .curr_is_store(rob_curr_is_store),
    .head_tag(rob_head_tag),
    
    // From/to d-cache
    .data_read(data_read),
    .data_write(data_write),
    .data_mbe(data_mbe), // mem byte enable
    .data_addr(data_addr),
    .data_wdata(data_wdata),
    .data_resp(data_resp),
    .data_rdata(data_rdata)
);

ro_buffer rob (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .cdb(cdb),
    .write(rob_write),
    .input_i(pc_and_rd),
    .rob_arr_o(rob_arr),
    .rob_free_tag(rob_free_tag),
    .empty(rob_is_empty),
    .full(rob_is_full),
    .rob_o(rob_o),
    .is_committing(rob_is_committing),
    .rob_store_complete(rob_store_complete),
    .curr_is_store(rob_curr_is_store),
    .head_tag(rob_head_tag)
);

alu_rs alu_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // From ROB
    // .rob_reg_vals(),
    // .rob_commit_arr(),
    .rob_arr_o(rob_arr),
    // From/to CDB
    .cdb_vals_i(cdb),
    .cdb_alu_vals_o(cdb[`ALU_RS_SIZE-1+2 -: `ALU_RS_SIZE]),
    // From decoder
    .alu_o(alu_o),
    // To decoder
    .alu_rs_full(alu_rs_full),
    // To/from regfile
    .rs1_alu_rs_i(rs1_alu_rs_i),
    .rs2_alu_rs_i(rs2_alu_rs_i),
    .alu_rs_d_out(alu_rs_d_out)
);

cmp_rs cmp_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // From ROB
    // .rob_reg_vals(),
    // .rob_commit_arr(),
    .rob_arr_o(rob_arr),
    // From/to CDB
    .cdb_vals_i(cdb),
    .cdb_cmp_vals_o(cdb[(2*(`CMP_RS_SIZE-1))+3 -: `CMP_RS_SIZE]), // I think this is right
    // From decoder
    .cmp_o(cmp_o),
    // To decoder
    .cmp_rs_full(cmp_rs_full),
    .rs1_cmp_rs_i(rs1_cmp_rs_i),
    .rs2_cmp_rs_i(rs2_cmp_rs_i),
    .cmp_rs_d_out(cmp_rs_d_out)
);

endmodule : mp4
