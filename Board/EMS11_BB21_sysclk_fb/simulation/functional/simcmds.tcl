# file: simcmds.tcl

# create the simulation script
vcd dumpfile isim.vcd
vcd dumpvars -m /EMS11_BB21_sysclk_fb_tb -l 0
wave add /
run 50000ns
quit
