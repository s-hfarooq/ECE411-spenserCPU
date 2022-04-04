package structs;
import rv32i_types::*;

typedef struct packed {
    logic [3:0] rob_tag;
    logic busy;
    rv32i_word effective_addr;
    rv32i_word dest;
} ldst_data_t;

typedef struct packed {
    logic ready;
    logic [2:0] idx;
    rv32i_word value;
} rs_reg_t;

typedef struct packed {
    logic valid; // ready to commit
    logic busy;
    rv32i_opcode opcode;
    rs_reg_t rs1;
    rs_reg_t rs2;
    rs_reg_t res;
} rs_data_t;

typedef struct packed {
    rv32i_word pc;
    rv32i_word next_pc;
    rv32i_word instr;
} i_queue_data_t;

typedef struct packed {
    // output [2:0] funct3;
    // output [6:0] funct7;
    // rv32i_opcode opcode;
    // rv32i_word i_imm;
    // rv32i_word s_imm;
    // rv32i_word b_imm;
    // rv32i_word u_imm;
    // rv32i_word j_imm;
    rv32i_reg rs1;
    rv32i_reg rs2;
    rv32i_reg rd;
    instr_t i_type;
    // instr_types_t instr_type;
    rv32i_word imm_val;
} i_decode_opcode_t;

typedef struct packed {
    rv32i_word entry_num; // needs to be parametrized
    logic busy;
    logic valid;
    i_decode_opcode_t op;

    rv32i_word value;
    rv32i_word instr_pc;
} rob_values_t;

endpackage: structs
