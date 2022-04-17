`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module alu_rs (
    input logic clk,
    input logic rst,
    input logic flush,

    // From ROB
    input rob_arr_t rob_arr_o,

    // From/to CDB
    input cdb_t cdb_vals_i,
    output cdb_entry_t [`ALU_RS_SIZE-1:0] cdb_alu_vals_o,

    // From decoder
    input alu_rs_t alu_o,

    // To decoder
    output logic alu_rs_full,

    // To/from regfile
    output rv32i_reg rs1_alu_rs_i, rs2_alu_rs_i,
    input regfile_data_out_t alu_rs_d_out
);

// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS

alu_rs_t data [`ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic is_in_use [3:0];
logic [`ALU_RS_SIZE-1:0] load_alu;
logic [`ALU_RS_SIZE-1:0] load_cdb;

// for whatever reason we got a multiple drivers error when writing directly to alu_arr[i].value
rv32i_word [`ALU_RS_SIZE-1:0] alu_res_arr;

always_ff @(posedge clk) begin
    // Can probably make more efficient - worry about later
    alu_rs_full <= 1'b1;
    for(int i = 0; i < `ALU_RS_SIZE; ++i) begin
        if(is_in_use[i] == 1'b0)
            alu_rs_full <= 1'b0;
    end
    
    if(rst || flush) begin
        for(int i = 0; i < `ALU_RS_SIZE; ++i) begin
            data[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
        end
    end else if (alu_o.valid) begin
        // load data from decoder / ROB

        // do comparison -- if tag exists in ROB, get data from ROB.
        // else -- get data from regfile
        for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
            if(alu_o.rs1.valid == 1'b1) begin
                // do nothing
            end else if(rob_arr_o[i].tag == alu_o.rs1.tag) begin
                if(rob_arr_o[i].valid == 1'b1) begin
                    // copy from ROB
                    alu_o.rs1.valid <= rob_arr_o[alu_o.rs1.tag].reg_data.can_commit;
                    alu_o.rs1.value <= rob_arr_o[alu_o.rs1.tag].reg_data.value;
                end else begin
                    // set entry valid to 0
                    // copy value over so that it is not dont cares
                    alu_o.rs1.valid <= 1'b0;
                end
            end else begin
                // copy from regfile
                rs1_alu_rs_i <= alu_o.rs1.tag;
                alu_o.rs1.valid <= 1'b1;
                alu_o.rs1.value <= alu_rs_d_out.vj_out;
            end

            if(alu_o.rs2.valid == 1'b1) begin
                // do nothing
            end else if(rob_arr_o[i].tag == alu_o.rs2.tag) begin
                if(rob_arr_o[i].valid == 1'b1) begin
                    // copy from ROB
                    alu_o.rs2.valid <= rob_arr_o[alu_o.rs2.tag].reg_data.can_commit;
                    alu_o.rs2.value <= rob_arr_o[alu_o.rs2.tag].reg_data.value;
                end else begin 
                    // set entry valid to 0
                    // copy value over so that it is not dont cares
                    alu_o.rs2.valid <= 1'b0;
                end
            end else begin
                // copy from regfile
                rs2_alu_rs_i <= alu_o.rs2.tag;
                alu_o.rs2.valid <= 1'b1;
                alu_o.rs2.value <= alu_rs_d_out.vk_out;
            end
        end

        // load into first available rs (TODO PARAMETRIZE)
        if(is_in_use[0] == 1'b0) begin
            data[0] <= alu_o;
            is_in_use[0] <= 1'b1;
        end else if(is_in_use[1] == 1'b0) begin
            data[1] <= alu_o;
            is_in_use[1] <= 1'b1;
        end else if(is_in_use[2] == 1'b0) begin
            data[2] <= alu_o;
            is_in_use[2] <= 1'b1;
        end else if(is_in_use[3] == 1'b0) begin
            data[3] <= alu_o;
            is_in_use[3] <= 1'b1;
        end else begin
            alu_rs_full <= 1'b1;
        end
    end

    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2

    // Maybe make generate - more efficient? 
    // Set valid bits based on input from CDB
    // CRITICAL PATH WHAT THE FUCK
    // FIX THIS ASAP
    for(int i = 0; i < `ALU_RS_SIZE; ++i) begin
        // check for tag match
        for(int j = 0; j < `NUM_CDB_ENTRIES; ++j) begin
            if(data[i].rs1.valid == 1'b0 && data[i].rs1.tag == cdb_vals_i[j].tag) begin
                data[i].rs1.value <= cdb_vals_i[j].value;
                data[i].rs1.valid <= 1'b1;
            end
            if(data[i].rs2.valid == 1'b0 &&  data[i].rs2.tag == cdb_vals_i[j].tag) begin
                data[i].rs2.value <= cdb_vals_i[j].value;
                data[i].rs2.valid <= 1'b1;
            end
        end

        load_alu[i] <= 1'b0;
        // if data[i].valid == 1'b1 then update alu_arr value and 
        // set load_rob high 1 cycle later
        if(data[i].rs1.valid == 1'b1 && data[i].rs2.valid == 1'b1) begin
            curr_rs_data.busy <= 1'b1;
            load_alu[i] <= 1'b1;
        end

        // Send data to CDB
        if(load_cdb[i] == 1'b1) begin
            cdb_alu_vals_o[i].value <= alu_res_arr[i];
            cdb_alu_vals_o[i].tag <= data[i].rob_idx;
            is_in_use[i] <= 1'b0;
        end
    end
end

// Instantiate ALU's
genvar alu_i;
generate
    for(alu_i = 0; alu_i < `ALU_RS_SIZE; ++alu_i) begin : generate_alu
        alu alu_instantiation(
            .clk(clk),
            .aluop(data[alu_i].op),
            .a(data[alu_i].rs1.value),
            .b(data[alu_i].rs2.value),
            .f(alu_res_arr[alu_i]),
            .load_alu(load_alu[alu_i]),
            .ready(load_cdb[alu_i])
        );
    end
endgenerate

endmodule : alu_rs
