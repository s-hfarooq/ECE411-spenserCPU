/* 
    I-Queue queue bit field:
        PC
        Next PC
        Instruction
*/

`include "../macros.sv"

import rv32i_types::*;
import structs::*;

// Instruction queue
module i_queue (
    // Inputs
    input logic clk,
    input logic rst,
    input logic flush,
    input logic read,
    input logic write,
    input i_queue_data_t data_in,
    input logic mem_resp,
    
    // Outputs to decoder
    output i_queue_data_t data_out,
    output logic empty,
    output logic full
);

// Array of I-Queue entries
i_queue_data_t i_queue_arr [`I_QUEUE_ENRTRIES-1:0];

// Head and tail pointers
logic [$clog2(`I_QUEUE_ENRTRIES)-1:0] head_ptr = {$clog2(`I_QUEUE_ENRTRIES){1'b0}};
logic [$clog2(`I_QUEUE_ENRTRIES)-1:0] tail_ptr = {$clog2(`I_QUEUE_ENRTRIES){1'b0}};

// Glue logic
logic [$clog2(`I_QUEUE_ENRTRIES):0] counter = 0;
assign empty = (counter == 0);
assign full = (counter == `I_QUEUE_ENRTRIES);

always_ff @ (posedge clk) begin
    data_out <= '{default: 0};
    if (rst || flush) begin
        head_ptr <= {$clog2(`I_QUEUE_ENRTRIES){1'b0}};
        tail_ptr <= {$clog2(`I_QUEUE_ENRTRIES){1'b0}};
        data_out <= '{default: 0};
        counter <= 0;
    end else begin
        unique case({read, write})
            2'b00: ; // do nothing
            2'b01: begin // only write
                if (mem_resp == 1'b1 && counter < `I_QUEUE_ENRTRIES) begin
                    // if (empty)
                    //     data_out <= data_in;
                    i_queue_arr[tail_ptr] <= data_in;
                    tail_ptr <= tail_ptr + 1'b1;
                    counter <= counter + 1'b1;
                end
            end
            2'b10: begin // only read
                // output data if queue not empty
                if (counter != 0) begin
                    data_out <= i_queue_arr[head_ptr];
                    head_ptr <= head_ptr + 1'b1;
                    counter <= counter - 1'b1;
                end
            end
            2'b11: begin // read and write
                // Want to pass input directly to output if we 
                // don't have anything in queue already
                if (mem_resp == 1'b1) begin
                    if (counter == 0) begin
                        data_out <= data_in;
                    end else begin
                        data_out <= i_queue_arr[head_ptr];
                        head_ptr <= head_ptr + 1'b1;
                        i_queue_arr[tail_ptr] <= data_in;
                        tail_ptr <= tail_ptr + 1'b1;
                    end
                end else begin
                    // Act as if only read is high if memory hasn't yet responded
                    if (counter != 0) begin
                        data_out <= i_queue_arr[head_ptr];
                        head_ptr <= head_ptr + 1'b1;
                        counter <= counter - 1'b1;
                    end
                end
            end
            default: ;
        endcase
    end
end

endmodule : i_queue
