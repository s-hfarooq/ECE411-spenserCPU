`ifndef i_queue_itf
`define i_queue_itf

interface i_queue_itf;
import i_queue_types::*;
bit clk, reset_n, flush_i, read_i, write_i, empty_o, full_o;

word_t data_i, data_o;
time timestamp;

initial begin
    clk = 1'b0;
    forever begin
        #5;
        clk = ~clk;
    end
end

task finish();
    repeat (100) @(posedge clk);
    $finish;
endtask

initial timestamp = 0;
always @(posedge clk) timestamp += 1;

struct {
    logic res [time];
    logic read [time];
} stu_errors;

function automatic void tb_report_dut_error(error_e err);
    case (err)
        RESET_ERROR: stu_errors.res[timestamp] = 1'b1;
        READ_ERROR: stu_errors.read[timestamp] = 1'b1;
        
        default: $fatal("TB reporting Unknown error");
    endcase
endfunction

endinterface 

`endif