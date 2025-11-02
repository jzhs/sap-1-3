`default_nettype none 

module newregister
#(parameter size = 8)
(
  input wire sysclk,
  input wire clken,
  input wire reset,
  input wire load,
  input  wire [size-1:0] data_in,
  output reg [size-1:0] value
);

always @(posedge sysclk or posedge reset)
if (reset)
    value <= 0;
else if (clken)
  begin
    if (load)
      value <= data_in;
    else
      value <= value;
  end

endmodule
