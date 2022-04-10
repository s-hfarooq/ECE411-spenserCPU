`include "macros.sv"

import rv32i_types::*;
import structs::*;

module i_decode(
    input clk,
    input rst,
    input load,

    // From Instruction Queue
    input i_queue_data_t d_in,

    // To Instruction Queue
    output logic iqueue_read,

    // From Register File
    // input rv32i_word reg_vj, reg_vk, // r1, r2 inputs
    input regfile_data_out_t regfile_entry_i,

    // To Register File
    output rv32i_reg rs1_o, rs2_o,
    output logic [3:0] tag,
    output logic load_tag,

    // From Reorder Buffer
    input logic [3:0] rob_free_tag,
    // input rv32i_word rob_reg_vals [RO_BUFFER_ENTRIES],
    // input logic rob_commit_arr [RO_BUFFER_ENTRIES],
    input rob_arr_t rob_in,

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

    // To Load-Store Buffer
    // output lsb_t lsb_o
);

i_decode_opcode_t op;

logic alu_valid;
rv32i_word alu_vj;
rv32i_word alu_vk;
rv32i_word alu_qj;
rv32i_word alu_qk;
alu_ops alu_op;
logic [2:0] alu_tag;

assign alu_o.valid = valid;
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

load_funct3_t load_funct3;
store_funct3_t store_funct3;
branch_funct3_t branch_funct3;
assign load_funct3 = load_funct3_t'(op.funct3);
assign store_funct3 = store_funct3_t'(op.funct3);
assign branch_funct3 = branch_funct3_t'(op.funct3);

// Glue signals
rv32i_word vj_o, vk_o;
logic [2:0] qj_o, qk_o;
assign rs1_o = op.rs1;
assign rs2_o = op.rs2;

always_comb begin
    // if source register is not reg0, and if ROB has the value for the
    // source register, use that value for the source operand, otherwise
    // use the value from the regfile.
    if (regfile_entry_i.qj_out != 0 && rob_in.entry_data[reg_qj].reg_data.can_commit) begin
        vj_o = rob_in.entry_data[reg_qj].reg_data.value;
        qj_o = 3'b000;
    end else begin
        vj_o = regfile_entry_i.vj_out;
        qj_o = regfile_entry_i.qj_out;
    end

    if (regfile_entry_i.qk_out != 0 && rob_in.entry_data[reg_qk].reg_data.can_commit) begin
        vk_o = rob_in.entry_data[reg_qk].reg_data.value;
        qk_o = 3'b000;
    end else begin
        vk_o = regfile_entry_i.vk_out;
        qk_o = regfile_entry_i.qk_out;
    end
end

// Decode + Issue
always_ff @ (posedge clk) begin
    case (op.opcode)
        op_lui : begin
            if (op.rd != 0 && alu_rs_full == 0 && rob_free_tag != 0) begin
                rob_dest <= op.rd;
                rob_write <= 1'b1;
                alu_vj <= 32'd0;
                alu_vk <= op.u_imm;
                alu_qj <= 4'd0;
                alu_qk <= 4'd0;
                alu_op <= alu_add;
                alu_tag <= rob_free_tag;
            end
        end

        op_auipc : begin
            if (op.rd != 0 && alu_rs_full == 0 && rob_free_tag != 0) begin
                rob_dest <= op.rd;
                rob_write <= 1'b1;
                alu_vj <= op.instr_pc;
                alu_vk <= op.u_imm;
                alu_qj <= 4'd0;
                alu_qk <= 4'd0;
                alu_op <= alu_add;
                alu_tag <= rob_free_tag;
            end
        end

        op_jal : begin
            if (alu_rs_full == 0) begin
                alu_valid <= 1'b1;
                rob_dest <= op.rd;
                rob_write <= 1'b1;
                alu_vj <= op.instr_pc;
                alu_vk <= 32'd4; // stores pc+4 into rd
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
                // cmp_o.br <= 1'b1;    // High if opcode is branch, non-branch opcodes also use
                // cmp_o.vj <= vj_o;
                // cmp_o.vk <= vk_o;
                // cmp_o.qj <= qj_o;
                // cmp_o.qk <= qk_o;
                // cmp_o.funct <= branch_funct3;
                // cmp_o.cmp_tag <= rob_free_tag;
                rob_write <= 1'b1;
            end
        end

        op_load : begin
            if (op.rd != 0 && lsb_full == 0) begin
                rob_dest <= op.rd;
                // lsb_o.vj <= vj_o;
                // lsb_o.vk <= 32'd0;
                // lsb_o.qj <= qj_o;
                // lsb_o.qk <= 32'd0;
                // lsb_o.addr <= op.i_imm;
                // lsb_o.op <= 1'b0;  // 0 = load, 1 = store
                // lsb_o.funct <= load_funct3;
                // lsb_o.tag <= rob_free_tag;
                rob_write <= 1'b1;
            end
        end

        op_store : begin
            if (op.rd != 0 && lsb_full == 0) begin
                // lsb_o.vj <= vj_o;
                // lsb_o.vk <= vk_o;
                // lsb_o.qj <= qj_o;
                // lsb_o.qk <= qk_o;
                // lsb_o.addr <= op.s_imm;
                // lsb_o.op <= 1'b1;  // 0 = load, 1 = store
                // lsb_o.funct <= store_funct3;
                // lsb_o.tag <= rob_free_tag;
                rob-write <= 1'b1;
            end
        end

        op_imm : begin
            if (op.rd != 0 && rob_free_tag != 0) begin
                // MAY NEED TO SEND INSTRUCTION TYPE TO ROB...
                rob_dest <= op.rd;
                case (op.funct3)
                    slt : begin
                        if (cmp_rs_full == 0) begin
                            // cmp_o.vj <= 
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
                                    alu_valid <= 1'b1;
                                    alu_vj <= vj_o;
                                    alu_vk <= op.i_imm;
                                    alu_qj <= qj_o;
                                    alu_qk <= 32'b0;
                                    alu_op <= alu_srl;
                                    rob_write <= 1'b1;
                                end

                                1'b1 : begin
                                    alu_valid <= 1'b1;
                                    alu_vj = vj_o;
                                    alu_vk <= op.i_imm;
                                    alu_qj <= qj_o;
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
                            alu_valid <= 1'b1;
                            alu_vj <= vj_o;
                            alu_vk <= op.i_imm;
                            alu_qj <= qj_o;
                            alu_qk <= 32'b0;
                            alu_op <= alu_ops'(op.funct3);
                            alu_tag <= rob_free_tag;
                            rob_write <= 1'b1;
                        end
                    end
                endcase
            end
        end

        op_reg : begin
            if (op.rd != 0 && rob_free_tag != 0) begin
                rob_dest <= op.rd;
                case (op.funct3)
                    add : begin
                        if (alu_rs_full == 0) begin
                            case (funct7[5])
                                1'b0: begin
                                    alu_valid <= 1'b1;
                                    alu_vj <= vj_o;
                                    alu_vk <= vk_o;
                                    alu_qj <= qj_o;
                                    alu_qk <= qk_o;
                                    alu_op <= alu_add;
                                    rob_write <= 1'b1;
                                    
                                end

                                1'b1: begin
                                    alu_valid <= 1'b1;
                                    alu_vj <= vj_o;
                                    alu_vk <= vj_o;
                                    alu_qj <= qj_o;
                                    alu_qk <= qk_o;
                                    alu_op <= alu_sub;
                                    rob_write <= 1'b1;
                                end
                                default : ;
                            endcase
                        end
                    end

                    slt : begin // send data to cmp rs somehow
                        if (cmp_rs_full == 0) begin
                            // cmp_o.br <= 1'b1;    // High if opcode is branch, non-branch opcodes also use
                            // cmp_o.cmp_vj <= ;
                            // cmp_o.cmp_vk <= ;
                            // cmp_o.cmp_qj <= ;
                            // cmp_o.cmp_qk <= ;
                            // cmp_o.funct <= branch_funct3;
                            // cmp_o.cmp_tag <= rob_free_tag;
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
                                    alu_valid <= 1'b1;
                                    alu_vj <= vj_o;
                                    alu_vk <= vk_o;
                                    alu_qj <= qj_o;
                                    alu_qk <= qk_o;
                                    alu_op <= alu_sll;
                                    rob_write <= 1'b1;
                                end

                                1'b1: begin
                                    alu_valid <= 1'b1;
                                    alu_vj <= vj_o;
                                    alu_vk <= vk_o;
                                    alu_qj <= qj_o;
                                    alu_qk <= qk_o;
                                    alu_op <= alu_sra;
                                    rob_write <= 1'b1;
                                end
                                default : ;
                            endcase
                        end
                    end

                    default : begin  // sll, axor, aor, aand
                        if (alu_rs_full == 0) begin
                            alu_valid <= 1'b1;
                            alu_op <= alu_ops'(op.funct3);
                        end
                    end
                endcase
            end
        end
        default : ;
    endcase
end

always_comb begin
    if (rst) begin
        iqueue_read = 1'b0;
        load_tag = 1'b0;
    end else begin
        case (op.opcode)
            op_lui, op_auipc, op_jal : begin
                if (alu_rs_full == 0 && rob_free_tag != 0) begin
                    iqueue_read = 1'b1;
                    load_tag = 1'b1;
                end
            end

            op_jalr : ; // ????????????????????????????????

            op_br : begin
                if (cmp_rs_full == 0 && rob_free_tag != 0)
                    iqueue_read = 1'b1;
            end

            op_load : begin
                if (lsb_full == 0 && rob_free_tag != 0) begin
                    iqueue_read = 1'b1;
                    load_tag = 1'b1;
                end
            end

            op_store : begin
                if (lsb_full == 0 && rob_free_tag != 0)
                    iqueue_read = 1'b1;
            end

            op_imm : begin
                if (rob_free_tag != 0) begin
                    case (op.funct3)
                        slt, sltu : begin
                            if (cmp_rs_full == 0) begin
                                iqueue_read = 1'b1;
                                load_tag = 1'b1;
                            end
                        end

                        sr, add, sll, axor, aor, aand: begin
                            if (alu_rs_full == 0) begin
                                iqueue_read = 1'b1;
                                load_tag = 1'b1;
                            end
                        end
                        default : ;
                    endcase
                end
            end

            op_reg : begin
                if (rob_free_tag != 0) begin
                    case (op.funct3)
                        slt, sltu : begin
                            if (cmp_rs_full == 0) begin
                                iqueue_read = 1'b1;
                                load_tag = 1'b1;
                            end
                        end

                        sr, add, sll, axor, aor, aand : begin
                            if (alu_rs_full == 0) begin
                                iqueue_read = 1'b1;
                                load_tag = 1'b1;
                            end
                        end
                        default : ;
                    endcase
                end
            end
            default : ;
        endcase
    end
end

endmodule
