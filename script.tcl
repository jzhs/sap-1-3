# "C:\Xilinx\Vivado\2024.2\bin\vivado.bat"

set 

read_verilog top.v
read_verilog sap1.v
read_verilog memory.v
read_verilog alu.v
read_verilog clocken.v
read_verilog control.v
read_verilog debounce.v
read_verilog hexout.v
read_verilog hexpad.v
read_verilog newreg.v

read_xdc sap_constraints.xdc

synth_design -top top -part xc7a35tcpg236-1
write_verilog -force post_synth.v



   opt_design

   place_design

   route_design

   report_timing_summary

   write_checkpoint top_routed.dcp

   write_bitstream top.bit
