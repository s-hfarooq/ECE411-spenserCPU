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

logic iqueue_read;
logic i_queue_empty;
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

logic rob_read;
logic flush;

rob_values_t rob_o;
logic rob_is_committing;

// 0: ldst store_res - no longer needed?
// 1: ldst load_res
// 2-5: alu_vals_o
// 6-9: cmp_vals_o
cdb_t cdb;

logic alu_rs_full;
logic cmp_rs_full;
cmp_rs_t cmp_o;
alu_rs_t alu_o;
lsb_t lsb_decode_o;
logic ldst_full, ldst_almost_full;

logic rob_store_complete;
logic rob_curr_is_store;
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] rob_head_tag;

logic rob_is_empty;
logic rob_is_full;

rv32i_reg rs1_alu_rs_i, rs2_alu_rs_i;
regfile_data_out_t alu_rs_d_outl;
rv32i_reg rs1_cmp_rs_i, rs2_cmp_rs_i;
regfile_data_out_t cmp_rs_d_out;

logic take_br;
rv32i_word next_pc;

logic i_cache_pmem_resp;
logic [255:0] i_cache_pmem_rdata;
logic [31:0] i_cache_pmem_address;
logic [255:0] i_cache_pmem_wdata;
logic i_cache_pmem_read;
logic i_cache_pmem_write;

rv32i_word instr_addr;
logic instr_read;
logic instr_resp;
logic [255:0] instr_rdata;
rv32i_word mem_address;
assign mem_addr = mem_address;

logic [255:0] data_rdata;
logic dcache_resp;
logic dcache_write;
logic dcache_read;
logic [3:0] dcache_byte_enable;
logic dcache_pmem_resp;
logic [255:0] dcache_pmem_rdata;
logic [31:0] dcache_pmem_address;
logic [255:0] dcache_pmem_wdata;
logic dcache_pmem_read;
logic dcache_pmem_write;
logic [31:0] d_cache_wdata;
logic [31:0] d_cache_address;

logic arbiter_mem_resp;
logic [255:0] arbiter_mem_rdata;
logic arbiter_mem_write;
logic arbiter_mem_read;
logic [255:0] arbiter_mem_wdata;
rv32i_word arbiter_mem_address;

cache i_cache (
    .clk(clk),
    /* Physical memory signals */
    .pmem_resp(i_cache_pmem_resp),
    .pmem_rdata(i_cache_pmem_rdata),
    .pmem_address(i_cache_pmem_address),
    .pmem_wdata(i_cache_pmem_wdata),
    .pmem_read(i_cache_pmem_read),
    .pmem_write(i_cache_pmem_write),
    /* CPU memory signals */
    .mem_read(instr_read),
    .mem_write(1'b0),
    .mem_byte_enable_cpu(4'b0),
    .mem_address(instr_addr),
    .mem_wdata_cpu(32'b0),
    .mem_resp(instr_resp),
    .mem_rdata_cpu(instr_rdata)
);

cache d_cache (
    .clk(clk),
    /* Physical memory signals */
    .pmem_resp(dcache_pmem_resp),
    .pmem_rdata(dcache_pmem_rdata),
    .pmem_address(dcache_pmem_address),
    .pmem_wdata(dcache_pmem_wdata),
    .pmem_read(dcache_pmem_read),
    .pmem_write(dcache_pmem_write),
    /* CPU memory signals */
    .mem_read(dcache_read),
    .mem_write(dcache_write),
    .mem_byte_enable_cpu(dcache_byte_enable),
    .mem_address(d_cache_address),
    .mem_wdata_cpu(d_cache_wdata),
    .mem_resp(dcache_resp),
    .mem_rdata_cpu(data_rdata)
);

arbiter arbiter (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // Memory
    .mem_rdata(arbiter_mem_rdata),
    .mem_addr(arbiter_mem_address),
    .mem_resp(arbiter_mem_resp),
    .mem_read(arbiter_mem_read),
    .mem_write(arbiter_mem_write),
    .mem_wdata(arbiter_mem_wdata),
    // Instruction Cache
    .inst_read(i_cache_pmem_read),
    .inst_addr(i_cache_pmem_address),
    .inst_resp(i_cache_pmem_resp),
    .inst_rdata(i_cache_pmem_rdata),
    // Data Cache
    .data_read(dcache_pmem_read),
    .data_write(dcache_pmem_write),
    .data_addr(dcache_pmem_address),
    .data_wdata(dcache_pmem_wdata),
    .data_resp(dcache_pmem_resp),
    .data_rdata(dcache_pmem_rdata)
);

cacheline_adaptor cacheline_adaptor (
    .clk(clk),
    .reset_n(~rst),
    .flush(1'b0),

    // Port to LLC (Lowest Level Cache)
    .line_i(arbiter_mem_wdata),
    .line_o(arbiter_mem_rdata),
    .address_i(arbiter_mem_address),
    .read_i(arbiter_mem_read),
    .write_i(arbiter_mem_write),
    .resp_o(arbiter_mem_resp),

    // Port to memory
    .burst_i(mem_rdata),
    .burst_o(mem_wdata),
    .address_o(mem_address),
    .read_o(mem_read),
    .write_o(mem_write),
    .resp_i(mem_resp)
);

i_fetch i_fetch (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .mem_resp(instr_resp),
    .mem_rdata(instr_rdata), // 32-bit instruction input
    .i_queue_data_out(iqueue_o),
    .iqueue_read(iqueue_read),
    .mem_read(instr_read),
    .pc_o(instr_addr),
    .take_br(take_br),
    .next_pc(next_pc),
    .i_queue_empty(i_queue_empty)
);

i_decode decode (
    .clk(clk),
    .rst(rst),
    .d_in(iqueue_o),
    .i_queue_empty(i_queue_empty),
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
    .cdb(cdb),
    .lsb_entry(lsb_decode_o), // from ROB/decode
    // .store_res(cdb[0]),
    .load_res(cdb[1]),
    .ldst_full(ldst_full),
    .almost_full(ldst_almost_full),
    //() To/from ROB
    .rob_store_complete(rob_store_complete),
    .curr_is_store(rob_curr_is_store),
    .head_tag(rob_head_tag),
    // From/to d-cache
    .data_read(dcache_read),
    .data_write(dcache_write),
    .data_mbe(dcache_byte_enable), // mem byte enable
    .data_addr(d_cache_address),
    .data_wdata(d_cache_wdata),
    .data_resp(dcache_resp),
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
    .head_tag(rob_head_tag),
    .pcmux_sel(take_br),
    .target_pc(next_pc),
    .take_br(take_br),
    .mem_resp(arbiter_mem_resp),
    .mem_read(arbiter_mem_read),
    .mem_write(arbiter_mem_write)
);

alu_rs alu_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    // From ROB
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
