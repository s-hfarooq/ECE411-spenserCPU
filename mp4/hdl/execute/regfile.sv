import rv32i_types::*;
import structs::*;

module regfile (
    input logic clk,
    input logic rst,
    input logic flush,

    // From decoder
    input logic load_tag, // load_tag in decoder
    input tag_t tag_decoder, // tag in decoder
    input rv32i_reg reg_id_decoder, // rd_o in decoder
    input rv32i_reg rs1_i, rs2_i,
    output regfile_data_out_t d_out,

    // From ROB
    input rob_values_t rob_o,
    input logic rob_is_committing
);

// Main structures
logic [31:0] regfile [31:0];

// To decoder
assign d_out.vj_out = (rs1_i == 0) ? 32'h0000_0000 : regfile[rs1_i];
assign d_out.vk_out = (rs2_i == 0) ? 32'h0000_0000 : regfile[rs2_i];


always_ff @ (posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 32; ++i) begin
            regfile[i] <= 32'h0000_0000;
        end
    end else if (rob_is_committing == 1'b1 && rob_o.op.rd != 0) begin
        // Load register value from ROB
        regfile[rob_o.op.rd] <= rob_o.reg_data.value;

        /* Clear tag for the register being of ROB commit when the tag of
        the register being modified matches the tag of the ROB entry that
        was just committed */
        // if (tags[rob_o.op.rd] == rob_o.tag)
        //     tags[rob_o.op.rd] <= 5'b00000;
    end
end

endmodule : regfile
