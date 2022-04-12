// issue - if we define multiple of the same module, we can't have different sizes for each

// array.sv
`define ARRAY_S_INDEX 3
`define ARRAY_WIDTH 1

// i_queue.sv
`define I_QUEUE_ENRTRIES 8

// pc_reg.sv
`define PC_REGISTER_WIDTH 32

// reg.sv
`define REGISTER_WIDTH 32

// alu_reservation_station.sv
`define ALU_RS_SIZE 4

// cmp_reservation_station.sv
`define CMP_RS_SIZE 4

// alu_reservation_station.sv
`define LDST_SIZE 4

// ro_buffer.sv
// 8 + 1 because entry 0 is reserved
`define RO_BUFFER_ENTRIES 9 

// i_decode.sv
`define EMPTY_REG 32'b0

`define NUM_CDB_ENTRIES 1
