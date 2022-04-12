module br_pred (
    input logic clk,
    input logic rst,

    output logic branch_pred_pc_sel,
    output logic pc_load
);

assign branch_pred_pc_sel = 1'b0; // pc_out + 4
assign pc_load = 1'b1;

endmodule : br_pred
