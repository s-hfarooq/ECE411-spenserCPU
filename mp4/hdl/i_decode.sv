include rv32i_types::*;
include structs::*;
module i_decode(
    input clk,
    input rst,
    input load,
    input i_queue_data_t d_in,
    output i_decode_opcode_t op
);

assign op.funct3 = d_in.instr[14:12];
assign op.funct7 = d_in.instr[31:25];
assign op.opcode = rv32i_opcode'(d_in.instr[6:0]);
assign op.i_imm = {{21{d_in.instr[31]}}, d_in.instr[30:20]};
assign op.s_imm = {{21{d_in.instr[31]}}, d_in.instr[30:25], d_in.instr[11:7]};
assign op.b_imm = {{20{d_in.instr[31]}}, d_in.instr[7], d_in.instr[30:25], d_in.instr[11:8], 1'b0};
assign op.u_imm = {d_in.instr[31:12], 12'h000};
assign op.j_imm = {{12{d_in.instr[31]}}, d_in.instr[19:12], d_in.instr[20], d_in.instr[30:21], 1'b0};
assign op.rs1 = d_in.instr[19:15];
assign op.rs2 = d_in.instr[24:20];
assign op.rd = d_in.instr[11:7];

endmodule