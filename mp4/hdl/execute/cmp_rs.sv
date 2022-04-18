`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module cmp_rs (
    input logic clk,
    input logic rst,
    input logic flush,

    // From ROB
    // input rv32i_word rob_reg_vals [`RO_BUFFER_ENTRIES],
    // input logic rob_commit_arr [`RO_BUFFER_ENTRIES],
    // output logic load_rob,
    input rob_arr_t rob_arr_o,

    // From/to CDB
    input cdb_t cdb_vals_i,
    output cdb_entry_t [`CMP_RS_SIZE-1:0] cdb_cmp_vals_o,

    // From decoder
    input cmp_rs_t cmp_o,

    // To decoder
    output logic cmp_rs_full,

    // To fetch
    output logic take_br,   // 1 = take branch, 0 = don't take branch
    output rv32i_word curr_pc,  // Do we need this???
    output rv32i_word next_pc,  // This IS NOT PC + 4

    // To/from regfile
    output rv32i_reg rs1_cmp_rs_i, rs2_cmp_rs_i,
    input regfile_data_out_t cmp_rs_d_out
);

cmp_rs_t data [`CMP_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic is_in_use [3:0];
logic [`CMP_RS_SIZE-1:0] load_cmp;
logic [`CMP_RS_SIZE-1:0] load_cdb;

// for whatever reason we got a multiple drivers error when writing directly to alu_arr[i].value
logic [`CMP_RS_SIZE-1:0] cmp_res_arr;

task updateFromROB(int idx);
    for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
        if(data[idx].rs1.valid == 1'b1) begin
            // do nothing
        end else if(rob_arr_o[i].tag == data[idx].rs1.tag) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                data[idx].rs1.valid <= rob_arr_o[data[idx].rs1.tag].reg_data.can_commit;
                data[idx].rs1.value <= rob_arr_o[data[idx].rs1.tag].reg_data.value;
            end else begin 
                // set entry valid to 0
                // copy value over so that it is not dont cares
                data[idx].rs1.valid <= 1'b0;
            end
        end else begin
            // copy from regfile
            rs1_cmp_rs_i <= data[idx].rs1.tag;
            data[idx].rs1.valid <= 1'b1;
            data[idx].rs1.value <= cmp_rs_d_out.vj_out;
        end

        if(data[idx].rs2.valid == 1'b1) begin
            // do nothing
        end else if(rob_arr_o[i].tag == data[idx].rs2.tag) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                data[idx].rs2.valid <= rob_arr_o[data[idx].rs2.tag].reg_data.can_commit;
                data[idx].rs2.value <= rob_arr_o[data[idx].rs2.tag].reg_data.value;
            end else begin 
                // set entry valid to 0
                // copy value over so that it is not dont cares
                data[idx].rs2.valid <= 1'b0;
            end
        end else begin
            // copy from regfile
            rs2_cmp_rs_i <= data[idx].rs2.tag;
            data[idx].rs2.valid <= 1'b1;
            data[idx].rs2.value <= cmp_rs_d_out.vk_out;
        end
    end

    data[idx].res.valid <= 1'b0;
endtask

always_ff @(posedge clk) begin
    // Can probably make more efficient - worry about later
    cmp_rs_full <= 1'b1;
    for(int i = 0; i < `CMP_RS_SIZE; ++i) begin
        if(is_in_use[i] == 1'b0)
            cmp_rs_full <= 1'b0;
    end
    
    if(rst || flush) begin
        for(int i = 0; i < `CMP_RS_SIZE; ++i) begin
            data[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
        end
    end 
    else if(cmp_o.valid) begin
        // load data from decoder / ROB

        if(is_in_use[0] == 1'b0) begin
            data[0] <= cmp_o;
            updateFromROB(0);
            is_in_use[0] <= 1'b1;
        end else if(is_in_use[1] == 1'b0) begin
            data[1] <= cmp_o;
            updateFromROB(1);
            is_in_use[1] <= 1'b1;
        end else if(is_in_use[2] == 1'b0) begin
            data[2] <= cmp_o;
            updateFromROB(2);
            is_in_use[2] <= 1'b1;
        end else if(is_in_use[3] == 1'b0) begin
            data[3] <= cmp_o;
            updateFromROB(3);
            is_in_use[3] <= 1'b1;
        end else begin
            cmp_rs_full <= 1'b1;
        end

        // for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
        //     if(cmp_o.rs1.valid == 1'b1) begin
        //         // do nothing
        //     end else if(rob_arr_o[i].tag == cmp_o.rs1.tag) begin
        //         if(rob_arr_o[i].valid == 1'b1) begin
        //             // copy from ROB
        //             cmp_o.rs1.valid <= rob_arr_o[cmp_o.rs1.tag].reg_data.can_commit;
        //             cmp_o.rs1.value <= rob_arr_o[cmp_o.rs1.tag].reg_data.value;
        //         end else begin 
        //             // set entry valid to 0
        //             // copy value over so that it is not dont cares
        //             cmp_o.rs1.valid <= 1'b0;
        //         end
        //     end else begin
        //         // copy from regfile
        //         rs1_cmp_rs_i <= cmp_o.rs1.tag;
        //         cmp_o.rs1.valid <= 1'b1;
        //         cmp_o.rs1.value <= cmp_rs_d_out.vj_out;
        //     end

        //     if(cmp_o.rs2.valid == 1'b1) begin
        //         // do nothing
        //     end else if(rob_arr_o[i].tag == cmp_o.rs2.tag) begin
        //         if(rob_arr_o[i].valid == 1'b1) begin
        //             // copy from ROB
        //             cmp_o.rs2.valid <= rob_arr_o[cmp_o.rs2.tag].reg_data.can_commit;
        //             cmp_o.rs2.value <= rob_arr_o[cmp_o.rs2.tag].reg_data.value;
        //         end else begin 
        //             // set entry valid to 0
        //             // copy value over so that it is not dont cares
        //             cmp_o.rs2.valid <= 1'b0;
        //         end
        //     end else begin
        //         // copy from regfile
        //         rs2_cmp_rs_i <= cmp_o.rs2.tag;
        //         cmp_o.rs2.valid <= 1'b1;
        //         cmp_o.rs2.value <= cmp_rs_d_out.vk_out;
        //     end
        // end

        // load into first available rs (TODO PARAMETRIZE)
    end
    
    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2

    // Maybe make generate - more efficient? 
    // Set valid bits based on input from CDB
    // CRITICAL PATH WHAT THE FUCK
    // FIX THIS ASAP
    for(int i = 0; i < `CMP_RS_SIZE; ++i) begin
        // check for tag match
        for(int j = 0; j < `NUM_CDB_ENTRIES; ++j) begin
            if(data[i].rs1.tag == cdb_vals_i[j].tag) begin
                data[i].rs1.value <= cdb_vals_i[j].value;
                data[i].rs1.valid <= 1'b1;
            end
            if(data[i].rs2.tag == cdb_vals_i[j].tag) begin
                data[i].rs2.value <= cdb_vals_i[j].value;
                data[i].rs2.valid <= 1'b1;
            end
        end

        load_cmp[i] <= 1'b0;
        // if data[i].valid == 1'b1 then update cmp_arr value and 
        // set load_rob high 1 cycle later
        if(data[i].rs1.valid == 1'b1 && data[i].rs2.valid == 1'b1) begin            
            load_cmp[i] <= 1'b1;
        end

        // Send data to CDB
        if(load_cdb[i] == 1'b1) begin
            cdb_cmp_vals_o[i].value <= cmp_res_arr[i];
            cdb_cmp_vals_o[i].tag <= data[i].rob_idx;
            is_in_use[i] <= 1'b0;
        end
    end
end

// Instantiate CMP's
genvar cmp_i;
generate
    for(cmp_i = 0; cmp_i < `CMP_RS_SIZE; ++cmp_i) begin : generate_cmp
        cmp cmp_instantiation(
            .clk(clk),
            .cmpop(data[cmp_i].op),
            .a(data[cmp_i].rs1.value),
            .b(data[cmp_i].rs2.value),
            .f(cmp_res_arr[cmp_i]),
            .load_cmp(load_cmp[cmp_i]),
            .ready(load_cdb[cmp_i])
        );
    end
endgenerate

// always_ff @ (posedge clk) begin
//     for (int i = 0; i < NUM_CMP_RS; ++i) begin
//         // Checks only current entries that have valid values
//         if (is_in_use[i] == 1 && Qj[i] == 0 && Qk[i] == 0) begin
//             if (data[i].br) begin   // If instruction is a branch
//                 // Tell fetch to add immediate to current PC instead
//                 // of going to PC + 4
//                 take_br <= cmp_res_arr[i];
//                 if (res[i]) begin
//                     next_pc[i] <= pc[i] + data[i].b_imm;
//                 end else begin
//                     next_pc[i] <= pc[i] + 4;
//                 end
//             end else begin   // If instruction is not a branchs
//                 // stuff
//             end
//         end
//     end
// end

endmodule : cmp_rs
