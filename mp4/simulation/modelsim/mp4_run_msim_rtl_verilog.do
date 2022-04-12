transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/frontend {/home/tvitkin2/spenserCPU/mp4/hdl/frontend/br_pred.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/macros.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/rv32i_types.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/cmp.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/alu.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/frontend {/home/tvitkin2/spenserCPU/mp4/hdl/frontend/pc_reg.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/structs.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/regfile.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/load_store_queue.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/cmp_rs.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/alu_rs.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/execute {/home/tvitkin2/spenserCPU/mp4/hdl/execute/ro_buffer.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/frontend {/home/tvitkin2/spenserCPU/mp4/hdl/frontend/i_queue.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/frontend {/home/tvitkin2/spenserCPU/mp4/hdl/frontend/i_fetch.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl/frontend {/home/tvitkin2/spenserCPU/mp4/hdl/frontend/i_decode.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/mp4.sv}

vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/tb_itf.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/top.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/magic_dual_port.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/param_memory.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/rvfi_itf.sv}
vlog -vlog01compat -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/rvfimon.v}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/shadow_memory.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/source_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  mp4_tb

add wave *
view structure
view signals
run 2000 ns
