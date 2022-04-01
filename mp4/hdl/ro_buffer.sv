import rv32i_types::*;
import structs::*;

module reorder_buffer #(
    parameter entries = 8
)
(
    input logic clk,
    input logic rst,
    input logic read,

    // From decoder
    input rv32i_reg rd,
    input rv32i_word value,
    input logic [1:0] op_type,    // math, jump, load, store


);

// still need tag
rob_values_t rob_arr [entries - 1:0];


// register, busy, tag, data columns



endmodule : reorder_buffer
