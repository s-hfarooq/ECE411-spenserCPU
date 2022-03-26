typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;

module regfile (
    input logic clk,
    input logic rst,
    input logic flush,

    // From decoder
    input logic load_tag,
    input rv32i_reg tag_decoder,
    input rv32i_word rs1_in,
    input rv32i_word rs2_in,
    input rv32i_reg reg_id_decoder,

    // From ROB
    input logic load_reg,
    input rv32i_reg reg_id_rob,
    input rv32i_word reg_val,
    input rv32i_reg tag_rob,

    // To reservation stations
    output rv32i_word vj_out,
    output rv32i_word vk_out,
    output rv32i_reg qj_out,
    output rv32i_reg qk_out,
	 
	 // testing
	 output rv32i_word reg1_val, reg2_val, reg3_val, reg4_val, reg5_val, reg6_val, reg7_val, reg8_val,
							 reg9_val, reg10_val, reg11_val, reg12_val, reg13_val, reg14_val, reg15_val, reg16_val,
							 reg17_val, reg18_val, reg19_val, reg20_val, reg21_val, reg22_val, reg23_val, reg24_val,
							 reg25_val, reg26_val, reg27_val, reg28_val, reg29_val, reg30_val, reg31_val
);

// Main structures
logic [31:0] regfile [31:0];
logic [4:0] tags [31:0];

// Testing
assign reg1_val  = regfile[1]; assign reg2_val  = regfile[2]; assign reg3_val  = regfile[3]; assign reg4_val  = regfile[4];
assign reg5_val  = regfile[5]; assign reg6_val  = regfile[6]; assign reg7_val  = regfile[7]; assign reg8_val  = regfile[8];
assign reg9_val  = regfile[9]; assign reg10_val = regfile[10];assign reg11_val = regfile[11];assign reg12_val = regfile[12];
assign reg13_val = regfile[13];assign reg14_val = regfile[14];assign reg15_val = regfile[15];assign reg16_val = regfile[16];
assign reg17_val = regfile[17];assign reg18_val = regfile[18];assign reg19_val = regfile[19];assign reg20_val = regfile[20];
assign reg21_val = regfile[21];assign reg22_val = regfile[22];assign reg23_val = regfile[23];assign reg24_val = regfile[24];
assign reg25_val = regfile[25];assign reg26_val = regfile[26];assign reg27_val = regfile[27];assign reg28_val = regfile[28];
assign reg29_val = regfile[29];assign reg30_val = regfile[30];assign reg31_val = regfile[31];

// To reservation stations
assign vj_out = (rs1_in == 0) ? 32'h0000_0000 : regfile[rs1_in];
assign vk_out = (rs2_in == 0) ? 32'h0000_0000 : regfile[rs2_in];
assign qj_out = tags[rs1_in];
assign qk_out = tags[rs2_in];

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
