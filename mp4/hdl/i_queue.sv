/* 
    I-Queue queue bit field:
        PC
        Next PC
        Instruction
*/

import rv32i_types::*;

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
    input rv32i_word pc_in,
    input rv32i_word next_pc_in,
    input rv32i_word instr_in,
    
    // Outputs to decoder
    output rv32i_word pc_out,
    output rv32i_word next_pc_out,
    output rv32i_word instr_out,
    output logic empty,
    output logic full
);

// Array of I-Queue entries
logic [95:0] queue [entries-1:0];

// Head and tail pointers
logic [$clog2(entries)-1:0] head_ptr = {$clog2(entries){1'b0}};
logic [$clog2(entries)-1:0] tail_ptr = {$clog2(entries){1'b0}};
logic [$clog2(entries)-1:0] head_ptr_next;
logic [$clog2(entries)-1:0] tail_ptr_next;
assign head_ptr_next = head_ptr + 1'b1;
assign tail_ptr_next = tail_ptr + 1'b1;

// Glue logic
logic [$clog2(entries):0] counter = 0;
assign empty = (counter == 0) ? 1'b1 : 1'b0;
assign full = (counter == entries) ? 1'b1 : 1'b0;

// Output buffer
logic [95:0] output_buf;
assign pc_out = output_buf[95:64];
assign next_pc_out = output_buf[63:32];
assign instr_out = output_buf[31:0];

always_ff @ (posedge clk) begin
    if (rst || flush) begin
        head_ptr <= {$clog2(entries){1'b0}};
        tail_ptr <= {$clog2(entries){1'b0}};
        output_buf <= 96'b0;
        counter <= 0;
    end else begin
        unique case({read, write})
            2'b00: ; // do nothing
            2'b01: begin
                if (counter < entries) begin
                    if (empty)
                        output_buf <= {pc_in, next_pc_in, instr_in};
                    queue[tail_ptr] <= {pc_in, next_pc_in, instr_in};
                    tail_ptr <= tail_ptr_next;
                    counter <= counter + 1'b1;
                end
            end
            2'b10: begin
                if (counter != 0) begin
                    output_buf <= queue[head_ptr];
                    head_ptr <= head_ptr_next;
                    counter <= counter - 1'b1;
                end
            end
            2'b11: begin
                if (counter == 0)
                    // Want to pass input directly to output if we 
                    // don't have anything in queue already
                    output_buf <= {pc_in, next_pc_in, instr_in};
                else begin
                    output_buf <= queue[head_ptr];
                    head_ptr <= head_ptr_next;
                    queue[tail_ptr] <= {pc_in, next_pc_in, instr_in};
                    tail_ptr <= tail_ptr_next;
                end
            end
        endcase
    end
end

endmodule : i_queue
