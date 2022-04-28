import rv32i_types::*;

module arbiter (
    input clk,
    input rst,
    input logic flush,

    // To/from cacheline adaptor
    input logic [255:0] cacheline_adaptor_mem_rdata,
    output rv32i_word cacheline_adaptor_mem_addr,
    input logic cacheline_adaptor_mem_resp,
    output logic cacheline_adaptor_mem_read,
    output logic cacheline_adaptor_mem_write,
    output logic [255:0] cacheline_adaptor_mem_wdata,
    
    // Instruction Cache
    input logic i_cache_arbiter_read,
    input rv32i_word i_cache_arbiter_address,
    output logic i_cache_arbiter_resp,
    output logic [255:0] i_cache_arbiter_rdata,
    
    // Data Cache
    input logic d_cache_arbiter_read,
    input logic d_cache_arbiter_write,
    input rv32i_word d_cache_arbiter_address,
    input logic [255:0] d_cache_arbiter_wdata,
    output logic d_cache_arbiter_resp,
    output logic [255:0] d_cache_arbiter_rdata
);

enum int unsigned {
    idle, icache, dcache
} state, next_state;

/* State Transitions */
always_comb begin
    if (rst) begin
        next_state = idle;
    end else begin
        case (state)
            idle : begin
                if (d_cache_arbiter_read || d_cache_arbiter_write)
                    next_state = dcache;
                else if (i_cache_arbiter_read)
                    next_state = icache;
                else
                    next_state = idle;
            end

            icache : begin
                if (cacheline_adaptor_mem_resp && (d_cache_arbiter_read || d_cache_arbiter_write))
                    next_state = dcache;
                else if (~cacheline_adaptor_mem_resp || i_cache_arbiter_read)
                    next_state = icache;
                else
                    next_state = idle;
            end

            dcache : begin
                if (cacheline_adaptor_mem_resp && i_cache_arbiter_read)
                    next_state = icache;
                else if (cacheline_adaptor_mem_resp)
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
            i_cache_arbiter_rdata = cacheline_adaptor_mem_rdata;
            cacheline_adaptor_mem_addr = i_cache_arbiter_address;
            i_cache_arbiter_resp = cacheline_adaptor_mem_resp;
            cacheline_adaptor_mem_read = i_cache_arbiter_read;
            cacheline_adaptor_mem_write = 1'b0;
            cacheline_adaptor_mem_wdata = 256'd0;
            d_cache_arbiter_resp = 1'b0;
            d_cache_arbiter_rdata = 'b0;
        end

        dcache : begin
            cacheline_adaptor_mem_read = d_cache_arbiter_read;
            cacheline_adaptor_mem_write = d_cache_arbiter_write;
            cacheline_adaptor_mem_addr = d_cache_arbiter_address;
            cacheline_adaptor_mem_wdata = d_cache_arbiter_wdata;
            d_cache_arbiter_resp = cacheline_adaptor_mem_resp;
            d_cache_arbiter_rdata = cacheline_adaptor_mem_rdata;
            i_cache_arbiter_resp = 1'b0;
            i_cache_arbiter_rdata = 'b0;
        end

        default : begin // idle
            cacheline_adaptor_mem_write = 1'b0;
            cacheline_adaptor_mem_read = 1'b0;
            cacheline_adaptor_mem_wdata = 'b0;
            cacheline_adaptor_mem_addr = 'b0;
            i_cache_arbiter_resp = 1'b0;
            i_cache_arbiter_rdata = 'b0;
            d_cache_arbiter_resp = 1'b0;
            d_cache_arbiter_rdata = 'b0;
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
