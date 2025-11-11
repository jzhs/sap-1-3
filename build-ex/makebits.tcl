
# Run with: "C:\Xilinx\Vivado\2024.2\bin\vivado.bat"

read_verilog [glob ../sap-1-3/*.v]
read_xdc ../sap-1-3/sap_constraints.xdc

synth_design -top top -part xc7a35tcpg236-1
write_verilog -force post_synth.v

opt_design
place_design
route_design
report_timing_summary
write_checkpoint -force top_routed.dcp

write_bitstream top.bit
