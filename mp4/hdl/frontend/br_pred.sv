module br_pred (
    input logic clk,
    input logic rst,
    input logic i_queue_full,
    output logic branch_pred_pc_sel,
    output logic pc_load,
    input logic mem_resp,
    input logic flush,
    input logic resolve_jal
);

assign branch_pred_pc_sel = 1'b0;
assign pc_load = (~i_queue_full && mem_resp) || flush || resolve_jal;

endmodule : br_pred
