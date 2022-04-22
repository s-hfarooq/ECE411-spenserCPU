`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module ro_buffer (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic write,

    input cdb_t cdb,

    // From decoder
    input i_decode_opcode_t input_i,
    // input rv32i_word instr_pc_in,

    // To decoder
    output rob_arr_t rob_arr_o,
    output logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] rob_free_tag,
    output logic empty,
    output logic full,

    // To regfile/reservation station
    output rob_values_t rob_o,
    output logic is_committing,

    // To/from load store queue
    input logic rob_store_complete,
    output logic curr_is_store,
    output logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] head_tag,

    // Output to PC
    output logic pcmux_sel,
    output rv32i_word target_pc
);

rob_arr_t rob_arr;
assign rob_arr_o = rob_arr;

// Set outputs to decoder equal to the ROB data
// always_comb begin
//     for (int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
//         for (int j = 0; j < `RO_BUFFER_ENTRIES; ++j) begin
//             if(rob_arr[i].valid == 1'b1) begin // entry is being used in rob
//                 rob_arr_o[i] = rob_arr[j];
//             end else begin
//                 rob_arr_o.reg_data.can_commit = 1'b0;
//             end
//         end
//     end
// end

// Head and tail pointers
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] head_ptr = {$clog2(`RO_BUFFER_ENTRIES){1'b0}};
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] tail_ptr = {$clog2(`RO_BUFFER_ENTRIES){1'b0}};
logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] tail_next_ptr = {$clog2(`RO_BUFFER_ENTRIES){1'b0}};

assign curr_is_store = (input_i.opcode == op_store);
assign head_tag = head_ptr;

// Glue logic
logic [$clog2(`RO_BUFFER_ENTRIES):0] counter = 0;
assign empty = (counter == 0);
assign full = (counter >= (`RO_BUFFER_ENTRIES - 3)); // TODO: may be able to set to -2

task incrementToNextInstr();
    // dont commit
    if(counter <= 0) begin
        // do nothing
    end else if(head_ptr >= (`RO_BUFFER_ENTRIES - 1)) begin
        head_ptr <= 1;
    end else begin
        head_ptr <= head_ptr + 1'b1;
    end


    if(counter <= 0) begin
        // tail_ptr <= tail_ptr;
        counter <= 0;
    end else if(write == 1'b0) begin
        counter <= counter - 1'b1;
    end
endtask

always_ff @ (posedge clk) begin
    is_committing <= 1'b0;

    if(input_i.rd == 8)
        $display("rd 8 exists out");

    if(rst || flush) begin
        for (int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
            rob_arr[i] <= '{default: 0};
        end

        counter <= 0;

        // Entry 0 is reserved
        head_ptr <= {$clog2(`RO_BUFFER_ENTRIES){1'b0}} + 1;
        tail_ptr <= {$clog2(`RO_BUFFER_ENTRIES){1'b0}} + 1;
        tail_next_ptr <= {$clog2(`RO_BUFFER_ENTRIES){1'b0}} + 2;
    end else begin
        // Check if we should commit head value
        if (rob_arr[head_ptr].reg_data.can_commit == 1'b1) begin
            // if (rob_arr[head_ptr].op.opcode == op_br) begin
            //     pcmux_sel <= 
            // end
            // if (rob_arr[head_ptr].op.opcode == op_br) begin
            //     pcmux_sel = 1'b1;
            //     target_pc = rob_arr[head_ptr].target_pc;
            // end else begin
            //     pcmux_sel = 1'b0;
            //     target_pc = 32'd0;
            // end

            if(rob_arr[head_ptr].op.opcode == op_br) begin
                rob_arr[head_ptr] <= '{default: 0};
                incrementToNextInstr();
            end else begin
                // Output to regfile, dequeue
                rob_o <= rob_arr[head_ptr];
                rob_arr[head_ptr].valid <= 4'b0;
                is_committing <= 1'b1;

                // rob_arr[head_ptr].reg_data.can_commit <= 1'b0;
                rob_arr[head_ptr] <= '{default: 0};

                if(curr_is_store == 1'b0 || rob_store_complete == 1'b1) begin
                    incrementToNextInstr();
                end
            end
        end 
        
        if (write == 1'b1) begin
            // Save value to ROB, enqueue
            if(input_i.rd == 8)
                $display("rd 8 exists2");
            if (counter < (`RO_BUFFER_ENTRIES - 1)) begin
                rob_arr[tail_ptr].op <= input_i;
                rob_arr[tail_ptr].tag <= tail_ptr; 
                rob_arr[tail_ptr].reg_data.can_commit <= 1'b0;

                // wait for computation
                rob_arr[tail_ptr].valid <= 1'b1;
                rob_arr[tail_ptr].reg_data.value <= 32'b0;
                // rob_arr[tail_ptr].op.instr_pc <= instr_pc_in;

                // Entry 0 is reserved
                if(tail_ptr >= (`RO_BUFFER_ENTRIES - 1))
                    tail_ptr <= 1;
                else
                    tail_ptr <= tail_ptr + 1'b1;

                if (tail_next_ptr >= (`RO_BUFFER_ENTRIES - 1))
                    tail_next_ptr <= 1;
                else
                    tail_next_ptr <= tail_next_ptr + 1;

                if(rob_arr[head_ptr].reg_data.can_commit == 1'b0)
                    counter <= counter + 1'b1;

                if(input_i.rd == 8)
                    $display("rd 8 exists");
            end
        end
    end

    // Should be in always_comb?
    for(int i = 0; i < `NUM_CDB_ENTRIES; ++i) begin
        // check for tag match
        for(int j = 0; j < `RO_BUFFER_ENTRIES; ++j) begin
            if(rob_arr[j].reg_data.can_commit == 1'b0 && rob_arr[j] && rob_arr[j].tag == cdb[i].tag) begin
                rob_arr[cdb[i].tag].reg_data.value <= cdb[i].value;
                rob_arr[cdb[i].tag].target_pc <= cdb[i].target_pc;
                rob_arr[cdb[i].tag].reg_data.can_commit <= 1'b1;
            end
        end
    end
end

always_comb begin
    if (rob_arr[head_ptr].reg_data.can_commit == 1'b1) begin
        if (rob_arr[head_ptr].op.opcode == op_br && rob_arr[head_ptr].reg_data.value == 1) begin
            pcmux_sel = 1'b1;
            target_pc = rob_arr[head_ptr].target_pc;
        end else begin
            pcmux_sel = 1'b0;
            target_pc = 32'd0;
        end
    end else begin
        pcmux_sel = 1'b0;
        target_pc = 32'd0;
    end
end

always_comb begin
    case (write)
        1'b0 : rob_free_tag = (rob_arr[tail_ptr].valid == 1) ? '0 : tail_ptr;
        1'b1 : rob_free_tag = (rob_arr[tail_next_ptr].valid == 1) ? '0 : tail_next_ptr;
        default : ;
    endcase
end

// always_comb begin : look_for_tags

//     for(int i = 0; i < `NUM_CDB_ENTRIES - 1; ++i) begin
//         // check for tag match
//         if(rob_arr[i].reg_data.can_commit == 1'b0 && rob_arr[i] && rob_arr[i].tag == cdb[i].tag) begin
//             rob_arr[cdb[i].tag].reg_data.value = cdb[i].value;
//             rob_arr[cdb[i].tag].reg_data.can_commit = 1'b1;
//         end
//     end
// end

endmodule : ro_buffer
