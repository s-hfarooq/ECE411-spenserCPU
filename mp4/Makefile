# Copied from MP2

VCS=vcs
VCSFLAGS=-sverilog -timescale=1ns/10ps -full64 -debug_access+all +v2k -nc -lca
VCSGUIFLAGS=-gui -kdb
.DEFAULT_GOAL:= mp4
TESTCODE_SRC=testcode
HVL_SRC=hvl
HDL_SRC=hdl
HDL_DEPS=rv32i_mux_types.sv rv32i_types.sv
MP4_HDL_TOP=mp4.sv
MP4_HDL_DEPS=$(filter-out $(MP4_HDL_TOP) $(HDL_DEPS), $(shell find $(HDL_SRC)/ -type f -name '*.sv' -printf "%f\n" | sort))
MP4_HVL_TOP=source_tb.sv random_tb.sv top.sv
MP4_HVL_DEPS=$(filter-out $(MP4_HVL_TOP), $(shell find $(HVL_SRC)/ -type f -name '*.sv' -printf "%f\n" | sort))

HDL=$(addprefix $(HDL_SRC)/, $(HDL_DEPS)) $(addprefix $(HDL_SRC)/, $(MP4_HDL_DEPS)) $(addprefix $(HDL_SRC)/, $(MP4_HDL_TOP)) 
HVL=$(wildcard $(HVL_SRC)/*.v) $(addprefix $(HVL_SRC)/, $(MP4_HVL_DEPS)) $(addprefix $(HVL_SRC)/, $(MP4_HVL_TOP))

.PHONY: mp4
mp4:
	$(VCS) $(VCSFLAGS) -top mp4_tb $(HDL) $(HVL)

.PHONY: mp4_gui
mp4_gui:
	$(VCS) $(VCSFLAGS) $(VCSGUIFLAGS) -top mp4_tb $(HDL) $(HVL)

.PHONY: clean
clean:
	rm -f *.vcd simv ucli.key
	rm -rf csrc/ simv.daidir/

# vcs -sverilog -timescale=1ns/10ps -top mp4_tb -full64 -debug_access+r +v2k -nc 
# hdl/rv32i_mux_types.sv hdl/rv32i_types.sv hdl/alu.sv hdl/ir.sv hdl/pc_reg.sv hdl/register.sv hdl/cmp.sv hdl/regfile.sv hdl/datapath.sv hdl/control.sv hdl/mp4.sv 
# hvl/tb_itf.sv hvl/memory.sv hvl/rvfimon.v hvl/source_tb.sv hvl/random_tb.sv hvl/top.sv
