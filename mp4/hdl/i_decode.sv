include rv32i_types::*;
include structs::*;

module i_decode(
    input clk,
    input rst,
    input load,
    input i_queue_data_t d_in,
    output i_decode_opcode_t op,
);

logic [31:0] in;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode,
logic [31:0] i_imm;
logic [31:0] s_imm;
logic [31:0] b_imm;
logic [31:0] u_imm;
logic [31:0] j_imm;
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
assign in = d_in.instr;
i_interpreter interpreter(.*);

always_comb begin: type_decode
    unique case (rv32i_opcode'(d_in.instr[6:0])) // afraid of an always_latch here
        op_lui: begin 
            op.instr_type = lui;
        end
        op_auipc: begin 
             op.instr_type = auipc
        end
        op_imm: begin 
            unique case (arith_funct3_t(funct3)) 

            endcase
        end
        op_jal: begin 

        end // TODO ?????
        op_jalr: begin 

        end // TODO ????
        op_reg: begin 

        end
        op_load: begin 

        end 
        op_store: begin 

        end
        op_csr: begin 

        end // not implemented
        op_br: begin 

        end
        default: begin 

        end
    endcase
end


always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    
    unique case (rv32i_opcode'(d_in.instr[6:0]))
        op_br: begin
            unique case (branch_funct3'(funct3))
                beq: begin
                end
                bne: begin
                end
                blt: begin
                end
                bge: begin
                end
                bltu: begin
                end
                bgeu: begin
                end
            endcase
        end

        op_load: begin
            unique case (load_funct3_t'(funct3))
                lb: begin
                end
                lh: begin
                end
                lw: begin
                end
                lbu: begin
                end
                lhu: begin
                end
            endcase
        end
        
        op_store: begin
            unique case (store_funct3_t'(funct3))
                sb: begin
                end
                sh: begin
                end
                sw: begin
                end
            endcase
        end

        op_arith: begin
            unique case (arith_funct3_t'(funct3))
                add: begin
                end
                addi: begin
                end
                sub: begin
                end
                sll: begin
                end
                slli: begin
                end
                slt: begin
                end
                slti: begin
                end
                sltiu: begin
                end
                sltu: begin
                end
                xor: begin
                end
                xori: begin
                end
                sra: begin
                end
                srai: begin
                end
                srl: begin
                end
                srli: begin
                end
                or: begin
                end
                ori: begin
                end
                and: begin
                end
                andi: begin
                end
            endcase
        end
        
        op_imm: begin 
            op.imm_val = i_imm;
            unique case (arith_funct3'(funct3))
                slt  : begin 
                    op.instr_type = slt;
                end
                sltu : begin 
                    op.instr_type = sltu;
                end
                sr   : begin 
                    case (funct7[5])
                        1'b0:   op.instr_type = srli; // srl
                        1'b1:   op.instr_type = srai;// sra
                    endcase
                end
                default: begin
                    // TODO
                end

                
                
                
                
                lui: begin
                end
                auipc: begin
                end
                jal: begin
                end
                jal: begin
                end


            endcase
        end
        LUI: begin 
            loadRegfile(regfilemux::u_imm);
            loadPC(pcmux::pc_plus4);   
        end
        CALC_ADDR: begin 
            loadMAR(marmux::alu_out);
            
            unique case (opcode)
                op_load  : setALU(alumux::rs1_out, alumux::i_imm,  1'b1,  alu_add);
                op_store : begin
                    load_data_out = 1'b1;
                    setALU(alumux::rs1_out, alumux::s_imm,  1'b1,  alu_add);
                end
                default  : ;
            endcase
        end
        LD_1: begin 
            loadMDR();
            mem_read = 1'b1;
            // mem_byte_enable = rmask;
        end
        LD_2: begin 
            loadPC(pcmux::pc_plus4);
            case (load_funct3) 
                lb : loadRegfile(regfilemux::lb);
                lh : loadRegfile(regfilemux::lh);
                lw : loadRegfile(regfilemux::lw);
                lbu: loadRegfile(regfilemux::lbu);
                lhu: loadRegfile(regfilemux::lhu);
                default: ;
            endcase
        end
        ST_1: begin 
            mem_write = 1'b1;
            mem_byte_enable = wmask;
        end
        ST_2: begin 
            loadPC(pcmux::pc_plus4);
        end
        BR: begin 
            setCMP(cmpmux::rs2_out, branch_funct3);
            setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
            loadPC(pcmux::pcmux_sel_t'(br_en)); // if br = 1, then alu_out. else, plus4
        end
        AUIPC: begin 
            setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_add);
            loadRegfile(regfilemux::alu_out);
            loadPC(pcmux::pc_plus4);
        end
        J: begin
            case (opcode)
                op_jal: begin
                    setALU(alumux::pc_out, alumux::j_imm, 1'b1, alu_add);
                    loadRegfile(regfilemux::pc_plus4);
                    loadPC(pcmux::alu_out);
                end
                op_jalr: begin
                    setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
                    loadRegfile(regfilemux::pc_plus4);
                    loadPC(pcmux::alu_mod2);
                end
                default: ;
            endcase
        end
        REG: begin
            loadPC(pcmux::pc_plus4);
            unique case (arith_funct3)
                slt  : begin 
                    loadRegfile(regfilemux::br_en);
                    setCMP(cmpmux::rs2_out, blt);
                end
                sltu : begin 
                    loadRegfile(regfilemux::br_en);
                    setCMP(cmpmux::rs2_out, bltu);
                end
                sr   : begin 
                    loadRegfile(regfilemux::alu_out);
                    // determine if srl or sra
                    case (funct7[5])
                        1'b0:   setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_srl); // srl
                        1'b1:   setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sra); // sra
                    endcase
                end
                add: begin
                    loadRegfile(regfilemux::alu_out);  
                    case (funct7[5])
                        1'b0:   setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_add);
                        1'b1:   setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sub);
                    endcase
                end
                default: begin
                    setALU(alumux::rs1_out, alumux::rs2_out,  1'b1, alu_ops'(funct3));
                    loadRegfile(regfilemux::alu_out);   
                end
            endcase
        end
        default: ;
    endcase
end


endmodule