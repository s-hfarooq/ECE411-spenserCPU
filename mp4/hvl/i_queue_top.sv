`include "include/i_queue_itf.sv"
`include "grader/i_queue_grader.sv"
import i_queue_types::*;

module top;

i_queue_itf itf();

grader grd (.*);
testbench tb(.*);

endmodule : top
