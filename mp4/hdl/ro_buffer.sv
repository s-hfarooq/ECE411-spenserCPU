import rv32i_types::*;
import structs::*;

module reorder_buffer #(
    parameter entries = 8
)
(
    input logic clk,
    input logic rst,
    input logic flush,
    input logic read,
    input logic write,

    // From decoder
    input i_decode_opcode_t input_i,
    input rv32i_word instr_pc_in,

    // From reservation station
    input rv32i_word value_in_reg,

    // To decoder
    output rv32i_word reg_val_o,
    output rv32i_reg reg_o,
    output logic empty,
    output logic full,

    // To regfile/reservation station
    output rob_values_t rob_o,
    output logic is_commting
);

// need to fix entry_num size
rob_values_t rob_arr [entries-1:0];

// Head and tail pointers
logic [$clog2(entries)-1:0] head_ptr = {$clog2(entries){1'b0}};
logic [$clog2(entries)-1:0] tail_ptr = {$clog2(entries){1'b0}};

// Glue logic
logic [$clog2(entries):0] counter = 0;
assign empty = (counter == 0);
assign full = (counter == entries);

always_ff @ (posedge clk) begin
    is_commiting <= 1'b0;

    if(rst || flush) begin
        for (int i = 0; i < entries; ++i) begin
            rob_arr[i] <= '{default: 0};
        end

        counter <= 0;
        head_ptr <= {$clog2(entries){1'b0}};
        tail_ptr <= {$clog2(entries){1'b0}};
    end else begin
        // Check if we should commit head value
        if (rob_arr[head_ptr].reg_data.can_commit == 1'b1) begin
            // Output to regfile, dequeue
            rob_o <= rob_arr[head_ptr];
            head_ptr <= head_ptr + 1'b1;
            is_commting <= 1'b1;
            counter <= counter - 1'b1;
        end else if (read == 1'b1) begin
            // Output to reservation station, dequeue
            output_rob <= rob_arr[head_ptr];
            head_ptr <= head_ptr + 1'b1;
        end else if (write == 1'b1) begin
            // Save value to ROB, enqueue
            if (counter < entries) begin
                rob_arr[tail_ptr].op <= input_i;
                rob_arr[tail_ptr].entry_num <= counter;
                rob_arr[tail_ptr].can_commit <= 1'b0;
                rob_arr[tail_ptr].valid <= 1'b1;
                rob_arr[tail_ptr].reg_data.value <= value_in_reg;
                rob_arr[tail_ptr].op.instr_pc <= instr_pc_in;

                tail_ptr <= tail_ptr + 1'b1;
                counter <= counter + 1'b1;
            end
        end
    end
end

endmodule : reorder_buffer
