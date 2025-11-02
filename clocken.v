
module clocken
#(parameter DIVISOR = 50000)
(
  input wire sysclk,
  output reg clken,  // rising slowclk
  output reg clken2, // falling slowclk
  output reg slowclk
);


// Input is a fast system clock (eg 100MHz) and a DIVISOR 
// parameter. 
// Output is a slow clock (eg 1 kHz) with a frequency 
//    (1/DIVISOR) * sysclk
// Output clken is a pulse, 1 clock cycle in length, marking
// the rising edge of slowclk. 
// Output clken_oop is a pulse, 1 clock cycle in length,
// marking the falling edge of slowclk.

localparam COUNTER_BITS = $clog2(DIVISOR);
reg [COUNTER_BITS - 1 : 0] count;

initial
begin
  count = 0;
end


always @(posedge sysclk) begin
  if (count == DIVISOR-1) begin
    count <= 0;
    clken <= 1;
    slowclk <= 1;
  end else if (count == (DIVISOR/2)-1) begin
    slowclk <= 0; 
    clken2 <= 1;
    count <= count+1;
  end else
  begin
    count <= count+1;
    clken <= 0;
    clken2 <= 0;
  end
end

endmodule
