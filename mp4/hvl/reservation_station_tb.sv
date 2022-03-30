// any verifiers 
// O/

// Copied from MP1 fifo

import rv32i_types::*;
import structs::*;
parameter s_index = 3;
module reservation_station_tb();
    timeunit 10ns;
    timeprecision 1ns;

    // Inputs
logic clk;
logic rst;
logic read;
logic load;
logic [s_index-1:0] rindex;
logic [s_index-1:0] windex;
rs_data_t datain;
    
// Outputs
rs_data_t dataout;

reservation_station dut(.*);

// Clock Synchronizer for Student Use
default clocking tb_clk @(negedge clk); endclocking

always begin
    #1 clk = ~clk;
end

initial begin
    clk = 0;
end

task reset();
    ##1;
    rst <= 1'b1;
    read <= 1'b0;
    load <= 1'b0;
    rindex <= '0;
    windex <= '0;
    datain <= '{default: 0};

    ##1;
    rst <= 1'b0;
    ##1;
endtask : reset



initial begin : TESTS
    $display("Starting reservation station tests...");
    reset();
    ##5;
    datain.opcode = op_auipc;

    datain.rs1.ready = 1'b0;
    datain.rs1.idx = 1'b0;
    datain.rs1.value = 32'hFFFFFFFF;

    datain.rs2.ready = 1'b0;
    datain.rs2.idx = 1'b0;
    datain.rs2.value = 32'hCCCCCCCC;

    datain.res.ready = 1'b0;
    datain.res.idx = 1'b0;
    datain.res.value = 32'hAAAAAAAA;


    ##5;
    reset();
    ##1;



    /***************************************************************/
    $display("Finished reservation station tests");
    $finish();
    $error("TB: Illegal Exit ocurred");
end
endmodule
