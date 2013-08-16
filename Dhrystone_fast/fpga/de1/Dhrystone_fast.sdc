## Generated SDC file "Dhrystone_fast.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.0 Build 232 07/05/2012 Service Pack 1 SJ Web Edition"

## DATE    "Fri Aug 16 00:35:28 2013"

##
## DEVICE  "EP2C20F484C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clock_50} -period 20.00 [get_ports {CLOCK_50}]

#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

# UART_RXD, KEY and SW are asynchronous, so we set false paths for those.
set_false_path -from [get_ports {UART_RXD KEY* SW*}] -to {VirtualToplevel:myVirtualToplevel|*}

#**************************************************************
# Set Multicycle Path
#**************************************************************

# The result from the hardware multiplier isn't used for two clocks, so we set a multicycle for that.
set_multicycle_path -from {VirtualToplevel:myVirtualToplevel|Dhrystone_fast_ROM:myrom|*} -through *Mult0* -to {VirtualToplevel:myVirtualToplevel|zpu_core:zpu|mem*} -setup -end 2
set_multicycle_path -from {VirtualToplevel:myVirtualToplevel|Dhrystone_fast_ROM:myrom|*} -through *Mult0* -to {VirtualToplevel:myVirtualToplevel|zpu_core:zpu|mem*} -hold -end 2



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

