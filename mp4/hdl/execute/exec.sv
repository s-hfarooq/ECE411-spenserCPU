import rv32i_types::*;
import structs::*;
import macros::*;


module exec (
    input logic clk,
    input logic rst,
    input logic flush,
    // inputs from decode / issue
    input logic load_tag,
    input rv32i_reg tag_decoder,
    input rv32i_reg reg_id_decoder,
    input i_decode_opcode_t op_in,

    
    // outputs to commit 
);

regfile_data_out_t regfile_d_out;
logic load_reg;

logic rob_read, rob_flush;

rob_values_t rob_o;
logic rob_is_commiting;

cdb_t cdb;


regfile register_file(
    .clk(),
    .rst(),
    .flush(),

    // From decoder
    .load_tag(load_tag),
    .tag_decoder(tag_decoder),
    .reg_id_decoder(reg_id_decoder),
    .op_in(op_in),

    // From ROB
    .load_reg(),
    .reg_id_rob(),
    .reg_val(),
    .tag_rob(),

    // To reservation stations
    .d_out(regfile_d_out)
    // .vj_out(), // operands, s1 and s2
    // .vk_out(),
    // .qj_out(),  // tags for operands, s1 and s2
    // .qk_out(),
    // .qi_out()   // result tag
);

ldst_buffer ldstbuf(

);

ro_buffer rob(

);

alu_reservation_station alu_rs(
    .cdb_alu_vals_o(cdb[4:0])
);

cmp_reservation_station cmp_rs(

);

cmp comparator(
    .cmpop(),
    .a(), 
    .b(),
    .f()
);

alu alu(
    .aluop(),
    .a(), 
    .b(),
    .f()
);


endmodule: exec