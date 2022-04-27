## Generated SDC file "mp4.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Sat Apr 23 20:22:06 2022"

##
## DEVICE  "EP2AGX45DF25I3"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {clk}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_resp}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_resp}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {rst}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_addr[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_mbe[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_mbe[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_mbe[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_mbe[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_read}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_wdata[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {data_write}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_addr[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {inst_read}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

