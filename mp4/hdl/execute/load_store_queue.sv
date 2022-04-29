`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module load_store_queue (
    input clk,
    input rst,
    input logic flush,

    // To/from CDB
    input cdb_t cdb,
    output cdb_entry_t load_res,

    // To/from ROB
    output logic ldst_full,
    output logic almost_full,
    input lsb_t lsb_entry,
    output logic rob_store_complete,
    input logic curr_is_store,
    input logic [$clog2(`RO_BUFFER_ENTRIES)-1:0] head_tag,
    
    // To/from d-cache
    output logic data_read,
    output logic data_write,
    output logic [3:0] data_mbe, // mem byte enable
    output rv32i_word data_addr,
    output rv32i_word data_wdata,
    input logic data_resp,
    input rv32i_word data_rdata,

    input rob_arr_t rob_arr_o
);

// Head and tail pointers
logic [$clog2(`LDST_SIZE)-1:0] head_ptr = {$clog2(`LDST_SIZE){1'b0}};
logic [$clog2(`LDST_SIZE)-1:0] tail_ptr = {$clog2(`LDST_SIZE){1'b0}};
logic [$clog2(`LDST_SIZE):0] counter;

lsb_t ldst_queue [`LDST_SIZE-1:0];

assign ldst_full = (counter >= (`LDST_SIZE - 1));
assign almost_full = (counter >= (`LDST_SIZE-2));
assign counter = (head_ptr > tail_ptr) ? (tail_ptr + `LDST_SIZE - head_ptr) : (tail_ptr - head_ptr);

task set_defaults();
    rob_store_complete <= 1'b0;
    data_read <= 1'b0;
    data_write <= 1'b0;
    data_mbe <= 4'b1111;
    load_res <= '{default: 0};
    data_addr <= 32'd0;
    data_wdata <= 32'd0;
endtask

task updateFromROB(int idx);
    for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
        if(lsb_entry.qj == 0) begin
            // do nothing
        end else if(rob_arr_o[i].tag == lsb_entry.qj) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[lsb_entry.qj].reg_data.can_commit)
                    ldst_queue[idx].qj <= 32'd0;
                else
                    ldst_queue[idx].qj <= lsb_entry.qj;
                ldst_queue[idx].vj <= rob_arr_o[lsb_entry.qj].reg_data.value;
            end
        end 

        if(lsb_entry.qk == 0) begin
            // do nothing
        end else if(rob_arr_o[i].tag == lsb_entry.qk) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[lsb_entry.qk].reg_data.can_commit)
                    ldst_queue[idx].qk <= 32'd0;
                else
                    ldst_queue[idx].qk <= lsb_entry.qk;
                ldst_queue[idx].vk <= rob_arr_o[lsb_entry.qk].reg_data.value;
            end
        end
    end
endtask


task updateFromROBLater(int idx);
    for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
        if(ldst_queue[idx].qj == 0) begin
            // do nothing
        end else if(rob_arr_o[i].tag == ldst_queue[idx].qj) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[lsb_entry.qj].reg_data.can_commit)
                    ldst_queue[idx].qj <= 32'd0;
                ldst_queue[idx].vj <= rob_arr_o[lsb_entry.qj].reg_data.value;
            end
        end 

        if(ldst_queue[idx].qk == 0) begin
            // do nothing
        end else if(rob_arr_o[i].tag == ldst_queue[idx].qk) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[lsb_entry.qk].reg_data.can_commit)
                    ldst_queue[idx].qk <= 32'd0;
                ldst_queue[idx].vk <= rob_arr_o[lsb_entry.qk].reg_data.value;
            end
        end
    end
endtask

always_ff @ (posedge clk) begin : store_rs
    set_defaults();

    data_read <= 1'b0;

    if (rst || flush) begin
        for(int i = 0; i < `LDST_SIZE; ++i)
            ldst_queue <= '{default: 0};
            
        head_ptr <= {$clog2(`LDST_SIZE){1'b0}};
        tail_ptr <= {$clog2(`LDST_SIZE){1'b0}};
    end else begin
        // add new entry to queue
        if (lsb_entry.valid == 1'b1 && counter < `LDST_SIZE) begin
            ldst_queue[tail_ptr] <= lsb_entry;
            updateFromROB(tail_ptr);
            tail_ptr <= tail_ptr + 1;
        end
    end

    if (counter > 0) begin
        // Check CDB to see if needed values have been broadcasted
        for (int i = 0; i < `LDST_SIZE; ++i) begin
            if(ldst_queue[i].valid == 1'b1)
                updateFromROBLater(i);
            for (int j = 0; j < `NUM_CDB_ENTRIES; ++j) begin
                if (ldst_queue[i].qj != 0 && ldst_queue[i].qj == cdb[j].tag) begin
                    ldst_queue[i].vj <= cdb[j].value;
                    ldst_queue[i].qj <= 0;
                end

                if (ldst_queue[i].qk != 0 && ldst_queue[i].qk == cdb[j].tag) begin
                    ldst_queue[i].vk <= cdb[j].value;
                    ldst_queue[i].qk <= 0;
                end
            end
        end

        // Set can finish if we have valid register values
        if (ldst_queue[head_ptr].qj == 0 && ldst_queue[head_ptr].qk == 0)
            ldst_queue[head_ptr].can_finish <= 1'b1;
        
        // Send data to cache if register values are valid
        if (ldst_queue[head_ptr].can_finish == 1'b1) begin
            case (ldst_queue[head_ptr].type_of_inst)
                1'b0: begin // load
                    // request data from d_cache
                    data_read <= 1'b1;
                    data_addr <= ldst_queue[head_ptr].addr + ldst_queue[head_ptr].vj;

                    // remove entry from queue
                    if (data_resp == 1'b1) begin // only once cache has responded
                        // broadcast data received on CDB
                        // calculate effective address and set tag

                        // need to load correct bits for lb/lh (shouldn't always be lowest)
                        case (load_funct3_t'(ldst_queue[head_ptr].funct))
                            lb: begin 
                                case (data_addr[1:0])
                                    2'b00: load_res.value <= {{24{data_rdata[7]}}, data_rdata[7:0]};
                                    2'b01: load_res.value <= {{24{data_rdata[15]}}, data_rdata[15:8]};
                                    2'b10: load_res.value <= {{24{data_rdata[23]}}, data_rdata[23:16]};
                                    2'b11: load_res.value <= {{24{data_rdata[31]}}, data_rdata[31:24]};
                                    default: load_res.value <= 32'h0;
                                endcase
                            end
                            lh: begin
                                case (data_addr[1])
                                    1'b0: load_res.value <= $signed(data_rdata[15:0]); // looking at the top bits
                                    1'b1: load_res.value <= $signed(data_rdata[31:16]);
                                endcase  
                            end
                            lw: begin 
                                load_res.value <= data_rdata;
                            end
                            lbu: begin 
                                case (data_addr[1:0])
                                    2'b00: load_res.value <= {24'h0, data_rdata[7:0]};
                                    2'b01: load_res.value <= {24'h0, data_rdata[15:8]};
                                    2'b10: load_res.value <= {24'h0, data_rdata[23:16]};
                                    2'b11: load_res.value <= {24'h0, data_rdata[31:24]};
                                    default: load_res.value <= 32'h0;
                                endcase
                            end
                            lhu: begin 
                                case (data_addr[1])
                                    1'b0: load_res.value <= {16'h0, data_rdata[15:0]}; // looking at the top bits
                                    1'b1: load_res.value <= {16'h0, data_rdata[31:16]};
                                endcase  
                            end

                            default: begin
                                load_res.value <= 32'd0;
                            end
                        endcase

                        load_res.tag <= ldst_queue[head_ptr].tag;
                        ldst_queue[head_ptr].valid <= 1'b0;
                        head_ptr <= head_ptr + 1;
                        data_read <= 1'b0;
                        ldst_queue[head_ptr] <= '{default: 0};
                    end
                end
                1'b1: begin // store
                    // check if both registers are valid and current store instruction at top of ROB, then output addr
                    if (ldst_queue[head_ptr].qj == 3'b0 && ldst_queue[head_ptr].qk == 3'b0 && 
                        curr_is_store == 1'b1 && head_tag == ldst_queue[head_ptr].tag) begin
                        // store to cache
                        data_write <= 1'b1;
                        data_addr <= ldst_queue[head_ptr].addr + ldst_queue[head_ptr].vj;
                        // SHOULD THIS BE VJ OR VK (IT SHOULD BE VK)
                        data_wdata <= ldst_queue[head_ptr].vk;

                        case (store_funct3_t'(ldst_queue[head_ptr].funct))
                            // TODO Verify: THIS ASSUMES THAT THIS IS ALWAYS THLOWEST BITS.
                            // WE NEED TO MAKE SURE THAT EVERYTHING IS 4-BYTE ALIGNED
                            sw: data_mbe <= 4'b1111;
                            sh: data_mbe <= 4'b0011 << data_addr[1:0];
                            sb: data_mbe <= 4'b0001 << data_addr[1:0];
                        endcase

                        // need to dequeue
                        if (data_resp == 1'b1) begin // only once cache has responded
                            ldst_queue[head_ptr].valid <= 1'b0;

                            head_ptr <= head_ptr + 1;
                            rob_store_complete <= 1'b1;
                            data_write <= 1'b0;

                            ldst_queue[head_ptr] <= '{default: 0};
                        end
                    end
                end
                default: ;
            endcase
        end
    end
end

endmodule : load_store_queue
