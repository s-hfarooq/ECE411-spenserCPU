module br_pred (
    input logic clk,
    input logic rst,
    
    input logic i_queue_full,
    input logic take_br,

    output logic branch_pred_pc_sel,
    output logic pc_load,
    input logic mem_resp,
    input logic flush
);

assign branch_pred_pc_sel = 1'b0; // pc_out + 4
// assign pc_load = (~i_queue_full || take_br) && mem_resp;

assign pc_load = (~i_queue_full && mem_resp) || flush;


endmodule : br_pred
