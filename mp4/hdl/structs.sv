package structs;
import rv32i_types::rv32i_opcode;
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
} i_queue_data;

endpackage: structs
