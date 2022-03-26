`ifndef grader
`define grader

import i_queue_types::*;
module grader(i_queue_itf itf);

initial begin
    $display("GDR: Grader Running");
    repeat (cap_p * 1000) @(posedge itf.clk);
    $display("GDR: Timing Out");
    $finish;
end

final begin
    $display("GDR: Cleaning Up Grading Run...");
end

endmodule : grader
`endif
