// 0-F 
// 10 = blank
// 11 = dash

module x7seg(
  input wire clk,
  input wire clken,
  input wire reset,
  input wire [7:0] byte,
  output reg [6:0] seg,
  output reg [3:0] an,
  output wire dp
);




endmodule