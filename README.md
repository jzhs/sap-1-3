# sap-1-3
add hex i/o to sap project


# New programming scheme

Put RUN/PROG in PROG position. Ie SW14 to up position.

Hex display goes to 0 _ xx where xx is the current content of addr 0.

Press up/down pushbuttons to cycle through addresses.

To edit enter new byte value on keypaed and press center push
button. Moves automatically to next adr.



# Timing Problem

On reset there is a 16 cycle delay (debouncing) before MANUAL is asserted. During that time
the clocken runs. This causes problems because we expect to be in single step mode
immediately.

For now I have removed the MANUAL debounce logic. Now powerup in step mode is OK. However, turning
stepping on/off is now a potential issue.