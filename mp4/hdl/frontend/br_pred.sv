module br_pred (
    input logic clk,
    input logic rst,

    output logic branch_pred_pc_sel
);

assign branch_pred_pc_sel = 1'b0; // pc_out + 4

endmodule : br_pred
