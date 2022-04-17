`include "macros.sv"

package structs;
import rv32i_types::*;

typedef logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] tag_t;

typedef struct packed {
    logic type_of_inst; // 0 = load, 1 = store
    rv32i_word vj;
    rv32i_word vk;
    tag_t qj;
    tag_t qk;
    rv32i_word addr;
    // logic op; // Renamed as type_of_inst
    logic [2:0] funct;
    tag_t tag;
    logic valid;
    logic can_finish;
} lsb_t;

typedef struct packed {
    rv32i_word pc;
    rv32i_word next_pc;
    rv32i_word instr;
} i_queue_data_t;

typedef struct packed {
    rv32i_word instr_pc;
    // logic [2:0] funct3;
    // logic [6:0] funct7;
    rv32i_opcode opcode;
    // rv32i_word i_imm;
    // rv32i_word s_imm;
    // rv32i_word b_imm;
    // rv32i_word u_imm;
    // rv32i_word j_imm;
    // rv32i_reg rs1;
    // rv32i_reg rs2;
    rv32i_reg rd;
} i_decode_opcode_t;

typedef struct packed {
    rv32i_word value;
    logic can_commit;
} rob_reg_data_t;

typedef struct packed {
    tag_t tag;
    // logic busy;        // do we need this?
    // logic can_commit;
    logic valid;
    i_decode_opcode_t op;

    // rv32i_word value;
    rob_reg_data_t reg_data;
} rob_values_t;

typedef struct packed {
    logic valid;
    // logic [$clog2(RO_BUFFER_ENTRIES)-1:0] idx;
    rv32i_word value;
    tag_t tag;
} rs_reg_t;

// passing data in and out of the reservation station
typedef struct packed {
    logic valid; // ready to commit
    logic busy;
    rv32i_opcode opcode;
    alu_ops alu_op;
    branch_funct3_t cmp_op;
    rs_reg_t rs1;
    rs_reg_t rs2;
    rs_reg_t res;
    // logic [ALU_RS_SIZE-1:0] idx;
} rs_data_t;

// for doing internal calculations in the alu reservation station
typedef struct packed { // when alu_rs needs to send data to the alu, it uses this struct
    logic valid;
    rs_reg_t rs1;
    rs_reg_t rs2;
    rs_reg_t res;
    // rv32i_word vj;
    // rv32i_word vk;
    // rv32i_word qj;
    // rv32i_word qk;
    // rv32i_word result;
    alu_ops op;
    tag_t rob_idx;
} alu_rs_t;

typedef struct packed { // when alu_rs needs to send data to the alu, it uses this struct
    logic valid;
    logic br;   // high if opcode is a branch, some non-branch opcodes also use cmp
    rv32i_word vj;
    rv32i_word vk;
    rv32i_word qj;
    rv32i_word qk;
    rv32i_word pc;
    rv32i_word b_imm;
    rv32i_word result;
    branch_funct3_t op;
    tag_t rob_idx;
} cmp_rs_t;

typedef struct packed {
    rv32i_word vj_out;
    rv32i_word vk_out;
    tag_t qi_out;
    tag_t qj_out;
    tag_t qk_out;
} regfile_data_out_t;

typedef struct packed {
    rv32i_word value;
    tag_t tag;
} cdb_entry_t;

typedef cdb_entry_t[`NUM_CDB_ENTRIES-1:0] cdb_t;
typedef rob_values_t[(`RO_BUFFER_ENTRIES)-1:0] rob_arr_t;

endpackage : structs
