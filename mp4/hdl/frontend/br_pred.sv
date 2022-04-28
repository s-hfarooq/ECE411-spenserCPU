module br_pred (
    input logic clk,
    input logic rst,
    input logic i_queue_full,
    output logic branch_prediction,
    output logic pc_load,
    input logic mem_resp,
    input logic flush
);

assign branch_prediction = 1'b0;
assign pc_load = (~i_queue_full && mem_resp) || flush;

endmodule : br_pred
