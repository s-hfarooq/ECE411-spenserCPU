`include "../macros.sv"

import rv32i_types::*;
import structs::*;

module alu_rs (
    input logic clk,
    input logic rst,
    input logic flush,

    // From ROB
    input rob_arr_t rob_arr_o,

    // To/from CDB
    input cdb_t cdb_vals_i,
    output cdb_entry_t [`ALU_RS_SIZE-1:0] cdb_alu_vals_o,

    // To/from decoder
    input alu_rs_t alu_o,
    output logic alu_rs_full
);

// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS

// TODO: edge case - what happens if tag value needed is broadcasted on cdb at the same 
// time as data is loading into RS? Don't think data would ever load into RS

alu_rs_t alu_rs_data_arr [`ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic [`ALU_RS_SIZE-1:0] is_in_use;
logic [`ALU_RS_SIZE-1:0] load_alu;
logic [`ALU_RS_SIZE-1:0] load_cdb;

// for whatever reason we got a multiple drivers error when writing directly to alu_arr[i].value
rv32i_word [`ALU_RS_SIZE-1:0] alu_res_arr;

task updateFromROB(int idx);
    for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
        if(alu_o.rs1.valid == 1'b1) begin
            // do nothing
        end else if(rob_arr_o[i].tag == alu_o.rs1.tag) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[alu_o.rs1.tag].reg_data.can_commit) begin
                    alu_rs_data_arr[idx].rs1.valid <= 1'b1;
                    alu_rs_data_arr[idx].rs1.tag <= 32'd0;
                end else begin
                    alu_rs_data_arr[idx].rs1.tag <= alu_o.rs1.tag;
                end
                alu_rs_data_arr[idx].rs1.value <= rob_arr_o[alu_o.rs1.tag].reg_data.value;
            end
        end 

        if(alu_o.rs2.valid == 1'b1) begin
            // do nothing
        end else if(rob_arr_o[i].tag == alu_o.rs2.tag) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[alu_o.rs2.tag].reg_data.can_commit) begin
                    alu_rs_data_arr[idx].rs2.valid <= 1'b1;
                    alu_rs_data_arr[idx].rs2.tag <= 32'd0;
                end else begin
                    alu_rs_data_arr[idx].rs2.tag <= alu_o.rs2.tag;
                end
                alu_rs_data_arr[idx].rs2.value <= rob_arr_o[alu_o.rs2.tag].reg_data.value;
            end
        end
    end
endtask

task updateFromROBLater(int idx);
    for(int i = 0; i < `RO_BUFFER_ENTRIES; ++i) begin
        if(alu_rs_data_arr[idx].rs1.tag == 0) begin
            // do nothing
        end else if(rob_arr_o[i].tag == alu_rs_data_arr[idx].rs1.tag) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[alu_rs_data_arr[idx].rs1.tag].reg_data.can_commit) begin
                    alu_rs_data_arr[idx].rs1.tag <= 32'd0;
                    alu_rs_data_arr[idx].rs1.valid <= 1'b1;
                end
                alu_rs_data_arr[idx].rs1.value <= rob_arr_o[alu_rs_data_arr[idx].rs1.tag].reg_data.value;
            end
        end 

        if(alu_rs_data_arr[idx].rs2.tag == 0) begin
            // do nothing
        end else if(rob_arr_o[i].tag == alu_rs_data_arr[idx].rs2.tag) begin
            if(rob_arr_o[i].valid == 1'b1) begin
                // copy from ROB
                if(rob_arr_o[alu_rs_data_arr[idx].rs2.tag].reg_data.can_commit)  begin
                    alu_rs_data_arr[idx].rs2.tag <= 32'd0;
                    alu_rs_data_arr[idx].rs2.valid <= 1'b1;
                end
                alu_rs_data_arr[idx].rs2.value <= rob_arr_o[alu_rs_data_arr[idx].rs2.tag].reg_data.value;
            end
        end
    end
endtask

always_ff @(posedge clk) begin
    // Can probably make more efficient - worry about later
    alu_rs_full <= 1'b1;
    for (int i = 0; i < `ALU_RS_SIZE; ++i) begin
        if (is_in_use[i] == 1'b0)
            alu_rs_full <= 1'b0;

        cdb_alu_vals_o[i] <= '{default: 0};
    end
    
    if (rst || flush) begin
        for (int i = 0; i < `ALU_RS_SIZE; ++i) begin
            alu_rs_data_arr[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
        end
    end else if (alu_o.valid) begin
        // load data from decoder / ROB

        // load into first available rs (TODO PARAMETRIZE)
        if (is_in_use[0] == 1'b0) begin
            alu_rs_data_arr[0] <= alu_o;
            is_in_use[0] <= 1'b1;
            updateFromROB(0);
        end else if (is_in_use[1] == 1'b0) begin
            alu_rs_data_arr[1] <= alu_o;
            is_in_use[1] <= 1'b1;
            updateFromROB(1);
        end else if (is_in_use[2] == 1'b0) begin
            alu_rs_data_arr[2] <= alu_o;
            is_in_use[2] <= 1'b1;
            updateFromROB(2);
        end else if (is_in_use[3] == 1'b0) begin
            alu_rs_data_arr[3] <= alu_o;
            is_in_use[3] <= 1'b1;
            updateFromROB(3);
        end else if (is_in_use[4] == 1'b0) begin
            alu_rs_data_arr[4] <= alu_o;
            is_in_use[4] <= 1'b1;
            updateFromROB(4);
        end else if (is_in_use[5] == 1'b0) begin
            alu_rs_data_arr[5] <= alu_o;
            is_in_use[5] <= 1'b1;
            updateFromROB(5);
        end else if (is_in_use[6] == 1'b0) begin
            alu_rs_data_arr[6] <= alu_o;
            is_in_use[6] <= 1'b1;
            updateFromROB(6);
        end else if (is_in_use[7] == 1'b0) begin
            alu_rs_data_arr[7] <= alu_o;
            is_in_use[7] <= 1'b1;
            updateFromROB(7);
        end else begin
            alu_rs_full <= 1'b1;
        end
    end

    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2

    // Maybe make generate - more efficient? 
    // Set valid bits based on input from CDB
    // CRITICAL PATH WHAT THE FUCK
    // FIX THIS ASAP
    if (~(rst || flush)) begin
        for (int i = 0; i < `ALU_RS_SIZE; ++i) begin
            // check for tag match
            if(alu_rs_data_arr[i].valid == 1'b1)
                updateFromROBLater(i);

            for (int j = 0; j < `NUM_CDB_ENTRIES; ++j) begin
                if (alu_rs_data_arr[i].rs1.valid == 1'b0 && alu_rs_data_arr[i].rs1.tag == cdb_vals_i[j].tag) begin
                    alu_rs_data_arr[i].rs1.value <= cdb_vals_i[j].value;
                    alu_rs_data_arr[i].rs1.valid <= 1'b1;
                end
                if (alu_rs_data_arr[i].rs2.valid == 1'b0 &&  alu_rs_data_arr[i].rs2.tag == cdb_vals_i[j].tag) begin
                    alu_rs_data_arr[i].rs2.value <= cdb_vals_i[j].value;
                    alu_rs_data_arr[i].rs2.valid <= 1'b1;
                end
            end

            load_alu[i] <= 1'b0;
            // if data[i].valid == 1'b1 then update alu_arr value and 
            // set load_rob high 1 cycle later
            if (alu_rs_data_arr[i].valid == 1'b1 && alu_rs_data_arr[i].rs1.valid == 1'b1 && alu_rs_data_arr[i].rs2.valid == 1'b1) begin
                // if(alu_rs_data_arr[i].jmp_type != none) begin
                //     if($signed(alu_rs_data_arr[i].rs1.value) > 0)
                //         alu_rs_data_arr[i].op <= alu_add;
                //     else
                //         alu_rs_data_arr[i].op <= alu_sub;
                // end
                
                load_alu[i] <= 1'b1;
            end

            // Send data to CDB
            if (is_in_use[i] == 1'b1 && load_cdb[i] == 1'b1) begin
                case (alu_rs_data_arr[i].jmp_type)
                    jal: begin
                        cdb_alu_vals_o[i].target_pc <= alu_res_arr[i];
                        cdb_alu_vals_o[i].value <= alu_rs_data_arr[i].curr_pc + 4; // should be old pc + 4
                    end
                    
                    jalr: begin
                        cdb_alu_vals_o[i].target_pc <= (alu_res_arr[i]) & 32'hFFFF_FFFE;
                        cdb_alu_vals_o[i].value <= alu_rs_data_arr[i].curr_pc + 4; // should be old pc + 4
                    end

                    default: begin
                        cdb_alu_vals_o[i].value <= alu_res_arr[i];
                    end
                endcase

                cdb_alu_vals_o[i].tag <= alu_rs_data_arr[i].rob_idx;
                is_in_use[i] <= 1'b0;
                load_alu[i] <= 1'b0;
                alu_rs_data_arr[i].valid <= 1'b0;
            end
        end
    end
end

// Instantiate ALU's
genvar alu_i;
generate
    for (alu_i = 0; alu_i < `ALU_RS_SIZE; ++alu_i) begin : generate_alu
        alu alu_instantiation(
            .clk(clk),
            .aluop(alu_rs_data_arr[alu_i].op),
            .a(alu_rs_data_arr[alu_i].rs1.value),
            .b(alu_rs_data_arr[alu_i].rs2.value),
            .f(alu_res_arr[alu_i]),
            .load_alu(load_alu[alu_i]),
            .ready(load_cdb[alu_i])
        );
    end
endgenerate

endmodule : alu_rs
