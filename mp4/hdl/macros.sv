// issue - if we define multiple of the same module, we can't have different sizes for each
package macros;

// array.sv
`DEFINE ARRAY_S_INDEX 3
`DEFINE ARRAY_WIDTH 1

// i_queue.sv
`DEFINE I_QUEUE_ENRTRIES 8

// pc_reg.sv
`DEFINE PC_REGISTER_WIDTH 32

// reg.sv
`DEFINE REGISTER_WIDTH 32

// alu_reservation_station.sv
`DEFINE ALU_RS_SIZE 4

// ro_buffer.sv
`DEFINE RO_BUFFER_ENTRIES 8

// i_decode.sv
`DEFINE EMPTY_REG 32'b0;

endpackage : macros
