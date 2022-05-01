module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;
typedef logic [$clog2(9)-1:0] tag_t;


typedef enum bit [6:0] {
    op_lui   = 7'b0110111, //load upper immediate (U type)
    op_auipc = 7'b0010111, //add upper immediate PC (U type)
    op_jal   = 7'b1101111, //jump and link (J type)
    op_jalr  = 7'b1100111, //jump and link register (I type)
    op_br    = 7'b1100011, //branch (B type)
    op_load  = 7'b0000011, //load (I type)
    op_store = 7'b0100011, //store (S type)
    op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011, //arith ops with register operands (R type)
    op_csr   = 7'b1110011  //control and status register (I type)
} rv32i_opcode;

typedef struct packed {
    rv32i_word pc;
    rv32i_word next_pc;
    rv32i_word instr;
} i_queue_data_t;

typedef struct packed {
    rv32i_word instr_pc;
    rv32i_opcode opcode;
    rv32i_reg rd;
    rv32i_word instr;
} i_decode_opcode_t;

typedef struct packed {
    rv32i_word value;
    logic can_commit;
} rob_reg_data_t;

typedef struct packed {
    tag_t tag;
    logic valid;
    i_decode_opcode_t op;
    rob_reg_data_t reg_data;
    rv32i_word target_pc;
} rob_values_t;

typedef struct packed {
    logic valid;
    rv32i_word value;
    tag_t tag;
} rs_reg_t;
/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2



rob_values_t rob_head;
assign rob_head = dut.rob.rob_arr[dut.rob.head_ptr];
// The following signals need to be set:
rv32i_word instr;
assign instr = rob_head.op.instr;

// Instruction and trap:
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO
assign rvfi.halt = dut.i_fetch.pc_load & (rob_head.op.instr_pc == rob_head.target_pc);   // Set high when you detect an infinite loop
assign rvfi.inst = instr;
assign rvfi.trap = 0;
assign rvfi.commit = dut.rob.is_committing; // Set high when a valid instruction is modifying regfile or PC

// Regfile:
assign rvfi.rs1_addr = instr[19:15];
assign rvfi.rs2_addr = instr[24:20];
assign rvfi.rs1_rdata = dut.reg_file.regfile[instr[19:15]];
assign rvfi.rs2_rdata = dut.reg_file.regfile[instr[24:20]];
assign rvfi.load_regfile = dut.rob_is_committing == 1'b1 && dut.rob_o.op.rd != 0;
assign rvfi.rd_addr = rob_head.op.rd;
assign rvfi.rd_wdata = (rob_head.reg_data.can_commit == 1'b1) ? rob_head.reg_data.value : 0;
// PC:
assign rvfi.pc_rdata = rob_head.op.instr_pc;
assign rvfi.pc_wdata = (dut.i_fetch.take_br == 1) ? rob_head.target_pc : rob_head.op.instr_pc + 4;

// Memory:
assign rvfi.mem_addr = dut.d_cache_mem_addr;
assign rvfi.mem_rmask = 4'hF;
assign rvfi.mem_wmask = dut.d_cache_byte_enable;
assign rvfi.mem_rdata = dut.d_cache_mem_rdata;
assign rvfi.mem_wdata = dut.d_cache_mem_wdata;

// Please refer to rvfi_itf.sv for more information.



    // logic halt;
    // logic commit;
    // logic [63:0] order;
    // logic [31:0] inst;
    // logic trap;
    // logic [4:0] rs1_addr;
    // logic [4:0] rs2_addr;
    // logic [31:0] rs1_rdata;
    // logic [31:0] rs2_rdata;
    // logic load_regfile;
    // logic [4:0] rd_addr;
    // logic [31:0] rd_wdata;
    // logic [31:0] pc_rdata;
    // logic [31:0] pc_wdata;
    // logic [31:0] mem_addr;
    // logic [3:0] mem_rmask;
    // logic [3:0] mem_wmask;
    // logic [31:0] mem_rdata;
    // logic [31:0] mem_wdata;

    // logic [15:0] errcode;

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = '{default: '0};

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

// halt logic wrong - when this is true, we might not be fully done, may have just fetched instruction (still need to execute)
// logic halt;
// assign halt = dut.i_fetch.pc_load & (dut.i_fetch.pc_out == dut.i_fetch.pc_in);

// always @(posedge itf.clk) begin
//     if (halt)
//         $finish;
// end

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),
    .mem_rdata(itf.mem_rdata),
    .mem_addr(itf.mem_addr),
    .mem_resp(itf.mem_resp),
    .mem_read(itf.mem_read),
    .mem_write(itf.mem_write),
    .mem_wdata(itf.mem_wdata)
);

/***************************** End Instantiation *****************************/

endmodule
