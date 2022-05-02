`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module cmp_rs (
    input logic clk,
    input logic rst,
    input logic flush,

    // From ROB
    input rob_arr_t rob_arr_o,

    // To/from CDB
    input cdb_t cdb_vals_i,
    output cdb_entry_t [`CMP_RS_SIZE-1:0] cdb_cmp_vals_o,

    // To/from decoder
    input cmp_rs_t cmp_o,
    output logic cmp_rs_full
);

// TODO: edge case - what happens if tag value needed is broadcasted on cdb at the same 
// time as data is loading into RS? Don't think data would ever load into RS

cmp_rs_t cmp_rs_data_arr [`CMP_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic [`CMP_RS_SIZE-1:0] is_in_use;
logic [`CMP_RS_SIZE-1:0] load_cmp;
logic [`CMP_RS_SIZE-1:0] load_cdb;

// for whatever reason we got a multiple drivers error when writing directly to cmp_arr[i].value
logic [`CMP_RS_SIZE-1:0] cmp_res_arr;

task updateFromROB(int idx);
    if (cmp_o.rs1.valid == 1'b1) begin
        // do nothing
    end else if (rob_arr_o[cmp_o.rs1.tag].valid == 1'b1) begin
        // copy from ROB
        if (rob_arr_o[cmp_o.rs1.tag].reg_data.can_commit) begin
            cmp_rs_data_arr[idx].rs1.valid <= 1'b1;
            cmp_rs_data_arr[idx].rs1.tag <= '0;
        end else begin
            cmp_rs_data_arr[idx].rs1.tag <= cmp_o.rs1.tag;
        end
        cmp_rs_data_arr[idx].rs1.value <= rob_arr_o[cmp_o.rs1.tag].reg_data.value;
    end 

    if (cmp_o.rs2.valid == 1'b1) begin
        // do nothing
    end else if (rob_arr_o[cmp_o.rs2.tag].valid == 1'b1) begin
        // copy from ROB
        if (rob_arr_o[cmp_o.rs2.tag].reg_data.can_commit) begin
            cmp_rs_data_arr[idx].rs2.valid <= 1'b1;
            cmp_rs_data_arr[idx].rs2.tag <= '0;
        end else begin
            cmp_rs_data_arr[idx].rs2.tag <= cmp_o.rs2.tag;
        end
        cmp_rs_data_arr[idx].rs2.value <= rob_arr_o[cmp_o.rs2.tag].reg_data.value;
    end
endtask

task updateFromROBLater(int idx);
    if(cmp_rs_data_arr[idx].rs1.tag == 0) begin
        // do nothing
    end else if (rob_arr_o[cmp_rs_data_arr[idx].rs1.tag].valid == 1'b1) begin
        // copy from ROB
        if (rob_arr_o[cmp_rs_data_arr[idx].rs1.tag].reg_data.can_commit) begin
            cmp_rs_data_arr[idx].rs1.tag <= '0;
            cmp_rs_data_arr[idx].rs1.valid <= 1'b1;
        end
        cmp_rs_data_arr[idx].rs1.value <= rob_arr_o[cmp_rs_data_arr[idx].rs1.tag].reg_data.value;
    end 

    if (cmp_rs_data_arr[idx].rs2.tag == 0) begin
        // do nothing
    end else if(rob_arr_o[cmp_rs_data_arr[idx].rs2.tag].valid == 1'b1) begin
        // copy from ROB
        if(rob_arr_o[cmp_rs_data_arr[idx].rs2.tag].reg_data.can_commit)  begin
            cmp_rs_data_arr[idx].rs2.tag <= '0;
            cmp_rs_data_arr[idx].rs2.valid <= 1'b1;
        end
        cmp_rs_data_arr[idx].rs2.value <= rob_arr_o[cmp_rs_data_arr[idx].rs2.tag].reg_data.value;
    end
endtask

always_ff @ (posedge clk) begin
    // Can probably make more efficient - worry about later
    cmp_rs_full <= 1'b1;
    for (int i = 0; i < `CMP_RS_SIZE; ++i) begin
        if (is_in_use[i] == 1'b0)
            cmp_rs_full <= 1'b0;

        cdb_cmp_vals_o[i] <= '{default: 0};
    end
    
    if (rst || flush) begin
        for (int i = 0; i < `CMP_RS_SIZE; ++i) begin
            cmp_rs_data_arr[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
        end
    end else if (cmp_o.valid) begin
        // load data from decoder / ROB

        // load into first available rs (TODO PARAMETRIZE)
        if (is_in_use[0] == 1'b0) begin
            cmp_rs_data_arr[0] <= cmp_o;
            is_in_use[0] <= 1'b1;
            updateFromROB(0);
        end else if (is_in_use[1] == 1'b0) begin
            cmp_rs_data_arr[1] <= cmp_o;
            is_in_use[1] <= 1'b1;
            updateFromROB(1);
        end else if (is_in_use[2] == 1'b0) begin
            cmp_rs_data_arr[2] <= cmp_o;
            is_in_use[2] <= 1'b1;
            updateFromROB(2);
        end else if (is_in_use[3] == 1'b0) begin
            cmp_rs_data_arr[3] <= cmp_o;
            is_in_use[3] <= 1'b1;
            updateFromROB(3);
        end else if (is_in_use[4] == 1'b0) begin
            cmp_rs_data_arr[4] <= cmp_o;
            is_in_use[4] <= 1'b1;
            updateFromROB(4);
        end else if (is_in_use[5] == 1'b0) begin
            cmp_rs_data_arr[5] <= cmp_o;
            is_in_use[5] <= 1'b1;
            updateFromROB(5);
        end else begin
            cmp_rs_full <= 1'b1;
        end
    end

    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2

    // Maybe make generate - more efficient? 
    // Set valid bits based on input from CDB
    // CRITICAL PATH WHAT THE FUCK
    // FIX THIS ASAP
    if (~(rst || flush)) begin
        for (int i = 0; i < `CMP_RS_SIZE; ++i) begin
            // check for tag match
            if(cmp_rs_data_arr[i].valid == 1'b1)
                updateFromROBLater(i);
                
            for (int j = 0; j < `NUM_CDB_ENTRIES; ++j) begin
                if (cmp_rs_data_arr[i].rs1.valid == 1'b0 && cmp_rs_data_arr[i].rs1.tag == cdb_vals_i[j].tag) begin
                    cmp_rs_data_arr[i].rs1.value <= cdb_vals_i[j].value;
                    cmp_rs_data_arr[i].rs1.valid <= 1'b1;
                end
                if (cmp_rs_data_arr[i].rs2.valid == 1'b0 &&  cmp_rs_data_arr[i].rs2.tag == cdb_vals_i[j].tag) begin
                    cmp_rs_data_arr[i].rs2.value <= cdb_vals_i[j].value;
                    cmp_rs_data_arr[i].rs2.valid <= 1'b1;
                end
            end

            load_cmp[i] <= 1'b0;
            // if data[i].valid == 1'b1 then update alu_arr value and 
            // set load_rob high 1 cycle later
            if (cmp_rs_data_arr[i].valid == 1'b1 && cmp_rs_data_arr[i].rs1.valid == 1'b1 && cmp_rs_data_arr[i].rs2.valid == 1'b1)
                load_cmp[i] <= 1'b1;

            // Send data to CDB
            if (is_in_use[i] && load_cdb[i] == 1'b1) begin
                // If instruction is a branch
                if (cmp_rs_data_arr[i].br == 1) begin
                    // if CMP output is 1 or 0, decide to take branch or not
                    if (cmp_res_arr[i] == 1) begin
                        cdb_cmp_vals_o[i].target_pc <= cmp_rs_data_arr[i].pc + cmp_rs_data_arr[i].b_imm;

                    end else begin
                        cdb_cmp_vals_o[i].target_pc <= cmp_rs_data_arr[i].pc + 4;
                    end
                end
                // SLT/SLTI/SLTU/SLTIU
                // else begin
                //     cdb_cmp_vals_o[i].value <= {31'd0, cmp_res_arr[i]};
                // end

                cdb_cmp_vals_o[i].value <= {31'd0, cmp_res_arr[i]};
                cdb_cmp_vals_o[i].tag <= cmp_rs_data_arr[i].rob_idx;
                is_in_use[i] <= 1'b0;
                load_cmp[i] <= 1'b0;
                cmp_rs_data_arr[i].res.valid <= 1'b1;
                cmp_rs_data_arr[i].valid <= 1'b0;
            end
        end
    end
end

// Instantiate CMP's
genvar cmp_i;
generate
    for (cmp_i = 0; cmp_i < `CMP_RS_SIZE; ++cmp_i) begin : generate_cmp
        cmp cmp_instantiation(
            .clk(clk),
            .cmpop(cmp_rs_data_arr[cmp_i].op),
            .a(cmp_rs_data_arr[cmp_i].rs1.value),
            .b(cmp_rs_data_arr[cmp_i].rs2.value),
            .f(cmp_res_arr[cmp_i]),
            .load_cmp(load_cmp[cmp_i]),
            .ready(load_cdb[cmp_i])
        );
    end
endgenerate

endmodule : cmp_rs
