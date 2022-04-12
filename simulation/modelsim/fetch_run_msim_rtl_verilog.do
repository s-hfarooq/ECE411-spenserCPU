transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/br_pred.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/rv32i_types.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/pc_reg.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/structs.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/mp4.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/i_queue.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/i_fetch.sv}

vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/magic_dual_port.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/param_memory.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/rvfi_itf.sv}
vlog -vlog01compat -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/rvfimon.v}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/shadow_memory.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/source_tb.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/tb_itf.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/top.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  mp4_tb

add wave *
view structure
view signals
run 1000 ns
