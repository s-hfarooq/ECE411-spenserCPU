`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module load_store_queue
(
    input clk,
    input rst,
    input logic flush,

    input cdb_t cdb,

    input lsb_t lsb_entry, // from ROB

    output cdb_entry_t load_res,

    output logic ldst_full,
    output logic almost_full,

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
    input rv32i_word data_rdata
);

// Head and tail pointers
logic [$clog2(`LDST_SIZE)-1:0] head_ptr = {$clog2(`LDST_SIZE){1'b0}};
logic [$clog2(`LDST_SIZE)-1:0] tail_ptr = {$clog2(`LDST_SIZE){1'b0}};
logic [$clog2(`LDST_SIZE):0] entries;

lsb_t queue [`LDST_SIZE-1:0];

assign ldst_full = (entries >= (`LDST_SIZE - 1));
assign almost_full = (entries >= (`LDST_SIZE-2));

assign entries = (head_ptr > tail_ptr) ? (tail_ptr + `LDST_SIZE - head_ptr) : (tail_ptr - head_ptr);

task set_defaults();
    rob_store_complete <= 1'b0;
    data_read <= 1'b0;
    data_write <= 1'b0;
    data_mbe <= 4'b1111;
    load_res <= '{default: 0};
    data_addr <= 32'd0;
    data_wdata <= 32'd0;
endtask

// store rs
always_ff @(posedge clk) begin : store_rs
    set_defaults();

    if(rst || flush) begin
        for(int i = 0; i < `LDST_SIZE; ++i)
            queue <= '{default: 0};
            
        head_ptr <= {$clog2(`LDST_SIZE){1'b0}};
        tail_ptr <= {$clog2(`LDST_SIZE){1'b0}};
        // entries <= {$clog2(`LDST_SIZE){1'b0}};
    end else begin
        if(lsb_entry.valid == 1'b1 && entries < `LDST_SIZE) begin
            queue[tail_ptr] <= lsb_entry;
            tail_ptr <= tail_ptr + 1;
            // if(data_resp == 1'b0)
            //     entries <= entries + 1;
        end
    end

    if(entries > 0) begin
        // Check CDB to see if needed values have been broadcasted
        for(int i = 0; i < `LDST_SIZE; ++i) begin
            for(int j = 0; j < `NUM_CDB_ENTRIES; ++j) begin
                if(queue[i].qj != 0 && queue[i].qj == cdb[j].tag) begin
                    queue[i].vj <= cdb[j].value;
                    queue[i].qj <= 0;
                end

                if(queue[i].qk != 0 && queue[i].qk == cdb[j].tag) begin
                    queue[i].vk <= cdb[j].value;
                    queue[i].qk <= 0;
                end
            end
        end

        // Set can finish if we have valid register values
        if(queue[head_ptr].qj == 0 && queue[head_ptr].qk == 0) begin
            queue[head_ptr].can_finish <= 1'b1;
        end
        
        if(queue[head_ptr].can_finish == 1'b1) begin
            case(queue[head_ptr].type_of_inst)
                1'b0: begin // load
                    // request data from d_cache
                    data_read <= 1'b1;
                    data_addr <= queue[head_ptr].addr + queue[head_ptr].vj;

                    // remove entry from queue
                    if(data_resp == 1'b1) begin // only once cache has responded
                        // broadcast data received on CDB
                        // calculate effective address and set tag

                        // need to load correct bits for lb/lh (shouldn't always be lowest)
                        case(load_funct3_t'(queue[head_ptr].funct))
                            lb: begin 
                                // load_res.value <= {{24{data_rdata[7]}}, data_rdata[7:0]};
                                $displayh("IN lb, data_addr: %p (%p), val will be (assumming 00): %p", data_addr, data_addr[1:0], {{24{data_rdata[7]}}, data_rdata[7:0]});

                                case (data_addr[1:0])
                                    2'b00: load_res.value <= {{24{data_rdata[7]}}, data_rdata[7:0]};
                                    2'b01: load_res.value <= {{24{data_rdata[15]}}, data_rdata[15:8]};
                                    2'b10: load_res.value <= {{24{data_rdata[23]}}, data_rdata[23:16]};
                                    2'b11: load_res.value <= {{24{data_rdata[31]}}, data_rdata[31:24]};
                                    default: load_res.value <= 32'h0;
                                endcase
                            end
                            lh: begin
                                // load_res.value <= {{16{data_rdata[15]}}, data_rdata[15:0]};
                                case (data_addr[1])
                                    1'b0: load_res.value <= $signed(data_rdata[15:0]); // looking at the top bits
                                    1'b1: load_res.value <= $signed(data_rdata[31:16]);
                                endcase  
                            end
                            lw: begin 
                                load_res.value <= data_rdata;
                            end
                            lbu: begin 
                                // load_res.value <= {24'b0, data_rdata[7:0]};
                                case (data_addr[1:0])
                                    2'b00: load_res.value <= {24'h0, data_rdata[7:0]};
                                    2'b01: load_res.value <= {24'h0, data_rdata[15:8]};
                                    2'b10: load_res.value <= {24'h0, data_rdata[23:16]};
                                    2'b11: load_res.value <= {24'h0, data_rdata[31:24]};
                                    default: load_res.value <= 32'h0;
                                endcase
                            end
                            lhu: begin 
                                // load_res.value <= {16'b0, data_rdata[15:0]};
                                case (data_addr[1])
                                    1'b0: load_res.value <= {16'h0, data_rdata[15:0]}; // looking at the top bits
                                    1'b1: load_res.value <= {16'h0, data_rdata[31:16]};
                                endcase  
                            end

                            default: begin
                                load_res.value <= 32'd0;
                            end
                        endcase

                        load_res.tag <= queue[head_ptr].tag;
                        queue[head_ptr].valid <= 1'b0;
                        head_ptr <= head_ptr + 1;
                        data_read <= 1'b0;
                        queue[head_ptr] <= '{default: 0};
                    end
                end
                1'b1: begin // store
                    // search CDB for valid tags
                    // for (int i = 0; i < `NUM_CDB_ENTRIES; ++i) begin
                    //     if (cdb[i].tag == queue[head_ptr].qj) begin
                    //         queue[head_ptr].vj <= cdb[i].value;
                    //         // set register to valid
                    //         queue[head_ptr].qj <= 3'b0;
                    //     end else if (cdb[i].tag == queue[head_ptr].qk) begin
                    //         queue[head_ptr].vk <= cdb[i].value;
                    //         // set register to valid
                    //         queue[head_ptr].qk <= 3'b0;
                    //     end
                    // end

                    // check if both registers are valid and current store instruction at top of ROB, then output addr
                    if (queue[head_ptr].qj == 3'b0 && queue[head_ptr].qk == 3'b0 && 
                        curr_is_store == 1'b1 && head_tag == queue[head_ptr].tag) begin
                        // store to cache
                        data_write <= 1'b1;
                        data_addr <= queue[head_ptr].addr + queue[head_ptr].vj;
                        // SHOULD THIS BE VJ OR VK (IT SHOULD BE VK)
                        data_wdata <= queue[head_ptr].vk;

                        case(store_funct3_t'(queue[head_ptr].funct))
                            // TODO Verify: THIS ASSUMES THAT THIS IS ALWAYS THLOWEST BITS.
                            // WE NEED TO MAKE SURE THAT EVERYTHING IS 4-BYTE ALIGNED
                            sw: data_mbe <= 4'b1111;
                            sh: data_mbe <= 4'b0011 << data_addr[1:0];
                            sb: data_mbe <= 4'b0001 << data_addr[1:0];
                            // sb: begin
                            //     data_mbe <= 4'b0001;
                            // end
                            // sh: begin
                            //     data_mbe <= 4'b0011;
                            // end
                            // sw: begin
                            //     data_mbe <= 4'b1111;
                            // end
                        endcase

                        // need to dequeue
                        if(data_resp == 1'b1) begin // only once cache has responded
                            queue[head_ptr].valid <= 1'b0;

                            head_ptr <= head_ptr + 1;
                            // if(lsb_entry.valid == 1'b0)
                            //     entries <= entries - 1;
                            rob_store_complete <= 1'b1;
                            data_write <= 1'b0;

                            queue[head_ptr] <= '{default: 0};
                        end
                    end
                end
                default: ;
            endcase
        end
    end
end

endmodule : load_store_queue
