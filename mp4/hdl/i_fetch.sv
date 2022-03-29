import rv32i_types::*;
import structs::*;

module i_fetch (
    input clk,
    input rst

    input rv32i_word pc_in,

    output i_queue_data_t 
);

logic i_queue_empty, i_queue_full, i_queue_flush, i_queue_read, i_queue_write;

i_queue_data_t i_queue_data_in, i_queue_data_out;


i_queue i_queue(
    // Inputs
    .clk(clk),
    .rst(rst),
    .flush(i_queue_flush),
    .read(i_queue_read),
    .write(i_queue_write),
    .data_in(i_queue_data_in),
    
    // Outputs to decoder
    .data_out(i_queue_data_out),
    .empty(i_queue_empty),
    .full(i_queue_full)
);

endmodule : i_fetch
