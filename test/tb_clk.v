`default_nettype none

module tb_clock;

reg sysclk;
reg reset;
wire clken;
wire clken2;  // out-of-phase clock enable
wire slowclk;

localparam CLKLEN = 8;

always #1 sysclk <= ~sysclk;

clocken #(.DIVISOR(CLKLEN)) 
clocken1(
   .sysclk(sysclk), 
   .reset(reset),
   .clken(clken), 
   .clken2(clken2), 
   .slowclk(slowclk)
);



initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars;
  sysclk = 0;
  reset = 1;
  #4;
  reset = 0;
  #100;
  $finish;
end
endmodule
