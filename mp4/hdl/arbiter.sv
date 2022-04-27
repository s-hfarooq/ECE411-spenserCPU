import rv32i_types::*;

module arbiter (
    input clk,
    input rst,
    input logic flush,

    // Memory
    input logic [255:0] mem_rdata,
    output rv32i_word mem_addr,
    input logic mem_resp,
    output logic mem_read,
    output logic mem_write,
    output logic [255:0] mem_wdata,
    
    // Instruction Cache
    input logic inst_read,
    input rv32i_word inst_addr,
    output logic inst_resp,
    output logic [255:0] inst_rdata,
    
    // Data Cache
    input logic data_read,
    input logic data_write,
    input rv32i_word data_addr,
    input logic [255:0] data_wdata,
    output logic data_resp,
    output logic [255:0] data_rdata
);

enum int unsigned {
    idle, icache, dcache
} state, next_state;

/* State Transitions */
always_comb begin
    if(rst) begin
        next_state = idle;
    end else begin
        case (state)
            idle : begin
                if (data_read || data_write)
                    next_state = dcache;
                else if (inst_read)
                    next_state = icache;
                else
                    next_state = idle;
            end

            icache : begin
                if (mem_resp && (data_read || data_write))
                    next_state = dcache;
                else if (~mem_resp || inst_read)
                    next_state = icache;
                else
                    next_state = idle;
            end

            dcache : begin
                if (mem_resp && inst_read)
                    next_state = icache;
                else if (mem_resp)
                    next_state = idle;
                else
                    next_state = dcache;
            end
            default: begin
                next_state = idle;
            end
        endcase
    end
end

/* State Outputs */
always_comb begin
    case (state)
        icache : begin
            inst_rdata = mem_rdata;
            mem_addr = inst_addr;
            inst_resp = mem_resp;
            mem_read = inst_read;
            mem_write = 1'b0;
            mem_wdata = 256'd0;
            data_resp = 1'b0;
            data_rdata = 'b0;
        end

        dcache : begin
            mem_read = data_read;
            mem_write = data_write;
            mem_addr = data_addr;
            mem_wdata = data_wdata;
            data_resp = mem_resp;
            data_rdata = mem_rdata;
            inst_resp = 1'b0;
            inst_rdata = 'b0;
        end

        default : begin // idle
            mem_write = 1'b0;
            mem_read = 1'b0;
            mem_wdata = 'b0;
            mem_addr = 'b0;
            inst_resp = 1'b0;
            inst_rdata = 'b0;
            data_resp = 1'b0;
            data_rdata = 'b0;
        end
    endcase
end

always_ff @ (posedge clk) begin
    if (rst)
        state <= idle;
    else
        state <= next_state;
end

endmodule : arbiter
