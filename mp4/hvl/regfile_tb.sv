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

	// Load Tags
	load_tag <= 1'b1;
	#(2);
	for (int i = 0; i < 32; i = i + 2) begin
		tag_decoder <= i;
		reg_id_decoder <= i;
		#(2);
	end
	load_tag <= 1'b0;

	// Tests loading registers and clearing tags during commits
	 reg_val <= 32'd42;
	 reg_id_rob <= 5'd0;	// Not supposed to load into register 0
	 #(2);
	 load_reg <= 1'b1;
	 #(2);
	for (int i = 1; i < 32; ++i) begin
		reg_val <= i;
		reg_id_rob <= i;
		tag_rob <= i;
		#(2);
	end
	load_reg <= 1'b0;
	reset();
	#(3);
    /***************************************************************/
    // Make sure your test bench exits by calling itf.finish();
    $finish();
    $error("TB: Illegal Exit ocurred");
end

endmodule
