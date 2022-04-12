import rv32i_types::*;
import structs::*;

module regfile (
    input logic clk,
    input logic rst,
    input logic flush,

    // From decoder
    input logic load_tag,
    input tag_t tag_decoder,
    input rv32i_reg reg_id_decoder,
    // input i_decode_opcode_t op_in,
    input rv32i_reg rs1_i, rs2_i,
    input rv32i_reg rs1_alu_rs_i, rs2_alu_rs_i,
    input rv32i_reg rs1_cmp_rs_i, rs2_cmp_rs_i,

    // From ROB
    input logic load_reg,
    input rv32i_reg reg_id_rob, // Destination reg from ROB
    input rv32i_word reg_val,
    input rv32i_reg tag_rob,    // Tag from ROB

    // Outputs
    output regfile_data_out_t d_out,
    output regfile_data_out_t alu_rs_d_out,
    output regfile_data_out_t cmp_rs_d_out

    // output rv32i_word vj_out, // operands, s1 and s2
    // output rv32i_word vk_out,
    // output rv32i_reg qj_out,  // tags for operands, s1 and s2
    // output rv32i_reg qk_out,
    // output rv32i_reg qi_out   // result tag
    // testing, uncomment to test
    // output rv32i_word reg0_val,  reg1_val,  reg2_val,  reg3_val,  reg4_val,  reg5_val,  reg6_val,  reg7_val,
    //                   reg8_val,  reg9_val,  reg10_val, reg11_val, reg12_val, reg13_val, reg14_val, reg15_val,
    //                   reg16_val, reg17_val, reg18_val, reg19_val, reg20_val, reg21_val, reg22_val, reg23_val,
    //                   reg24_val, reg25_val, reg26_val, reg27_val, reg28_val, reg29_val, reg30_val, reg31_val,
    // output rv32i_reg tag0_val,  tag1_val,  tag2_val,  tag3_val,  tag4_val,  tag5_val,  tag6_val,  tag7_val,
    //                  tag8_val,  tag9_val,  tag10_val, tag11_val, tag12_val, tag13_val, tag14_val, tag15_val,
    //                  tag16_val, tag17_val, tag18_val, tag19_val, tag20_val, tag21_val, tag22_val, tag23_val,
    //                  tag24_val, tag25_val, tag26_val, tag27_val, tag28_val, tag29_val, tag30_val, tag31_val
);

// Main structures
logic [31:0] regfile [31:0];
logic [4:0] tags [31:0];

// Testing, uncomment to test
// assign reg1_val  = regfile[1]; assign reg2_val  = regfile[2]; assign reg3_val  = regfile[3]; assign reg4_val  = regfile[4];
// assign reg5_val  = regfile[5]; assign reg6_val  = regfile[6]; assign reg7_val  = regfile[7]; assign reg8_val  = regfile[8];
// assign reg9_val  = regfile[9]; assign reg10_val = regfile[10];assign reg11_val = regfile[11];assign reg12_val = regfile[12];
// assign reg13_val = regfile[13];assign reg14_val = regfile[14];assign reg15_val = regfile[15];assign reg16_val = regfile[16];
// assign reg17_val = regfile[17];assign reg18_val = regfile[18];assign reg19_val = regfile[19];assign reg20_val = regfile[20];
// assign reg21_val = regfile[21];assign reg22_val = regfile[22];assign reg23_val = regfile[23];assign reg24_val = regfile[24];
// assign reg25_val = regfile[25];assign reg26_val = regfile[26];assign reg27_val = regfile[27];assign reg28_val = regfile[28];
// assign reg29_val = regfile[29];assign reg30_val = regfile[30];assign reg31_val = regfile[31];assign reg0_val  = regfile[0];
// assign tag1_val  = tags[1]; assign tag2_val  = tags[2]; assign tag3_val  = tags[3]; assign tag4_val  = tags[4];
// assign tag5_val  = tags[5]; assign tag6_val  = tags[6]; assign tag7_val  = tags[7]; assign tag8_val  = tags[8];
// assign tag9_val  = tags[9]; assign tag10_val = tags[10];assign tag11_val = tags[11];assign tag12_val = tags[12];
// assign tag13_val = tags[13];assign tag14_val = tags[14];assign tag15_val = tags[15];assign tag16_val = tags[16];
// assign tag17_val = tags[17];assign tag18_val = tags[18];assign tag19_val = tags[19];assign tag20_val = tags[20];
// assign tag21_val = tags[21];assign tag22_val = tags[22];assign tag23_val = tags[23];assign tag24_val = tags[24];
// assign tag25_val = tags[25];assign tag26_val = tags[26];assign tag27_val = tags[27];assign tag28_val = tags[28];
// assign tag29_val = tags[29];assign tag30_val = tags[30];assign tag31_val = tags[31];assign tag0_val  = tags[0];

// To decoder
assign d_out.vj_out = (rs1_i == 0) ? 32'h0000_0000 : regfile[rs1_i];
assign d_out.vk_out = (rs2_i == 0) ? 32'h0000_0000 : regfile[rs2_i];
assign d_out.qj_out = tags[rs1_i];
assign d_out.qk_out = tags[rs2_i];

// to ALU units
assign alu_rs_d_out.vj_out = (rs1_alu_rs_i == 0) ? 32'h0000_0000 : regfile[rs1_alu_rs_i];
assign alu_rs_d_out.vk_out = (rs2_alu_rs_i == 0) ? 32'h0000_0000 : regfile[rs2_alu_rs_i];
assign alu_rs_d_out.qj_out = tags[rs1_alu_rs_i];
assign alu_rs_d_out.qk_out = tags[rs2_alu_rs_i];

// to CMP units
assign cmp_rs_d_out.vj_out = (rs1_cmp_rs_i == 0) ? 32'h0000_0000 : regfile[rs1_cmp_rs_i];
assign cmp_rs_d_out.vk_out = (rs2_cmp_rs_i == 0) ? 32'h0000_0000 : regfile[rs2_cmp_rs_i];
assign cmp_rs_d_out.qj_out = tags[rs1_cmp_rs_i];
assign cmp_rs_d_out.qk_out = tags[rs2_cmp_rs_i];

always_ff @ (posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 32; ++i) begin
            regfile[i] <= 32'h0000_0000;
            tags[i] <= 5'b00000;
        end
    end
    else if (flush) begin
        // ????????????
    end
    // Load register value from ROB
    else if (load_reg == 1'b1 && reg_id_rob != 5'b00000) begin
        regfile[reg_id_rob] <= reg_val;

        /* Clear tag for the register being of ROB commit when the tag of
        the register being modified matches the tag of the ROB entry that
        was just committed */
        if (tags[reg_id_rob] == tag_rob)
            tags[reg_id_rob] <= 5'b00000;
    end

    // Load register tag from decoder
    else if (load_tag)
        tags[reg_id_decoder] <= tag_decoder;
end

endmodule : regfile
