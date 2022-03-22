/*
I-Queue entry bit field:
    PC
    Next PC
    Instruction
*/
import rv32i_types::*;

module instruction_queue #(
    parameter entries = 8
)
(
    // Inputs
    input logic clk,
    input logic rst,
    input logic flush,
    input logic shift,
    input logic load,
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
logic [95:0] entry [entries-1:0];
logic [$clog2(entries + 1):0] tail_ptr = $clog2(entries + 1)'b0;

assign empty = tail_ptr == 0;
assign full = tail_ptr == entries;

always_ff @ (posedge clk) begin
    if (rst || flush) begin
        for (int i = 0; i < entries; ++i)
            entry[i] <= 96'b0;

        tail_ptr <= $clog2(entries + 1)'b0;
    end else begin
        case({shift, load})
            00: ; // do nothing
            01: begin
                entry[tail_ptr] <= {pc_in, next_pc_in, instr_in};
                tail_ptr <= tail_ptr + 1;
            end
            10: begin
                {pc_out, next_pc_out, instr_out} <= entry[0];
                for (int i = 0; i < entries - 1; ++i)
                    entry[i] <= entry[i + 1];
                entry[tail_ptr - 1] <= 96'b0;
                tail_ptr <= tail_ptr - 1;
            end
            11: begin
                {pc_out, next_pc_out, instr_out} <= entry[0];
                for (int i = 0; i < entries - 1; ++i)
                    entry[i] <= entry[i + 1];
                entry[tail_ptr] <= {pc_in, next_pc_in, instr_in};
            end
        endcase
    end
end

endmodule : instruction_queue
