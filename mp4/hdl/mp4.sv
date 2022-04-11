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
    output rv32i_word inst_addr, // WHERE DOES THIS CONNECT TO??? - PC
    input logic inst_resp,
    input rv32i_word inst_rdata    // 32-bit instruction

    // D-Cache signals
    /*output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe,
    output rv32i_word data_addr,
    output rv32i_word data_wdata,
    input logic data_resp,
    input rv32i_word data_rdata,*/

    // Testing
    // output rv32i_word i_queue_o
);

logic iqueue_read;
i_queue_data_t iqueue_o;
logic load_tag; // From Decoder to Regfile
alu_rs_t alu_o;
regfile_data_out_t regfile_data_o;  // From regfile to Decoder
logic [3:0] tag_decoder;
rv32i_reg rd_from_decoder;    // to Regfile
rv32i_reg rs1_from_decoder, rs2_from_decoder;

//assign mem_wdata = 32'b0;

// module cache (
//   input clk,

//   /* Physical memory signals */
//   input logic pmem_resp,
//   input logic [255:0] pmem_rdata,
//   output logic [31:0] pmem_address,
//   output logic [255:0] pmem_wdata,
//   output logic pmem_read,
//   output logic pmem_write,

//   /* CPU memory signals */
//   input logic mem_read,
//   input logic mem_write,
//   input logic [3:0] mem_byte_enable_cpu,
//   input logic [31:0] mem_address,
//   input logic [31:0] mem_wdata_cpu,
//   output logic mem_resp,
//   output logic [31:0] mem_rdata_cpu
// );
// cache i_cache(
//     .clk(clk),
//     .pmem_resp(),
//     .pmem_rdata(),
//     .pmem_address(),
//     .pmem_wdata(),
//     .pmem_read(),
//     .pmem_write(),
//     .mem_read(),
//     .mem_write(),
//     .mem_byte_enable_cpu(),
//     .mem_address(),
//     .mem_wdata_cpu(),
//     .mem_resp(),
//     .mem_rdata_cpu()
// );

i_fetch i_fetch(
    .clk(clk),
    .rst(rst),
    .mem_resp(inst_resp),
    .mem_rdata(inst_rdata), // 32-bit instruction input
    .iqueue_read(iqueue_read),
    .i_queue_data_out(iqueue_o),
    .mem_read(inst_read),
    .mem_write(),
    .pc_o(inst_addr)
);

i_decode decode(
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
    .rob_free_tag(4'd1),
    // .rob_reg_vals(),
    // .rob_commit_arr(),
    .rob_write(),
    .rob_dest(),
    .alu_rs_full(1'b0),
    .alu_o(alu_o),
    .cmp_rs_full(1'b0),
    // .cmp_o(),
    .lsb_full(1'b0)
);

regfile reg_file (
    .clk(clk),
    .rst(rst),
    .flush(1'b0),
    .load_tag(load_tag),
    .tag_decoder(tag_decoder),
    .reg_id_decoder(rd_from_decoder),
    .rs1_i(rs1_from_decoder),
    .rs2_i(rs2_from_decoder),
    .load_reg(),
    .reg_id_rob(),
    .reg_val(),
    .tag_rob(),
    .d_out(regfile_data_o)
);

endmodule : mp4
