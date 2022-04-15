`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module alu_rs (
    input logic clk,
    input logic rst,
    input logic flush,

    // From ROB
    // input logic [$clog2(RO_BUFFER_ENTRIES)-1:0] rs_idx_in, // index of register to set valid bit
    // input logic is_valid,
    // input logic [2:0] rob_free_tag,
    // input rv32i_word rob_reg_vals [`RO_BUFFER_ENTRIES],
    // input logic rob_commit_arr [`RO_BUFFER_ENTRIES],
    input rob_arr_t rob_arr_o,
    // output logic load_rob,

    // From/to CDB
    input cdb_t cdb_vals_i,
    output cdb_entry_t [`ALU_RS_SIZE-1:0] cdb_alu_vals_o,

    // From decoder
    input alu_rs_t alu_o,
    // input rs_data_t data_in,
    // input logic alu_valid,

    // To decoder
    output logic alu_rs_full,

    // To/from regfile
    output rv32i_reg rs1_alu_rs_i, rs2_alu_rs_i,
    input regfile_data_out_t alu_rs_d_out
);

// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS

// TODO: LOADING TAG VALUE IS INCORRECT, MAYBE TIMING ISSUE?

rs_data_t data [`ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic is_in_use [3:0];
logic [`ALU_RS_SIZE-1:0] load_alu;

rs_data_t curr_rs_data;

alu_rs_t [`ALU_RS_SIZE-1:0] alu_arr;
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
            alu_arr[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
            // cdb_alu_vals_o[i] <= '{default: 0};
        end

        // load_rob <= 1'b0;
    end else if (alu_o.valid) begin
        // load data from decoder / ROB
        // for(int i = 0; i < `ALU_RS_SIZE; ++i)
        //     cdb_alu_vals_o[i] <= '{default: 0};

        curr_rs_data.valid <= 1'b0;
        curr_rs_data.busy <= 1'b0;
        curr_rs_data.opcode <= rv32i_opcode'(alu_o.op);
        curr_rs_data.alu_op <= alu_o.op;

        // do comparison -- if tag exists in ROB, get data from ROB.
        // else -- get data from regfile
        for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
            if(alu_o.qj == 0) begin
                // Copy from alu_o input
                curr_rs_data.rs1.valid <= 1'b1;
                curr_rs_data.rs1.value <= alu_o.vj;
            end else if(rob_arr_o[i].tag == alu_o.qj) begin
                if(rob_arr_o[i].valid == 1'b1) begin
                    // copy from ROB
                    curr_rs_data.rs1.valid <= rob_arr_o[alu_o.qj].reg_data.can_commit;
                    curr_rs_data.rs1.value <= rob_arr_o[alu_o.qj].reg_data.value;
                end else begin 
                    // set entry valid to 0
                    // copy value over so that it is not dont cares
                    curr_rs_data.rs1.valid <= 1'b0;
                end
            end else begin
                // copy from regfile
                rs1_alu_rs_i <= alu_o.qj;
                curr_rs_data.rs1.valid <= 1'b1;
                curr_rs_data.rs1.value <= alu_rs_d_out.vj_out;
            end


            if(alu_o.qk == 0) begin
                // Copy from alu_o input
                curr_rs_data.rs2.valid <= 1'b1;
                curr_rs_data.rs2.value <= alu_o.vk;
            end else if(rob_arr_o[i].tag == alu_o.qk) begin
                if(rob_arr_o[i].valid == 1'b1) begin
                    // copy from ROB
                    curr_rs_data.rs2.valid <= rob_arr_o[alu_o.qk].reg_data.can_commit;
                    curr_rs_data.rs2.value <= rob_arr_o[alu_o.qk].reg_data.value;
                end else begin 
                    // set entry valid to 0
                    // copy value over so that it is not dont cares
                    curr_rs_data.rs2.valid <= 1'b0;
                end
            end else begin
                // copy from regfile
                rs2_alu_rs_i <= alu_o.qk;
                curr_rs_data.rs2.valid <= 1'b1;
                curr_rs_data.rs2.value <= alu_rs_d_out.vk_out;
            end
        end

        curr_rs_data.rs1.tag <= alu_o.qj;
        curr_rs_data.rs2.tag <= alu_o.qk;
        curr_rs_data.res.valid <= 1'b0;
        curr_rs_data.res.value <= 32'b0;
        curr_rs_data.res.tag <= alu_o.rob_idx;

        // load into first available rs (TODO PARAMETRIZE)
        if(is_in_use[0] == 1'b0) begin
            data[0] <= curr_rs_data;
            is_in_use[0] <= 1'b1;
        end else if(is_in_use[1] == 1'b0) begin
            data[1] <= curr_rs_data;
            is_in_use[1] <= 1'b1;
        end else if(is_in_use[2] == 1'b0) begin
            data[2] <= curr_rs_data;
            is_in_use[2] <= 1'b1;
        end else if(is_in_use[3] == 1'b0) begin
            data[3] <= curr_rs_data;
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

        // Set valid bit on entry if both inputs are valid
        if(data[i].rs1.valid == 1'b1 && data[i].rs2.valid == 1'b1)
            data[i].valid <= 1'b1;

        load_alu[i] <= 1'b0;
        // if data[i].valid == 1'b1 then update alu_arr value and 
        // set load_rob high 1 cycle later
        if(data[i].valid == 1'b1) begin
            alu_arr[i].vj <= data[i].rs1.value;
            alu_arr[i].vk <= data[i].rs2.value;
            alu_arr[i].qj <= data[i].rs1.tag;
            alu_arr[i].qj <= data[i].rs2.tag;
            alu_arr[i].op <= data[i].alu_op; // doesn't matter?
            alu_arr[i].rob_idx <= data[i].res.tag; // doesn't matter?

            load_alu[i] <= 1'b1;
        end

        // Send data to CDB
        if(load_cdb[i] == 1'b1) begin
            cdb_alu_vals_o[i].value <= alu_res_arr[i];
            cdb_alu_vals_o[i].tag <= alu_arr[i].rob_idx;
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
            .aluop(alu_arr[alu_i].op),
            .a(alu_arr[alu_i].vj),
            .b(alu_arr[alu_i].vk),
            .f(alu_res_arr[alu_i]),
            .load_alu(load_alu[alu_i]),
            .ready(load_cdb[alu_i])
        );
    end
endgenerate

endmodule : alu_rs
