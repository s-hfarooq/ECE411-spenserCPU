import rv32i_types::*;
import structs::*;
import macros::*;

module reservation_station (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic load,

    // From ROB
    input logic [$clog2(RO_BUFFER_ENTRIES)-1:0] rs_idx_in, // index of register to set valid bit
    input logic is_valid,
    input logic [2:0] rob_free_tag,
    input rv32i_word rob_reg_vals [RO_BUFFER_ENTRIES],
    input logic rob_commit_arr [RO_BUFFER_ENTRIES],

    // From decoder
    input alu_rs_t alu_o,
    // input rs_data_t data_in,
    // input logic alu_valid,

    // To ALU
    output alu_rs_t data_out,

    // To decoder
    output logic alu_rs_full,

    // To ROB
    output alu_rs_t [ALU_RS_SIZE-1:0] alu_arr,
    output logic [ALU_RS_SIZE-1:0] load_rob
);

// ROB sends valid signal (valid, rs1.ready, rs2.ready must all be high before execution)
// set busy to high, send to ALU
// ALU broadcasts on CDB when done, add to ROB, clear from RS

rs_data_t data [ALU_RS_SIZE-1:0] /* synthesis ramstyle = "logic" */;
logic is_in_use [3:0];
logic [ALU_RS_SIZE-1:0] load_alu;

rs_data_t curr_rs_data;

WE NEED TO UPDATE NUM_ENTRIES - YES - NO


always_ff @(posedge clk) begin
    alu_rs_full <= 1'b1;
    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        if(is_in_use[i] == 1'b0)
            alu_rs_full <= 1'b0;
    end

    // TEST THIS CODE;
    // if(!(is_in_use && 4'b1111)) begin
    //     alu_rs_full = 1'b1;
    // end
    
    if(rst || flush) begin
        for(int i = 0; i < ALU_RS_SIZE; ++i) begin
            data[i] <= '{default: 0};
            alu_arr[i] <= '{default: 0};
            is_in_use[i] <= 1'b0;
        end

        load_rob <= 1'b0;
    end 
    else if(load) begin
        curr_rs_data.valid <= 1'b0;
        curr_rs_data.busy <= 1'b0;
        curr_rs_data.opcode <= alu_o.op;
        curr_rs_data.alu_op <= alu_o.op;
        curr_rs_data.rs1.valid <= 1'b0;
        curr_rs_data.rs1.value <= alu_o.vj; // need to fetch from ROB/regfile?
        curr_rs_data.rs1.tag <= alu_o.qj;
        curr_rs_data.rs2.valid <= 1'b0;
        curr_rs_data.rs2.value <= alu_o.vk; // need to fetch from ROB/regfile?
        curr_rs_data.rs2.tag <= alu_o.qk;
        curr_rs_data.res.valid <= 1'b0;
        curr_rs_data.res.value <= 32'b0;
        curr_rs_data.res.tag <= alu_o.rob_idx; // ?

        if(is_in_use[0] == 1'b0) begin
            data[0] <= curr_rs_data;
        end else if(is_in_use[1] == 1'b0) begin
            data[1] <= curr_rs_data;
        end else if(is_in_use[2] == 1'b0) begin
            data[2] <= curr_rs_data;
        end else if(is_in_use[3] == 1'b0) begin
            data[3] <= curr_rs_data;
        end else begin
            alu_rs_full = 1'b1;
        end
    end
end

always_ff @(posedge clk) begin: set_data_vals
    // if is_valid sent as input, iterate though all items and set valid bit high for rs1/rs2

    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        if(is_valid == 1'b1) begin
            if(data[i].rs1.idx == rs_idx_in)
                data[i].rs1.valid = 1'b1;
            if(data[i].rs2.idx == rs_idx_in)
                data[i].rs2.valid = 1'b1;
        end

        // Set valid bit on entry if both inputs are valid
        if(data[i].rs1.valid == 1'b1 && data[i].rs2.valid == 1'b1)
            data[i].valid = 1'b1;


        // Update values from ROB output - TODO
        for(int i = 0; i < RO_BUFFER_ENTRIES; ++i) begin
            if(rob_commit_arr[i] == 1'b1) begin
                for(int i = 0; i < ALU_RS_SIZE; ++i) begin
                    
                end
            end
        end
    end

    for(int i = 0; i < ALU_RS_SIZE; ++i) begin
        // if data[i].valid == 1'b1 then update alu_arr value and set load_rob high 1 cycle later
        load_alu[i] <= 1'b0;
        if(data[i].valid == 1'b1) begin
            alu_arr[i].vj <= data[i].rs1.value.value;
            alu_arr[i].vk <= data[i].rs2.value.value;
            alu_arr[i].qj <= data[i].rs1.tag;
            alu_arr[i].qj <= data[i].rs2.tag;
            alu_arr[i].op <= data[i].alu_op;
            alu_arr[i].rob_idx <= data[i].res.idx;

            load_alu[i] <= 1'b1;

            is_in_use[i] <= 1'b0;
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
            .ready(load_rob[i])
        );
    end
endgenerate

endmodule : reservation_station
