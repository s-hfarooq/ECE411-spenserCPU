import rv32i_types::*;
import structs::*;
import macros::*;

module i_decode(
    input clk,
    input rst,
    input load,

    // From Instruction Queue
    input i_queue_data_t d_in,

    // To Instruction Queue
    output logic iqueue_read,

    // From Register File
    input rv32i_word reg_vj, reg_vk, // r1, r2 inputs

    // From Reorder Buffer
    input logic [2:0] rob_tag,
    // input 

    // To Reorder Buffer
    output logic rob_write,
    output rv32i_word rob_dest, // Tag/address

    // From ALU Reservation Station
    input logic alu_rs_full,  // Signal is high if RS is full

    // To ALU Reservation Station
    output alu_rs_t alu_o,

    // From CMP Reservation Station
    input logic cmp_rs_full,    // Signal is high if RS is full

    // To CMP Reservation Station
    output cmp_rs_t cmp_o,

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

always_comb begin
    // if source register is not reg0, and if ROB has the value for the
    // source register, use that value for the source operand, otherwise
    // use the value from the regfile.
    if (reg_vj != 0 && )
end

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

        op_jal : begin
            if (alu_rs_full == 0) begin
                rob_dest <= op.rd;
                rob_write <= 1'b1;
                alu_vj <= op.instr_pc;
                alu_vk <= 32'd4;
                alu_qj <= 3'd0;
                alu_qk <= 3'd0;
                alu_op <= alu_add;
                rob_write <= 1'b1;
            end
        end

        op_jalr : begin
            // ????? no idea what conditions to use, CHECK
            if () begin

            end
        end

        op_br : begin
            if (cmp_rs_full == 0) begin
                rob_dest <= op.rd;
                rob_write <= 1'b1;

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
                // ...
                case (op.funct3)
                    slt : begin
                        if (cmp_rs_full == 0) begin
                            // send data to CMP Reservation Station
                            rob_write <= 1'b1;
                        end
                    end

                    sltu : begin
                        if (cmp_rs_full == 0) begin
                            // send data to CMP reservation station
                            rob_write <= 1'b1;
                        end
                    end

                    sr : begin
                        if (alu_rs_full == 0) begin
                            case (funct7[5])
                                1'b0 : begin
                                    // alu_vj <= ;
                                    alu_vk <= op.i_imm;
                                    // alu_qj = ;
                                    alu_qk <= 32'b0;
                                    alu_op <= alu_srl;
                                    rob_write <= 1'b1;
                                end

                                1'b1 : begin
                                    // alu_vj = ;
                                    alu_vk <= op.i_imm;
                                    // alu_qj = ;
                                    alu_qk <= 32'b0;
                                    alu_op <= alu_sra;
                                    rob_write <= 1'b1;
                                end

                                default : ;
                            endcase
                        end
                    end

                    default : begin  // add, sll, axor, aor, aand
                        if (alu_rs_full == 0) begin
                            // alu_vj = ;
                            alu_vk = op.i_imm;
                            // alu_qj = ;
                            alu_qk <= 32'b0;
                            alu_op <= alu_ops'(op.funct3);
                            rob_write <= 1'b1;
                        end
                    end
                endcase
            end
        end

        op_reg : begin
            if (op.rd != 0) begin
                case (op.funct3)
                    add : begin
                        if (alu_rs_full == 0) begin
                            case (funct7[5])
                                1'b0: begin
                                    // alu_vj <= ;
                                    // alu_vk <= ;
                                    // alu_qj <= ;
                                    // alu_qk <= ;
                                    alu_op <= alu_add;
                                    rob_write <= 1'b1;
                                end

                                1'b1: begin
                                    // alu_vj = ;
                                    // alu_vk = ;
                                    // alu_qj = ;
                                    // alu_qk = ;
                                    alu_op <= alu_sub;
                                    rob_write <= 1'b1;
                                end
                                default : ;
                            endcase
                        end
                    end

                    slt : begin // send data to cmp rs somehow
                        if (cmp_rs_full == 0) begin
                            // cmp_o.cmp_vj <= ;
                            // cmp_o.cmp_vk <= ;
                            // cmp_o.cmp_qj <= ;
                            // cmp_o.cmp_qk <= ;
                            cmp_o.cmp_op <= blt;
                            rob_write <= 1'b1;
                        end
                        
                    end

                    sltu : begin
                        if (cmp_rs_full == 0) begin
                            // cmp_o.cmp_vj <= ;
                            // cmp_o.cmp_vk <= ;
                            // cmp_o.cmp_qj <= ;
                            // cmp_o.cmp_qk <= ;
                            cmp_o.cmp_op <= bltu;
                            rob_write <= 1'b1;
                        end
                    end

                    sr : begin
                        if (alu_rs_full == 0) begin
                            case (funct7[5])
                                1'b0: begin
                                    // alu_vj <= ;
                                    // alu_vk <= ;
                                    // alu_qj <= ;
                                    // alu_qk <= ;
                                    alu_op <= alu_sll;
                                    rob_write <= 1'b1;
                                end

                                1'b1: begin
                                    // alu_vj <= ;
                                    // alu_vk <= ;
                                    // alu_qj <= ;
                                    // alu_qk <= ;
                                    alu_op <= alu_sra;
                                    rob_write <= 1'b1;
                                end
                                default : ;
                            endcase
                        end
                    end

                    default : begin  // sll, axor, aor, aand
                        if (alu_rs_full == 0) begin
                            alu_op = alu_ops'(op.funct3);
                        end
                    end
                endcase
            end
        end
        default : ;
    endcase
end

always_comb begin

end

endmodule
