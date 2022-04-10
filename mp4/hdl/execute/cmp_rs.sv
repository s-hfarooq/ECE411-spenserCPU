import rv32i_types::*;
import structs::*;
import macros::*;

module cmp_rs (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic load,

    // From ROB
    // input logic [$clog2(RO_BUFFER_ENTRIES)-1:0] rs_idx_in, // index of register to set valid bit
    // input logic is_valid,
    // input logic [2:0] rob_free_tag,
    input rv32i_word rob_reg_vals [RO_BUFFER_ENTRIES],
    input logic rob_commit_arr [RO_BUFFER_ENTRIES],

    // From/to CDB
    input cdb_t cdb_vals_i,
    output cdb_entry_t [ALU_RS_SIZE-1:0] cdb_alu_vals_o,

    // From decoder
    input alu_rs_t alu_o,
    // input rs_data_t data_in,
    // input logic alu_valid,

    // To ALU
    output alu_rs_t data_out,

    // To decoder
    output logic alu_rs_full
);

// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS

rs_data_t data [ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic is_in_use [3:0];
logic [ALU_RS_SIZE-1:0] load_alu;

rs_data_t curr_rs_data;

alu_rs_t [ALU_RS_SIZE-1:0] alu_arr;
logic [ALU_RS_SIZE-1:0] load_cdb;


always_ff @(posedge clk) begin
    // Can probably make more efficient - worry about later
    alu_rs_full <= 1'b1;
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        if(is_in_use[i] == 1'b0)
            alu_rs_full <= 1'b0;
    end
    
    if(rst || flush) begin
        for(int i = 0; i < ALU_RS_SIZE; ++i) begin
            data[i] <= '{default: 0};
            alu_arr[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
        end

        load_rob <= 1'b0;
    end 
    else if(load) begin
        // load data from decoder / ROB

        curr_rs_data.valid <= 1'b0;
        curr_rs_data.busy <= 1'b0;
        curr_rs_data.opcode <= alu_o.op;
        curr_rs_data.alu_op <= alu_o.op;
        curr_rs_data.rs1.valid <= rob_commit_arr[alu_o.qj];
        curr_rs_data.rs1.value <= rob_reg_vals[alu_o.qj]; // need to get value from ROB (only if tag != 0)
        curr_rs_data.rs1.tag <= alu_o.qj;
        curr_rs_data.rs2.valid <= rob_commit_arr[alu_o.qk];
        curr_rs_data.rs2.value <= rob_reg_vals[alu_o.qk]; // need to get value from ROB (only if tag != 0)
        curr_rs_data.rs2.tag <= alu_o.qk;
        curr_rs_data.res.valid <= 1'b0;
        curr_rs_data.res.value <= 32'b0;
        curr_rs_data.res.tag <= alu_o.rob_idx;


        // load into first available rs (TODO PARAMETRIZE)
        if(is_in_use[0] == 1'b0) begin
            data[0] <= curr_rs_data;
        end else if(is_in_use[1] == 1'b0) begin
            data[1] <= curr_rs_data;
        end else if(is_in_use[2] == 1'b0) begin
            data[2] <= curr_rs_data;
        end else if(is_in_use[3] == 1'b0) begin
            data[3] <= curr_rs_data;
        end else begin
            alu_rs_full <= 1'b1;
        end
    end
end

always_ff @(posedge clk) begin: set_data_vals
    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2

    // Maybe make generate - more efficient? 
    // Set valid bits based on input from CDB
    // CRITICAL PATH WHAT THE FUCK
    // FIX THIS ASAP
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        // check for tag match
        for(int j = 0; j < NUM_CDB_ENTRIES; ++j) begin
            if(data[i].rs1.tag == cdb_vals_i[j].tag) begin
                data[i].rs1.value <= cdb_vals_i[j].value;
                data[i].rs1.valid <= 1'b1;
            end
            if(data[i].rs2.tag == cdb_vals_i[j].tag) begin
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
            alu_arr[i].op <= data[i].alu_op;
            alu_arr[i].rob_idx <= data[i].res.idx;

            load_alu[i] <= 1'b1;

            is_in_use[i] <= 1'b0;
        end

        // Send data to CDB
        if(load_cdb[i] == 1'b1) begin
            cdb_alu_vals_o[i].value <= alu_arr[i].result;
            cdb_alu_vals_o[i].tag <= alu_arr[i].rob_idx;
        end
    end
end

// Instantiate ALU's
genvar alu_i;
generate
    for(alu_i = 0; alu_i < ALU_RS_SIZE; ++alu_i) begin
        alu alu_instantiation(
            .clk(clk),
            .aluop(alu_arr[alu_i].op),
            .a(alu_arr[alu_i].vj),
            .b(alu_arr[alu_i].vk),
            .f(alu_arr[alu_i].result)
            .load_alu(load_alu[i]),
            .ready(load_cdb[i])
        );
    end
endgenerate

endmodule : cmp_rs
