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
    output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe,
    output rv32i_word data_addr,
    output rv32i_word data_wdata,
    input logic data_resp,
    input rv32i_word data_rdata,

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

regfile_data_out_t regfile_d_out;
logic load_reg;

logic rob_read, rob_flush;

rob_values_t rob_o;
logic rob_is_commiting;

cdb_t cdb;

logic alu_rs_full;
logic cmp_rs_full;

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
    .rob_free_tag(4'd1),
    .rob_in(),
    .rob_write(),
    .rob_dest(),
    .alu_rs_full(alu_rs_full),
    .alu_o(alu_o),
    .cmp_rs_full(cmp_rs_full),
    .cmp_o(),
    .lsb_full(1'b0),
    .lsb_o()
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

load_store_queue ldstbuf (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .load(),
    .cdb(cdb),
    .lsb_entry(), // from ROB
    .store_res(),
    .load_res(),
    .ldst_full(),

    //() To/from ROB
    .rob_store_complete(),
    .curr_is_store(),
    .head_tag(),
    
    // From/to d-cache
    .data_read(),
    .data_write(),
    .data_mbe(), // mem byte enable
    .data_addr(),
    .data_wdata(),
    .data_resp(),
    .data_rdata(),
);

ro_buffer rob (
    .clk(clk),
    .rst(rst),
    .flush(),
    .read(flush),
    .write(),

    // From decoder
    .input_i(),
    .instr_pc_in(),
    
    // From reservation station
    .value_in_reg(),

    // To decoder
    .rob_arr_o(),
    .reg_o(),
    .empty(),
    .full(),

    // To regfile/reservation station
    .rob_o(),
    .is_commiting(),

    // To/from load store queue
    .rob_store_complete(),
    .curr_is_store(),
    .head_tag()
);

alu_reservation_station alu_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .load(),

    // From ROB
    .rob_reg_vals(),
    .rob_commit_arr(),

    // From/to CDB
    .cdb_vals_i(),
    .cdb_alu_vals_o(),

    // From decoder
    .alu_o(),

    // To decoder
    .alu_rs_full(alu_rs_full)
);

cmp_reservation_station cmp_rs (
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .load(),

    // From ROB
    .rob_reg_vals(),
    .rob_commit_arr(),

    // From/to CDB
    .cdb_vals_i(),
    .cdb_alu_vals_o(),

    // From decoder
    .cmp_o(),

    // To decoder
    .cmp_rs_full(cmp_rs_full)
);

endmodule : mp4
