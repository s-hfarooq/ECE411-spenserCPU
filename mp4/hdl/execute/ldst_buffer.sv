/* Copied from MP1 given code. */
import rv32i_types::*;
import structs::*;
import macros::*;

module ldst_buffer
(
    input clk,
    input rst,
    input logic flush,
    input logic load,

    input cdb_t cdb,

    input lsb_t lsb_entry, // from rob

    output cdb_entry_t store_res,
    output cdb_entry_t load_res,

    output logic ldst_full
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

// store rs
always_comb begin : store_rs
    if (queue[head_ptr].type == 1'b1) begin // store
        // search CDB for valid tags
        for (int i = 0; i < NUM_CDB_ENTRIES; ++i) begin
            if (cdb[i].tag == queue[head_ptr].qj) begin
                queue[head_ptr].vj = cdb[i].value;
                // set register to valid
                queue[head_ptr].qj = 3'b0;
            end 
            else if (cdb[i].tag == queue[head_ptr].qk) begin
                queue[head_ptr].vk = cdb[i].value;
                // set register to valid
                queue[head_ptr].qk = 3'b0;
            end
            else begin
                // keep waiting
            end
        end
        // check if both registers are valid, then output addr
        if (queue[head_ptr].qj == 3'b0 && queue[head_ptr].qk == 3'b0) begin
            store_res.tag = queue[head_ptr].tag;
            // add addresses together
            // store addr = queue[head_ptr].vj + queue[head_ptr].address;
            store_res.value = queue[head_ptr].vk;

            // need to dequeue
        end
    end
    else begin
        // do nothing for loads i think?? DOUBLE CHECK
    end
end

endmodule : ldst_buffer
