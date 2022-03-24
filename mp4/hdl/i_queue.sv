/*
I-Queue entry bit field:
    PC
    Next PC
    Instruction
*/

module instruction_queue #(
    parameter entries = 8
)
(
    // Inputs
    input logic clk,
    input logic rst,
    input logic flush,
    input logic read,
    input logic write,
    input logic [31:0] pc_in,
    input logic [31:0] next_pc_in,
    input logic [31:0] instr_in,
    
    // Outputs to decoder
    output logic [31:0] pc_out,
    output logic [31:0] next_pc_out,
    output logic [31:0] instr_out,
    output logic empty,
    output logic full
);

// Array of I-Queue entries
logic [95:0] entry [entries-1:0];

// Head and tail pointers
logic [$clog2(entries)-1:0] head_ptr = {$clog2(entries){1'b0}};
logic [$clog2(entries)-1:0] tail_ptr = {$clog2(entries){1'b0}};
logic [$clog2(entries)-1:0] head_ptr_next = head_ptr + 1'b1;
logic [$clog2(entries)-1:0] tail_ptr_next = tail_ptr + 1'b1;

// Glue logic
logic [2:0] counter = 0;
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
        counter <= 0;
    end else begin
        case({read, write})
            00: ; // do nothing
            01: begin
                if (counter < entries) begin
                    if (empty)
                        output_buf <= {pc_in, next_pc_in, instr_in};
                    entry[tail_ptr] <= {pc_in, next_pc_in, instr_in};
                    if (tail_ptr == (entries - 1))
                        tail_ptr <= {$clog2(entries){1'b0}};
                    else
                        tail_ptr <= tail_ptr_next;
                    counter <= counter + 1;
                end
            end
            10: begin
                if (counter > 0) begin
                    output_buf <= entry[head_ptr];
                    if (head_ptr == (entries - 1))
                        head_ptr <= {$clog2(entries){1'b0}};
                    else
                        head_ptr <= head_ptr_next;
                    counter <= counter - 1;
                end
            end
            11: begin
                /* Dequeue: If there is only one item in the queue, then
                the input data should be directly copied into the output */
                output_buf <= (head_ptr_next == tail_ptr) ?
                              {pc_in, next_pc_in, instr_in} :
                              entry[head_ptr];
                head_ptr = head_ptr_next;
                // Enqueue
                entry[tail_ptr <= {pc_in, next_pc_in, instr_in};
                tail_ptr = tail_ptr_next;
                // Not sure if this is needed
                if (tail_ptr == (entries - 1))
                        tail_ptr <= {$clog2(entries){1'b0}};
                    else
                        tail_ptr <= tail_ptr + 1;
                if (head_ptr == (entries - 1))
                        head_ptr <= {$clog2(entries){1'b0}};
                    else
                        head_ptr <= head_ptr + 1;
            end
        endcase
    end
end

endmodule : instruction_queue
