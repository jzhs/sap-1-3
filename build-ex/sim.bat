@ set XILINX_VIVADO=C:\Xilinx\Vivado\2024.2
@ set PATH=%XILINX_VIVADO%\bin;%PATH%

set SOURCE=..\sap-1-3

echo sim.bat COMPILING...
rem these commands produce .sdb files, and others, in a directory .\xsim.dir\work
call xvlog %SOURCE%\alu.v
call xvlog %SOURCE%\clocken.v
call xvlog %SOURCE%\control.v
call xvlog %SOURCE%\debounce.v
call xvlog %SOURCE%\hexout.v
call xvlog %SOURCE%\hexpad.v
call xvlog %SOURCE%\memory.v
call xvlog %SOURCE%\newreg.v
call xvlog %SOURCE%\sap1.v
call xvlog %SOURCE%\top.v
call xvlog %SOURCE%\test\tb.v

echo sim.bat ELABORATING

rem this creates and populates a directory .\my_snapshot
call xelab -top tb -snapshot my_snapshot -debug all


rem use this to run w/o waveforms: 
rem call xsim my_snapshot -R
echo sim.bat SIMULATING

rem use for waveforms:
call xsim my_snapshot -tclbatch xsim_cfg.tcl


echo sim.bat DISPLAYING WAVEFORMS
echo When vivado starts, open waveform window.
call xsim --gui my_snapshot.wdb

rem vivado -mode batch -nojournal -nolog -notrace -source <myscript.tcl> -tclargs [myscript_arguments]
