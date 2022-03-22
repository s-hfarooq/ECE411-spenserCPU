package structs;

typedef struct packed {
    logic [3:0] rob_tag,
    logic busy,
    rv32i_word effective_addr,
    rv32i_word dest
} ldst_data_t;

endpackage: structs
