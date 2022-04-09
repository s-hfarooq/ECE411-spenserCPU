include rv32i_types::*;
include structs::*;

module i_decode(
    input clk,
    input rst,
    input load,

    // From Instruction Queue
    input i_queue_data_t d_in,

    // To Instruction Queue
    output logic iqueue_read,

    // From Register File
    input rv32i_word vj, vk, // r1, r2 inputs

    // From Reorder Buffer
    input [2:0] rob_tag,

    // To Reorder Buffer
    output logic rob_write,

    // From ALU Reservation Station
    input logic alu_rs_full,  // Signal is high if RS is full

    // To ALU Reservation Station
    output alu_rs_t alu_o,

    // From CMP Reservation Station
    input logic cmp_rs_full,    // Signal is high if RS is full

    // From Load-Store Buffer
    input logic lsb_full    // Signal is high if buffer is full

    // output i_decode_opcode_t op
);

i_decode_opcode_t op;

rv32i_word alu_vj;
rv32i_word alu_vk;
rv32i_word alu_qj;
rv32i_word alu_qk;
alu_ops alu_op;
logic [2:0] alu_tag;

assign alu_o.alu_vj = alu_vj;
assign alu_o.alu_vk = alu_vk;
assign alu_o.alu_qj = alu_qj;
assign alu_o.alu_qk = alu_qk;
assign alu_o.alu_op = alu_op;
assign alu_o.alu_tag = alu_tag;


// taken from IR register
assign op.instr_pc = d_in.pc;
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

// Decode + Issue
always_ff @ (posedge clk) begin
    case (op.opcode)
        op_lui : begin
            if (op.rd != 0 && alu_rs_full == 0) begin
                // send signals to ROB and ALU RS
            end
        end

        op_auipc : begin
            if (op.rd != 0 && alu_rs_full == 0) begin
                // Send signals to ROB and ALU RS
            end
        end

        op_jal : ;
        op_jalr : ;

        op_br : begin
            if (cmp_rs_full == 0) begin
                // Send signals to ROB and CMP RS
            end
        end

        op_load : begin
            if (op.rd != 0 && lsb_full == 0) begin
                // Send data to ROB and Load-Store Buffer
            end
        end

        op_store : begin
            if (op.rd != 0 && lsb_full == 0) begin
                // Send data to ROB and Load-Store Buffer
            end
        end

        op_imm : begin
            if (op.rd != 0) begin
                // Send data to ROB
                case (op.arith_funct3)
                    // Might be able to combine add, sll, axor, aor, aand
                    add : begin
                        if (alu_rs_full == 0) begin
                            // Send data to ALU RS
                            // alu_vj = ;
                            // alu_vk = ;
                            // alu_qj = ;
                            // alu_qk = ;
                            alu_op = alu_ops'(op.arith_funct3);
                            // alu_tag = ;
                            rob_write <= 1'b1;
                        end
                    end
                    sll : ;
                    slt : ;
                    sltu : ;
                    axor : ;
                    sr : ;
                    aor : ;
                    aand : ;
                    default : ;
                endcase
            end
        end

        op_reg : ;
        op_csr : ;
        default : ;
    endcase
end

always_comb begin

end

// opcode	 LUI 	op	 0110111 	funct3	 imm[31:12] 	funct7	 imm[31:12]
// opcode	 AUIPC 	op	 0010111 	funct3	 imm[31:12] 	funct7	 imm[31:12]
// opcode	 JAL 	op	 1101111 	funct3	 imm[20|10:1|11|19:12] 	funct7	 imm[20|10:1|11|19:12]
// opcode	 JALR 	op	 1100111 	funct3	 000 	funct7	 imm[11:0]
// opcode	 BEQ 	op	 1100011 	funct3	 000 	funct7	 imm[12|10:5]
// opcode	 BNE 	op	 1100011 	funct3	 001 	funct7	 imm[12|10:5]
// opcode	 BLT 	op	 1100011 	funct3	 100 	funct7	 imm[12|10:5]
// opcode	 BGE 	op	 1100011 	funct3	 101 	funct7	 imm[12|10:5]
// opcode	 BLTU 	op	 1100011 	funct3	 110 	funct7	 imm[12|10:5]
// opcode	 BGEU 	op	 1100011 	funct3	 111 	funct7	 imm[12|10:5]
// opcode	 LB 	op	 0000011 	funct3	 000 	funct7	 imm[11:0]
// opcode	 LH 	op	 0000011 	funct3	 001 	funct7	 imm[11:0]
// opcode	 LW 	op	 0000011 	funct3	 010 	funct7	 imm[11:0]
// opcode	 LBU 	op	 0000011 	funct3	 100 	funct7	 imm[11:0]
// opcode	 LHU 	op	 0000011 	funct3	 101 	funct7	 imm[11:0]
// opcode	 SB 	op	 0100011 	funct3	 000 	funct7	 imm[11:5]
// opcode	 SH 	op	 0100011 	funct3	 001 	funct7	 imm[11:5]
// opcode	 SW 	op	 0100011 	funct3	 010 	funct7	 imm[11:5]
// opcode	 ADDI 	op	 0010011 	funct3	 000 	funct7	 imm[11:0]
// opcode	 SLTI 	op	 0010011 	funct3	 010 	funct7	 imm[11:0]
// opcode	 SLTIU 	op	 0010011 	funct3	 011 	funct7	 imm[11:0]
// opcode	 XORI 	op	 0010011 	funct3	 100 	funct7	 imm[11:0]
// opcode	 ORI 	op	 0010011 	funct3	 110 	funct7	 imm[11:0]
// opcode	 ANDI 	op	 0010011 	funct3	 111 	funct7	 imm[11:0]
// opcode	 SLLI 	op	 0010011 	funct3	 001 	funct7	 0000000
// opcode	 SRLI 	op	 0010011 	funct3	 101 	funct7	 0000000
// opcode	 SRAI 	op	 0010011 	funct3	 101 	funct7	 0100000
// opcode	 ADD 	op	 0110011 	funct3	 000 	funct7	 0000000
// opcode	 SUB 	op	 0110011 	funct3	 000 	funct7	 0100000
// opcode	 SLL 	op	 0110011 	funct3	 001 	funct7	 0000000
// opcode	 SLT 	op	 0110011 	funct3	 010 	funct7	 0000000
// opcode	 SLTU 	op	 0110011 	funct3	 011 	funct7	 0000000
// opcode	 XOR 	op	 0110011 	funct3	 100 	funct7	 0000000
// opcode	 SRL 	op	 0110011 	funct3	 101 	funct7	 0000000
// opcode	 SRA 	op	 0110011 	funct3	 101 	funct7	 0100000
// opcode	 OR 	op	 0110011 	funct3	 110 	funct7	 0000000
// opcode	 AND 	op	 0110011 	funct3	 111 	funct7	 0000000

endmodule
