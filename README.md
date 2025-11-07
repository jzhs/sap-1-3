# sap-1-3
add hex i/o to sap project


# New programming scheme

Put RUN/PROG (SW14) in up (PROG) position.
Press and release RESET (btnL).

Hex display goes to 0 _ xx where xx is the current content of addr 0.

Press up/down pushbuttons to cycle through addresses.

To edit enter new byte value on keypaed and press WRITE (btnC).  Moves
automatically to next adr.

To run, flip RUN/PROG to RUN and reset.

In order to get Vivado to infer a block ram (rather than a bunch of
flip-flops) I had to remove the initialization of  the memory. This is ok because rams
don't come with built in initializations. So no program is there to begin.

Old initial program is
  0  09
  1  1A
  2  2B
  3  E0
  4  F0
  5  00
  6  00
  7  00
  8  00
  9  0F
  A  0E
  B  01

Answer should be 1C

# Timing Problem

On reset there is a 16 cycle delay (debouncing) before MANUAL is asserted. During that time
the clocken runs. This causes problems because we expect to be in single step mode
immediately.

For now I have removed the MANUAL debounce logic. Now powerup in step mode is OK. However, turning
stepping on/off is now a potential issue.


# Bug: switch PROG to on. Why do I need a reset to see content of mem?