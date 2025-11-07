module tb_programming;

reg sysclk;
reg reset;
wire clken;
wire clken2;  // out-of-phase clock enable
wire slowclk;

localparam CLKLEN = 10;

always #1 sysclk <= ~sysclk;

clocken #(.DIVISOR(CLKLEN)) 
clocken1(
   .sysclk(sysclk), 
   .clken(clken), 
   .clken2(clken2), 
   .slowclk(slowclk),
   .reset(reset)
);

reg write;
reg [3:0] adr;
reg [7:0] data;
wire [7:0] value;

RAM
#(.ADDR_WIDTH(4))
mem (
  .clk(sysclk),
  //.clken(clken),
  //.reset(reset),
  .rw(write),
  .addr(adr),
  .data_in(data),
  .data_out(value)
);
initial begin
  sysclk = 0;
  reset = 1;
  #4;
  reset = 0;
  adr = 4'b0;
  #22;
  adr = 4'b1;
  #24;
  data = 8'hff;
  #21;
  write = 1;
  #163;
  write = 0;
  #30;
  adr = 2;
  #60;
  adr = 1;
  #60;
  $finish;  
end

endmodule