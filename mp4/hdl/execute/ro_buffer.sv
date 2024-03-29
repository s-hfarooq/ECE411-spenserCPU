`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module ro_buffer (
    input logic clk,
    input logic rst,
    output logic flush,
    input logic load_rob,

    input cdb_t cdb,

    // From decoder
    input i_decode_opcode_t decoder_instr_i,

    // To decoder
    output rob_arr_t rob_arr_o,
    output logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] rob_free_tag,
    output logic full,

    // To regfile/reservation station
    output rob_values_t rob_o,
    output logic is_committing,

    // To/from load store queue
    input logic rob_store_complete,
    output logic curr_is_store,
    output logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] head_ptr,

    // Output to PC
    output logic branch_taken,
    output rv32i_word target_pc,

    input logic mem_resp,
    input logic mem_read
);

rob_arr_t rob_arr;
assign rob_arr_o = rob_arr;

// Head and tail pointers
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] tail_ptr = {$clog2(`RO_BUFFER_ENTRIES){1'b0}};
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] tail_next_ptr = {$clog2(`RO_BUFFER_ENTRIES){1'b0}};

assign curr_is_store = (rob_arr[head_ptr].op.opcode == op_store);

// Glue logic
logic [$clog2(`RO_BUFFER_ENTRIES):0] counter = 0;
assign full = (counter >= (`RO_BUFFER_ENTRIES - 3)); // TODO: may be able to set to -2

task incrementToNextInstr();
    // dont commit
    if (counter <= 0) begin
        // do nothing
    end else if (head_ptr >= (`RO_BUFFER_ENTRIES - 1)) begin
        head_ptr <= 1;
    end else begin
        head_ptr <= head_ptr + 1'b1;
    end


    if (counter <= 0) begin
        counter <= 0;
    end else if (load_rob == 1'b0) begin
        counter <= counter - 1'b1;
    end
endtask

always_ff @ (posedge clk) begin
    is_committing <= 1'b0;
    branch_taken <= 1'b0;
    target_pc <= 32'b0;
    flush <= 1'b0;

    if (rst || flush) begin
        for (int i = 0; i < `RO_BUFFER_ENTRIES; ++i)
            rob_arr[i] <= '{default: 0};

        // Entry 0 is reserved
        head_ptr <= {$clog2(`RO_BUFFER_ENTRIES){1'b0}} + 1;
        tail_ptr <= {$clog2(`RO_BUFFER_ENTRIES){1'b0}} + 1;
        tail_next_ptr <= {$clog2(`RO_BUFFER_ENTRIES){1'b0}} + 2;
        counter <= 0;
    end else begin
        // Check if we should commit head value
        if (rob_arr[head_ptr].reg_data.can_commit == 1'b1 || rob_store_complete == 1'b1) begin
            if (rob_arr[head_ptr].op.opcode == op_br) begin
                // branch prediction logic here? 
                if (rob_arr[head_ptr].reg_data.value == 1) begin
                    branch_taken <= 1'b1;
                    target_pc <= rob_arr[head_ptr].target_pc;

                    if (mem_read == 1 && mem_resp == 1) begin
                        rob_arr[head_ptr] <= '{default: 0};
                        incrementToNextInstr();
                        flush <= 1'b1;
                    end
                end else begin
                    rob_arr[head_ptr] <= '{default: 0};
                    incrementToNextInstr();
                end
            end else if (rob_arr[head_ptr].op.opcode == op_jal || rob_arr[head_ptr].op.opcode == op_jalr) begin
                // do jump
                rob_o <= rob_arr[head_ptr];
                // rob_arr[head_ptr].valid <= 4'b0;
                target_pc <= rob_arr[head_ptr].target_pc;
                is_committing <= 1'b1;

                // rob_arr[head_ptr] <= '{default: 0};
                branch_taken <= 1'b1;

                if (mem_read == 1 && mem_resp == 1) begin
                    rob_arr[head_ptr] <= '{default: 0};
                    incrementToNextInstr();
                    flush <= 1'b1;
                end

                // flush <= 1'b1;

                // if (rob_arr[head_ptr].op.opcode == op_jalr) begin
                //     flush <= 1'b1;
                //     branch_taken <= 1'b1;
                // end

                // incrementToNextInstr();
            end else begin
                // Output to regfile, dequeue
                rob_o <= rob_arr[head_ptr];
                rob_arr[head_ptr].valid <= '0;

                if (rob_store_complete == 1'b0)
                    is_committing <= 1'b1;

                rob_arr[head_ptr] <= '{default: 0};

                if (curr_is_store == 1'b0 || rob_store_complete == 1'b1)
                    incrementToNextInstr();
            end
        end 
        
        if (load_rob == 1'b1) begin
            // Save value to ROB, enqueue
            if (counter < (`RO_BUFFER_ENTRIES - 1)) begin
                rob_arr[tail_ptr].op <= decoder_instr_i;
                rob_arr[tail_ptr].tag <= tail_ptr;
                
                // wait for computation
                rob_arr[tail_ptr].valid <= 1'b1;
                rob_arr[tail_ptr].reg_data.value <= 32'b0;
                rob_arr[tail_ptr].reg_data.can_commit <= '0;

                // Entry 0 is reserved
                if (tail_ptr >= (`RO_BUFFER_ENTRIES - 1))
                    tail_ptr <= 1;
                else
                    tail_ptr <= tail_ptr + 1'b1;

                if (tail_next_ptr >= (`RO_BUFFER_ENTRIES - 1))
                    tail_next_ptr <= 1;
                else
                    tail_next_ptr <= tail_next_ptr + 1;

                if (rob_arr[head_ptr].reg_data.can_commit == 1'b0)
                    counter <= counter + 1'b1;
            end
        end
    end

    // Should be in always_comb?
    for (int i = 0; i < `NUM_CDB_ENTRIES; ++i) begin
        // check for tag match
        for (int j = 0; j < `RO_BUFFER_ENTRIES; ++j) begin
            if (rob_arr[j].reg_data.can_commit == 1'b0 && rob_arr[j] && rob_arr[j].tag == cdb[i].tag) begin
                rob_arr[cdb[i].tag].reg_data.value <= cdb[i].value;
                rob_arr[cdb[i].tag].target_pc <= cdb[i].target_pc;
                rob_arr[cdb[i].tag].reg_data.can_commit <= 1'b1;
            end
        end
    end
end

// rob_free_tag needed for decode
always_comb begin
    case (load_rob)
        1'b0 : rob_free_tag = (rob_arr[tail_ptr].valid == 1) ? '0 : tail_ptr;
        1'b1 : rob_free_tag = (rob_arr[tail_next_ptr].valid == 1) ? '0 : tail_next_ptr;
        default : ;
    endcase
end

endmodule : ro_buffer
