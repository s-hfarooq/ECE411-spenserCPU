/* 
    I-Queue queue bit field:
        PC
        Next PC
        Instruction
*/

import rv32i_types::*;
import structs::*;

// Instruction queue
module i_queue #(
    parameter entries = 8
)
(
    // Inputs
    input logic clk,
    input logic rst,
    input logic flush,
    input logic read,
    input logic write,
    input i_queue_data data_in,
    
    // Outputs to decoder
    output i_queue_data data_out,
    output logic empty,
    output logic full
);

// Array of I-Queue entries
i_queue_data queue [entries-1:0];

// Head and tail pointers
logic [$clog2(entries)-1:0] head_ptr = {$clog2(entries){1'b0}};
logic [$clog2(entries)-1:0] tail_ptr = {$clog2(entries){1'b0}};

// Glue logic
logic [$clog2(entries):0] counter = 0;
assign empty = (counter == 0);
assign full = (counter == entries);

always_ff @ (posedge clk) begin
    if (rst || flush) begin
        head_ptr <= {$clog2(entries){1'b0}};
        tail_ptr <= {$clog2(entries){1'b0}};
        data_out <= '{default: 0};
        counter <= 0;
    end else begin
        unique case({read, write})
            2'b00: ; // do nothing
            2'b01: begin
                if (counter < entries) begin
                    if (empty)
                        data_out <= data_in;
                    queue[tail_ptr] <= data_in;
                    tail_ptr <= tail_ptr + 1'b1;
                    counter <= counter + 1'b1;
                end
            end
            2'b10: begin
                if (counter != 0) begin
                    data_out <= queue[head_ptr];
                    head_ptr <= head_ptr + 1'b1;
                    counter <= counter - 1'b1;
                end
            end
            2'b11: begin
                // Want to pass input directly to output if we 
                // don't have anything in queue already
                if (counter == 0) begin
                    data_out <= data_in;
                end else begin
                    data_out <= queue[head_ptr];
                    head_ptr <= head_ptr + 1'b1;
                    queue[tail_ptr] <= data_in;
                    tail_ptr <= tail_ptr + 1'b1;
                end
            end
        endcase
    end
end

endmodule : i_queue
