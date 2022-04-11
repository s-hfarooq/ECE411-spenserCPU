`include "macros.sv"

import rv32i_types::*;
import structs::*;

module load_store_queue
(
    input clk,
    input rst,
    input logic flush,
    input logic load,

    input cdb_t cdb,

    input lsb_t lsb_entry, // from ROB

    output cdb_entry_t store_res,
    output cdb_entry_t load_res,

    output logic ldst_full,

    // To/from ROB
    output logic rob_store_complete,
    input logic curr_is_store,
    input logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] head_tag,
    
    // From/to d-cache
    output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe, // mem byte enable
    output rv32i_word data_addr,
    output rv32i_word data_wdata,
    input logic data_resp,
    input rv32i_word data_rdata,
);

// Head and tail pointers
logic [$clog2(LDST_SIZE)-1:0] head_ptr = {$clog2(LDST_SIZE){1'b0}};
logic [$clog2(LDST_SIZE)-1:0] tail_ptr = {$clog2(LDST_SIZE){1'b0}};
logic [$clog2(LDST_SIZE):0] entries = 0;

lsb_t queue [LDST_SIZE-1:0];

assign ldst_full = (entries == LDST_SIZE);

always_ff @(posedge clk) begin
    if(rst || flush) begin
        for(int i = 0; i < LDST_SIZE; ++i)
            queue <= '{default: 0};
            
        head_ptr <= {$clog2(LDST_SIZE){1'b0}};
        tail_ptr <= {$clog2(LDST_SIZE){1'b0}};
        entries <= {$clog2(LDST_SIZE){1'b0}};
    end else begin
        if(load == 1'b1 && entries < LDST_SIZE) begin
            queue[tail_ptr] <= lsb_entry;
            tail_ptr <= tail_ptr + 1;
            entries <= entries + 1;
        end
    end
end
function void set_defaults()
    rob_store_complete <= 1'b0;
    data_read <= 1'b0;
    data_write <= 1'b0;
    data_mbe <= 4'b1111;
endfunction
// store rs
always_ff @(posedge clk) begin : store_rs
    set_defaults();

    if(entries > 0) begin
        case(queue[head_ptr].type)
            1'b0: begin // load
                // broadcast data received on CDB
                // calculate effective address and set tag
                load_res.value <= data_rdata;
                load_res.tag <= queue[head_ptr].qj;

                // request data from d_cache
                data_read <= 1'b1;
                data_addr <= queue[head_ptr].addr + queue[head_ptr].vj;

                // remove entry from queue
                if(data_resp == 1'b1) begin // only once cache has responded
                    head_ptr <= head_ptr + 1;
                    entries <= entries - 1;
                end
            end
            1'b1: begin // store
                // search CDB for valid tags
                for (int i = 0; i < NUM_CDB_ENTRIES; ++i) begin
                    if (cdb[i].tag == queue[head_ptr].qj) begin
                        queue[head_ptr].vj <= cdb[i].value;
                        // set register to valid
                        queue[head_ptr].qj <= 3'b0;
                    end
                    else if (cdb[i].tag == queue[head_ptr].qk) begin
                        queue[head_ptr].vk <= cdb[i].value;
                        // set register to valid
                        queue[head_ptr].qk <= 3'b0;
                    end
                    else begin
                        // keep waiting
                    end
                end

                // check if both registers are valid and current store instruction at top of ROB, then output addr
                if (queue[head_ptr].qj == 3'b0 && queue[head_ptr].qk == 3'b0 && 
                     curr_is_store == 1'b1 && head_tag == queue[head_ptr].tag) begin
                    store_res.tag <= queue[head_ptr].tag;
                    // add addresses together
                    store_res.value <= queue[head_ptr].vj; // SHOULD THIS BE VJ OR VK
                    store_res.tag <= queue[head_ptr].qj;

                    // store to cache
                    data_write <= 1'b1;
                    data_addr <= queue[head_ptr].addr + queue[head_ptr].vj;
                    // SHOULD THIS BE VJ OR VK
                    data_wdata <= queue[head_ptr].vk;

                    // need to dequeue
                    if(data_resp == 1'b1) begin // only once cache has responded
                        head_ptr <= head_ptr + 1;
                        entries <= entries - 1;
                        rob_store_complete <= 1'b1;
                    end
                end
            end
            default: ;
        endcase
    end
end

endmodule : load_store_queue
