transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/rv32i_mux_types.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/rv32i_types.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/structs.sv}
vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hdl {/home/tvitkin2/spenserCPU/mp4/hdl/reservation_station.sv}

vlog -sv -work work +incdir+/home/tvitkin2/spenserCPU/mp4/hvl {/home/tvitkin2/spenserCPU/mp4/hvl/reservation_station_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  reservation_station_tb

add wave *
view structure
view signals
run -all
