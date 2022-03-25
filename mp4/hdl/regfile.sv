module regfile (
    input logic clk,
    input logic rst,
    input logic flush,

    // From decoder
    input logic load_tag,
    input rv32i_reg tag_decoder,
    input rv32i_word rs1_in,
    input rv32i_word rs2_in,

    // From ROB
    input logic load_reg,
    input rv32i_reg reg_dest_rob,
    input rv32i_word reg_val,
    input rv32i_reg tag_rob,

    // To reservation stations
    output rv32i_word vj_out,
    output rv32i_word vk_out
);

assign vj_out = (rs1_in == 0) ? 32'h0000_0000 : regfile[rs1_in];
assign vk_out = (rs2_in == 0) ? 32'h0000_0000 : regfile[rs2_in];

logic [31:0] regfile [31:0];
logic [4:0] tags [31:0];

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
    else if (load_reg == 1'b1 && reg_dest_rob != 5'b00000) begin
        regfile[reg_dest_rob] <= reg_val;

        // Clear tag for the register being of ROB commit when
        // the tag of the register being modified matches the tag
        // of the ROB entry that was just committed
        if (tags[reg_dest_rob] == tag_rob)
            tags[reg_dest_rob] <= 5'b00000;
    end

    // Load register tag from decoder
    else if (load_tag)
        tags[reg_id] <= tag_decoder;
end

endmodule : regfile
