import rv32i_types::*;
import structs::*;

module reorder_buffer #(
    parameter entries = 8
)
(
    input logic clk,
    input logic rst,
    input logic flush,
    input logic read,

    // From decoder
    input rv32i_reg rd_i,
    input rv32i_word reg_val_i,

    // To decoder
    output rv32i_word reg_val_o,
    output rv32i_reg reg_o
);

// need to fix entry_num size
rob_values_t rob_arr [entries-1:0];

always_ff @ (posedge clk) begin
    if(rst || flush) begin
        for(int i = 0; i < entries; ++i) begin
            rob_values_t[i] <= '{default: 0};
        end
    end else begin

    end
    
end

endmodule : reorder_buffer
