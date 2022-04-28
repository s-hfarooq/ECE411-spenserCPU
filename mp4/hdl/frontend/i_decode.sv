`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module i_decode (
    input clk,
    input rst,
    input logic flush,
    // input load,

    // From Instruction Queue
    input i_queue_data_t d_in,
    input logic i_queue_empty,

    // To Instruction Queue
    output logic i_queue_read,

    // From Register File
    // input rv32i_word reg_vj, reg_vk, // r1, r2 inputs
    input regfile_data_out_t regfile_entry_i,

    // To Register File
    output rv32i_reg rs1_o, rs2_o, rd_o,
    output logic [3:0] tag,
    output logic load_tag,

    // From Reorder Buffer
    input logic [3:0] rob_free_tag,
    input rob_arr_t rob_in,
    input logic rob_is_full,

    // To Reorder Buffer
    output logic rob_write,
    // output rv32i_word rob_dest, // Tag/address
    output i_decode_opcode_t pc_and_rd,

    // From ALU Reservation Station
    input logic alu_rs_full,  // Signal is high if RS is full

    // To ALU Reservation Station
    output alu_rs_t alu_o,

    // From CMP Reservation Station
    input logic cmp_rs_full,    // Signal is high if RS is full

    // To CMP Reservation Station
    output cmp_rs_t cmp_o,

    // From Load-Store Buffer
    input logic lsb_full,    // Signal is high if buffer is full
    input logic lsb_almost_full,

    // To Load-Store Buffer
    output lsb_t lsb_o
);

// i_decode_opcode_t op;

rv32i_word instr_pc;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode;
logic [31:0] i_imm, s_imm, b_imm, u_imm, j_imm;
rv32i_reg rs1, rs2, rd;

// taken from IR register
assign instr_pc = d_in.pc;
assign funct3 = d_in.instr[14:12];
assign funct7 = d_in.instr[31:25];
assign opcode = rv32i_opcode'(d_in.instr[6:0]);
assign i_imm = {{21{d_in.instr[31]}}, d_in.instr[30:20]};
assign s_imm = {{21{d_in.instr[31]}}, d_in.instr[30:25], d_in.instr[11:7]};
assign b_imm = {{20{d_in.instr[31]}}, d_in.instr[7], d_in.instr[30:25], d_in.instr[11:8], 1'b0};
assign u_imm = {d_in.instr[31:12], 12'h000};
assign j_imm = {{12{d_in.instr[31]}}, d_in.instr[19:12], d_in.instr[20], d_in.instr[30:21], 1'b0};
assign rs1 = d_in.instr[19:15];
assign rs2 = d_in.instr[24:20];
assign rd = d_in.instr[11:7];

load_funct3_t load_funct3;
store_funct3_t store_funct3;
branch_funct3_t branch_funct3;
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);

// Glue signals
rv32i_word vj_o, vk_o;
logic [2:0] qj_o, qk_o;
assign rs1_o = rs1;
assign rs2_o = rs2;

always_comb begin
    // if source register is not reg0, and if ROB has the value for the
    // source register, use that value for the source operand, otherwise
    // use the value from the regfile.
    if (regfile_entry_i.qj_out != 0 && rob_in[regfile_entry_i.qj_out].reg_data.can_commit) begin
        vj_o = rob_in[regfile_entry_i.qj_out].reg_data.value;
        qj_o = 3'b000;
    end else begin
        vj_o = regfile_entry_i.vj_out;
        qj_o = regfile_entry_i.qj_out;
    end

    if (regfile_entry_i.qk_out != 0 && rob_in[regfile_entry_i.qk_out].reg_data.can_commit) begin
        vk_o = rob_in[regfile_entry_i.qk_out].reg_data.value;
        qk_o = 3'b000;
    end else begin
        vk_o = regfile_entry_i.vk_out;
        qk_o = regfile_entry_i.qk_out;
    end
end

// Decode + Issue
always_ff @ (posedge clk) begin
    if(rd == 8)
        $displayh("rd is 8, d_in is %p, opcode is %p", d_in, opcode);
    if (rst || flush) begin
        rob_write <= 1'b0;
        pc_and_rd.instr_pc <= 32'd0;
        pc_and_rd.opcode <= rv32i_opcode'(opcode);
        pc_and_rd.rd <= '0;
        // alu_o.valid <= 1'b0;
        alu_o <= '0;
        cmp_o <= '0;
        lsb_o <= '0;
    end else begin
        rob_write <= 1'b0;
        pc_and_rd.instr_pc <= 32'd0;
        pc_and_rd.opcode <= rv32i_opcode'(opcode);
        pc_and_rd.rd <= '0;
        alu_o.valid <= 1'b0;
        cmp_o.valid <= 1'b0;
        lsb_o.valid <= 1'b0;
        case (opcode)
            op_lui : begin
                if (rd != 0 && alu_rs_full == 0 && rob_free_tag != 0) begin
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= rd;
                    rob_write <= 1'b1;
                    alu_o.valid <= 1'b1;
                    alu_o.rs1.value <= 32'd0;
                    alu_o.rs2.value <= u_imm;
                    alu_o.rs1.valid <= 1'b1;
                    alu_o.rs2.valid <= 1'b1;
                    alu_o.rs1.tag <= 4'd0;
                    alu_o.rs2.tag <= 4'd0;
                    alu_o.op <= alu_add;
                    alu_o.rob_idx <= rob_free_tag;
                end
            end

            op_auipc : begin // KEEP
                if (rd != 0 && alu_rs_full == 0 && rob_free_tag != 0) begin
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= rd;
                    rob_write <= 1'b1;
                    alu_o.valid <= 1'b1;
                    alu_o.rs1.value <= instr_pc;
                    alu_o.rs1.valid <= 1'b1;
                    alu_o.rs2.value <= u_imm;
                    alu_o.rs2.valid <= 1'b1;
                    alu_o.rs1.tag <= 4'd0;
                    alu_o.rs2.tag <= 4'd0;
                    alu_o.op <= alu_add;
                    alu_o.rob_idx <= rob_free_tag;
                end
            end

            op_jal : begin
                if (alu_rs_full == 0) begin
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= rd;
                    rob_write <= 1'b1;
                    alu_o.valid <= 1'b1;
                    alu_o.rs1.value <= instr_pc + 32'd4;
                    alu_o.rs1.valid <= 1'b1;
                    alu_o.rs2.value <= j_imm;
                    alu_o.rs2.valid <= 1'b1;
                    alu_o.rs1.tag <= 4'd0;
                    alu_o.rs2.tag <= 4'd0;
                    alu_o.op <= alu_add;
                    alu_o.rob_idx <= rob_free_tag;
                end
            end

            // op_jalr : begin
            //     // ????? no idea what conditions to use, CHECK
            //     if () begin

            //     end
            // end

            op_br : begin   // KEEP
                if (cmp_rs_full == 0) begin
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= 4'd0;
                    cmp_o.valid <= 1'b1;
                    cmp_o.br <= 1'b1;    // High if opcode is branch, some non-branch opcodes also use
                    cmp_o.rs1.value <= vj_o;
                    cmp_o.rs1.valid <= (qj_o == 0);
                    cmp_o.rs2.value <= vk_o;
                    cmp_o.rs2.valid <= (qk_o == 0);
                    cmp_o.rs1.tag <= qj_o;
                    cmp_o.rs2.tag <= qk_o;
                    cmp_o.pc <= instr_pc;
                    cmp_o.b_imm <= b_imm;
                    cmp_o.op <= branch_funct3;
                    cmp_o.rob_idx <= rob_free_tag;
                    rob_write <= 1'b1;
                end
            end

            op_load : begin // KEEP
                if (rd != 0 && (lsb_full == 0)) begin
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= rd;
                    lsb_o.vj <= vj_o;
                    lsb_o.valid <= 1'b1;
                    lsb_o.vk <= 32'd0;
                    lsb_o.qj <= qj_o;
                    lsb_o.qk <= 32'd0;
                    lsb_o.addr <= i_imm;
                    lsb_o.type_of_inst <= 1'b0;  // 0 = load, 1 = store
                    lsb_o.funct <= load_funct3;
                    lsb_o.tag <= rob_free_tag;
                    lsb_o.type_of_inst <= 1'b0;
                    lsb_o.can_finish <= 1'b0;
                    rob_write <= 1'b1;
                end
            end

            op_store : begin    // KEEP
                if (lsb_full == 0) begin
                    lsb_o.valid <= 1'b1;
                    lsb_o.vj <= vj_o;
                    lsb_o.vk <= vk_o;
                    lsb_o.qj <= qj_o;
                    lsb_o.qk <= qk_o;
                    lsb_o.addr <= s_imm;
                    lsb_o.type_of_inst <= 1'b1;  // 0 = load, 1 = store
                    lsb_o.funct <= store_funct3;
                    lsb_o.tag <= rob_free_tag;
                    lsb_o.type_of_inst <= 1'b1;
                    lsb_o.can_finish <= 1'b0;
                    rob_write <= 1'b1;
                end
            end

            op_imm : begin
                if (rd != 0 && rob_free_tag != 0) begin
                    // MAY NEED TO SEND INSTRUCTION TYPE TO ROB...
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= rd;
                    case (funct3)
                        slt : begin
                            if (cmp_rs_full == 0) begin
                                cmp_o.valid <= 1'b1;
                                cmp_o.br <= 1'b0;    // High if opcode is branch, some non-branch opcodes also use
                                cmp_o.rs1.value <= vj_o;
                                cmp_o.rs1.valid <= (qj_o == 0);
                                cmp_o.rs2.value <= i_imm;
                                cmp_o.rs2.valid <= 1'b1;
                                cmp_o.rs1.tag <= qj_o;
                                cmp_o.rs2.tag <= 4'd0;
                                cmp_o.pc <= instr_pc;
                                cmp_o.b_imm <= 32'd0;
                                cmp_o.op <= branch_funct3;
                                cmp_o.rob_idx <= rob_free_tag;
                                rob_write <= 1'b1;
                            end
                        end

                        sltu : begin
                            if (cmp_rs_full == 0) begin
                                cmp_o.valid <= 1'b1;
                                cmp_o.br <= 1'b0;    // High if opcode is branch, some non-branch opcodes also use
                                cmp_o.rs1.value <= vj_o;
                                cmp_o.rs1.valid <= (qj_o == 0);
                                cmp_o.rs2.value <= i_imm;
                                cmp_o.rs2.valid <= 1'b1;
                                cmp_o.rs1.tag <= qj_o;
                                cmp_o.rs2.tag <= 4'd0;
                                cmp_o.pc <= instr_pc;
                                cmp_o.b_imm <= 32'd0;
                                cmp_o.op <= branch_funct3;
                                cmp_o.rob_idx <= rob_free_tag;
                                rob_write <= 1'b1;
                            end
                        end

                        sr : begin
                            if (alu_rs_full == 0) begin
                                case (funct7[5])
                                    1'b0 : begin // srli
                                        alu_o.valid <= 1'b1;
                                        alu_o.rs1.value <= vj_o;
                                        alu_o.rs1.valid <= (qj_o == 0);
                                        alu_o.rs2.value <= i_imm;
                                        alu_o.rs2.valid <= 1'b1;
                                        alu_o.rs1.tag <= qj_o;
                                        alu_o.rs2.tag <= 32'b0;
                                        alu_o.op <= alu_srl;
                                        alu_o.rob_idx <= rob_free_tag;
                                        rob_write <= 1'b1;
                                    end

                                    1'b1 : begin // srai
                                        alu_o.valid <= 1'b1;
                                        alu_o.rs1.value <= vj_o;
                                        alu_o.rs1.valid <= (qj_o == 0);
                                        alu_o.rs2.value <= i_imm;
                                        alu_o.rs2.valid <= 1'b1;
                                        alu_o.rs1.tag <= qj_o;
                                        alu_o.rs2.tag <= 32'b0;
                                        alu_o.op <= alu_sra;
                                        alu_o.rob_idx <= rob_free_tag;
                                        rob_write <= 1'b1;
                                    end
                                    default : ;
                                endcase
                            end
                        end

                        default : begin  // add, sll, axor, aor, aand
                            if (alu_rs_full == 0) begin
                                alu_o.valid <= 1'b1;
                                alu_o.rs1.value <= vj_o;
                                alu_o.rs1.valid <= (qj_o == 0);
                                alu_o.rs2.value <= i_imm;
                                alu_o.rs2.valid <= 1'b1;
                                alu_o.rs1.tag <= qj_o;
                                alu_o.rs2.tag <= 32'b0;
                                alu_o.op <= alu_ops'(funct3);
                                alu_o.rob_idx <= rob_free_tag;
                                rob_write <= 1'b1;
                            end
                        end
                    endcase
                end
            end

            op_reg : begin
                if (rd != 0 && rob_free_tag != 0) begin
                    pc_and_rd.instr_pc <= instr_pc;
                    pc_and_rd.opcode <= rv32i_opcode'(opcode);
                    pc_and_rd.rd <= rd;
                    case (arith_funct3_t'(funct3))
                        add : begin
                            if (alu_rs_full == 0) begin
                                case (funct7[5])
                                    1'b0: begin
                                        alu_o.valid <= 1'b1;
                                        alu_o.rs1.value <= vj_o;
                                        alu_o.rs1.valid <= (qj_o == 0);
                                        alu_o.rs2.value <= vk_o;
                                        alu_o.rs2.valid <= (qk_o == 0);
                                        alu_o.rs1.tag <= qj_o;
                                        alu_o.rs2.tag <= qk_o;
                                        alu_o.op <= alu_add;
                                        alu_o.rob_idx <= rob_free_tag;
                                        rob_write <= 1'b1;
                                    end

                                    1'b1: begin
                                        alu_o.valid <= 1'b1;
                                        alu_o.rs1.value <= vj_o;
                                        alu_o.rs1.valid <= (qj_o == 0);
                                        alu_o.rs2.value <= vk_o;
                                        alu_o.rs2.valid <= (qk_o == 0);
                                        alu_o.rs1.tag <= qj_o;
                                        alu_o.rs2.tag <= qk_o;
                                        alu_o.op <= alu_sub;
                                        alu_o.rob_idx <= rob_free_tag;
                                        rob_write <= 1'b1;
                                    end
                                    default : ;
                                endcase
                            end
                        end

                        slt : begin
                            if (cmp_rs_full == 0) begin
                                cmp_o.valid <= 1'b1;
                                cmp_o.br <= 1'b0;    // High if opcode is branch, some non-branch opcodes also use
                                cmp_o.rs1.value <= vj_o;
                                cmp_o.rs1.valid <= (qj_o == 0);
                                cmp_o.rs2.value <= vk_o;
                                cmp_o.rs2.valid <= (qk_o == 0);
                                cmp_o.rs1.tag <= qj_o;
                                cmp_o.rs2.tag <= qk_o;
                                cmp_o.pc <= instr_pc;
                                cmp_o.b_imm <= 32'd0;
                                cmp_o.op <= branch_funct3;
                                cmp_o.rob_idx <= rob_free_tag;
                                rob_write <= 1'b1;
                            end
                        end

                        sltu : begin
                            if (cmp_rs_full == 0) begin
                                cmp_o.valid <= 1'b1;
                                cmp_o.br <= 1'b0;
                                cmp_o.rs1.value <= vj_o;
                                cmp_o.rs1.valid <= (qj_o == 0);
                                cmp_o.rs2.value <= vk_o;
                                cmp_o.rs2.valid <= (qk_o == 0);
                                cmp_o.rs1.tag <= qj_o;
                                cmp_o.rs2.tag <= qk_o;
                                cmp_o.pc <= instr_pc;
                                cmp_o.b_imm <= 32'd0;
                                cmp_o.op <= branch_funct3;
                                cmp_o.rob_idx <= rob_free_tag;
                                rob_write <= 1'b1;
                            end
                        end

                        sr : begin
                            if (alu_rs_full == 0) begin
                                case (funct7[5])
                                    1'b0 : begin // srl
                                        alu_o.valid <= 1'b1;
                                        alu_o.rs1.value <= vj_o;
                                        alu_o.rs1.valid <= (qj_o == 0);
                                        alu_o.rs2.value <= vk_o;
                                        alu_o.rs2.valid <= (qk_o == 0);
                                        alu_o.rs1.tag <= qj_o;
                                        alu_o.rs2.tag <= qk_o;
                                        alu_o.op <= alu_srl;
                                        alu_o.rob_idx <= rob_free_tag;
                                        rob_write <= 1'b1;
                                    end

                                    1'b1 : begin // sra
                                        alu_o.valid <= 1'b1;
                                        alu_o.rs1.value <= vj_o;
                                        alu_o.rs1.valid <= (qj_o == 0);
                                        alu_o.rs2.value <= vk_o;
                                        alu_o.rs2.valid <= (qk_o == 0);
                                        alu_o.rs1.tag <= qj_o;
                                        alu_o.rs2.tag <= qk_o;
                                        alu_o.op <= alu_sra;
                                        alu_o.rob_idx <= rob_free_tag;
                                        rob_write <= 1'b1;
                                    end
                                    default : ;
                                endcase
                            end
                        end

                        default : begin  // sll, axor, aor, aand
                            if (alu_rs_full == 0) begin
                                alu_o.valid <= 1'b1;
                                alu_o.rs1.value <= vj_o;
                                alu_o.rs2.value <= vk_o;
                                alu_o.rs1.valid <= (qj_o == 0);
                                alu_o.rs2.valid <= (qk_o == 0);
                                alu_o.rs1.tag <= qj_o;
                                alu_o.rs2.tag <= qk_o;
                                alu_o.op <= alu_ops'(funct3);
                                alu_o.rob_idx <= rob_free_tag;
                                rob_write <= 1'b1;
                            end
                        end
                    endcase
                end
            end
            default : ;
        endcase
    end
end

// Let iQueue know we want new values
always_ff @(posedge clk) begin
   if (rst || flush) begin
        i_queue_read <= 1'b0;
        rd_o <= rd;
        load_tag <= 1'b0;
        tag <= '0;
    end else if (rob_is_full == 1'b1 || lsb_almost_full == 1'b1 || lsb_full == 1'b1 /*|| i_queue_empty == 1'b1*/) begin
        i_queue_read <= 1'b0;
    end else begin
        i_queue_read <= 1'b0;
        rd_o <= rd;
        load_tag <= 1'b0;
        tag <= '0;
        case (opcode)
            op_lui, op_auipc, op_jal : begin
                if (rd == 0)
                    i_queue_read <= 1'b1;
                else if (alu_rs_full == 0 && rob_free_tag != 0) begin
                    i_queue_read <= 1'b1;
                    rd_o <= rd;
                    load_tag <= 1'b1;
                    tag <= rob_free_tag;
                end
            end

            op_jalr : ; // ????????????????????????????????

            op_br : begin
                if (cmp_rs_full == 0 && rob_free_tag != 0)
                    i_queue_read <= 1'b1;
            end

            op_load : begin
                if (rd == 0)
                    i_queue_read <= 1'b1;
                else if ((lsb_full == 0) && rob_free_tag != 0) begin
                    i_queue_read <= 1'b1;
                    rd_o <= rd;
                    load_tag <= 1'b1;
                    tag <= rob_free_tag;
                    // $displayh("Tag=%p, rd=%p", rob_free_tag, rd);
                end
            end

            op_store : begin
                if ((lsb_full == 0 )  && rob_free_tag != 0)
                    i_queue_read <= 1'b1;
            end

            op_imm : begin
                if (rob_free_tag != 0) begin
                    if (rd == 0)
                        i_queue_read <= 1'b1;
                    else begin
                        case (funct3)
                            slt, sltu : begin
                                if (cmp_rs_full == 0) begin
                                    i_queue_read <= 1'b1;
                                    rd_o <= rd;
                                    load_tag <= 1'b1;
                                    tag <= rob_free_tag;
                                end
                            end

                            sr, add, sll, axor, aor, aand: begin
                                if (alu_rs_full == 0) begin
                                    i_queue_read <= 1'b1;
                                    rd_o <= rd;
                                    load_tag <= 1'b1;
                                    tag <= rob_free_tag;
                                end
                            end
                            default : ;
                        endcase
                    end
                end
            end

            op_reg : begin
                if (rob_free_tag != 0) begin
                    if (rd == 0)
                        i_queue_read <= 1'b1;
                    else begin
                        case (funct3)
                            slt, sltu : begin
                                if (cmp_rs_full == 0) begin
                                    i_queue_read <= 1'b1;
                                    rd_o <= rd;
                                    load_tag <= 1'b1;
                                    tag <= rob_free_tag;
                                end
                            end

                            sr, add, sll, axor, aor, aand : begin
                                if (alu_rs_full == 0) begin
                                    i_queue_read <= 1'b1;
                                    rd_o <= rd;
                                    load_tag <= 1'b1;
                                    tag <= rob_free_tag;
                                end
                            end
                            default : ;
                        endcase
                    end
                end
            end
            default : begin
                i_queue_read <= 1'b1; // this makes it fast?
            end
        endcase
    end
end

endmodule : i_decode
