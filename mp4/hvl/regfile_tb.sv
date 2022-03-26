typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;

module testbench();

timeunit 10ns;

timeprecision 1ns;

logic clk = 0;
logic rst;
logic flush;

// From decoder
logic load_tag;
rv32i_reg tag_decoder;
rv32i_word rs1_in;
rv32i_word rs2_in;
rv32i_reg reg_id_decoder;

// From ROB
logic load_reg;
rv32i_reg reg_id_rob;
rv32i_word reg_val;
rv32i_reg tag_rob;

// To reservation stations
rv32i_word vj_out;
rv32i_word vk_out;
rv32i_reg qj_out;
rv32i_reg qk_out;

rv32i_word reg1_val, reg2_val, reg3_val, reg4_val, reg5_val, reg6_val, reg7_val, reg8_val,
			  reg9_val, reg10_val, reg11_val, reg12_val, reg13_val, reg14_val, reg15_val, reg16_val, 
			  reg17_val, reg18_val, reg19_val, reg20_val, reg21_val, reg22_val, reg23_val, reg24_val,
			  reg25_val, reg26_val, reg27_val, reg28_val, reg29_val, reg30_val, reg31_val;

regfile rf(.*);

always begin : CLOCK_GENERATION
	#1 clk = ~clk;
end

initial begin: CLOCK_INITIALIZATION
	clk = 0;
end

// Register values
//logic [31:0] answer = rf.regfile[1];

// default clocking tb_clk @(negedge clk); endclocking

task reset();
    rst <= 1'b1;
    #(8);
    rst <= 1'b0;
    #(1);
endtask : reset

// DO NOT MODIFY CODE ABOVE THIS LINE

initial begin
    reset();
    /************************ Your Code Here ***********************/
    #(3);
	 reg_val <= 32'd5;
	 reg_id_rob <= 5'd1;
	 #(2);
	 load_reg <= 1'b1;
	 #(2);
	 reg_val <= 32'd102;
	 reg_id_rob <= 5'd2;
	 #(2);

    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    $finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule
