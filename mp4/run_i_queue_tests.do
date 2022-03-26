
transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work  {./include/i_queue_itf.sv}
vlog -sv -work work  {./include/i_queue_types.sv}
vlog -sv -work work  {./grader/i_queue_grader.sv}
vlog -sv -work work  {./hdl/i_queue.sv}
vlog -sv -work work  {./hvl/i_queue_top.sv}
vlog -sv -work work  {./hvl/i_queue_testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L rtl_work -L work -voptargs="+acc"  top

view structure
view signals
run -all