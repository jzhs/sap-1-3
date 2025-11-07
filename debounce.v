`timescale 1ns / 1ps
// When input differs from the current output, increment the counter. 
// When counter hits max go ahead and change the output.
// The input has to be different from current output "for
// a long time" to get the output to change. Here a long time means
// something like 20ms. This is enough time for most physical switches to
// settle but still seems instantaneous to human perception.

// So basically 
//    clock_period x MAX_COUNT  <  20ms
// will work for many purposes.  Default is  1ms clock with a MAX_COUNT of 16. 


module debounce
#(
    parameter MAX_COUNT = 16
)
(
    input wire clock,  
    input wire clken,  // a slow (1ms) clock
    input wire reset,
    input wire in,     // noisy input
    output reg out,    // debounced and synched output
    output reg out_rise,
    output reg out_fall
);

localparam COUNTER_BITS = $clog2(MAX_COUNT);

reg [COUNTER_BITS - 1 : 0] counter;


    
always @(posedge clock)
if (reset) begin
  counter = 0;
  out = 0;
  out_rise = 0;
  out_fall = 0;
end else begin
  out_rise <= 0;
  out_fall <= 0;
  if (clken) begin
    if (counter == MAX_COUNT - 1) begin
      out <= in;
      counter <= 0;
      if (in == 1)
        out_rise <= 1;
      else
        out_fall <= 1;
    end else if (in != out) begin
      counter <= counter + 1;  
    end
  end
  
end

endmodule



