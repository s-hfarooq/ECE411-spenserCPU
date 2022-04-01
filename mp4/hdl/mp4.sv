import rv32i_types::*;
import structs::*;

module mp4 (
    input logic clk,
    input logic rst,
    input rv32i_word mem_rdata,
    input rv32i_word mem_addr,
    input logic mem_resp,
    output logic mem_read,
    output logic mem_write,
    output rv32i_word mem_wdata,
    
    // I-Cache signals
    output logic inst_read,
    output rv32i_word inst_addr, // WHERE DOES THIS CONNECT TO???
    input logic inst_resp,
    input rv32i_word inst_rdata,    // 32-bit instruction

    // Testing
    output rv32i_word i_queue_o 
);


// module cache (
//   input clk,

//   /* Physical memory signals */
//   input logic pmem_resp,
//   input logic [255:0] pmem_rdata,
//   output logic [31:0] pmem_address,
//   output logic [255:0] pmem_wdata,
//   output logic pmem_read,
//   output logic pmem_write,

//   /* CPU memory signals */
//   input logic mem_read,
//   input logic mem_write,
//   input logic [3:0] mem_byte_enable_cpu,
//   input logic [31:0] mem_address,
//   input logic [31:0] mem_wdata_cpu,
//   output logic mem_resp,
//   output logic [31:0] mem_rdata_cpu
// );
cache i_cache(
    .clk(clk),
    .pmem_resp(),
    .pmem_rdata(),
    .pmem_address(),
    .pmem_wdata(),
    .pmem_read(),
    .pmem_write(),
    .mem_read(),
    .mem_write(),
    .mem_byte_enable_cpu(),
    .mem_address(),
    .mem_wdata_cpu(),
    .mem_resp(),
    .mem_rdata_cpu()
);

i_fetch i_fetch(
    .clk(clk),
    .rst(rst),
    .mem_resp(inst_resp),
    .mem_rdata(inst_rdata), // 32-bit instruction input
    .i_queue_data_out(),
    .mem_read(inst_read),
    .mem_write(mem_write)
);

endmodule : mp4
