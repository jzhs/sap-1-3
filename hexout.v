// Display a byte on 7-segment display


module hexout(
  input wire clk,
  input wire clken,
  input wire reset,
  input wire [15:0] word,
  output reg [6:0] seg,
  output reg [3:0] an
  //output wire dp
);


reg [3:0] nib;
reg [1:0] count;

always @(posedge clk)
  if (clken)
    case (count)
      2'b00 : begin an <= 4'b0111; nib <= word[15:12]; end
      2'b01 : begin an <= 4'b1011; nib <= word[11:8]; end
      2'b10 : begin an <= 4'b1101; nib <= word[7:4]; end
      2'b11 : begin an <= 4'b1110; nib <= word[3:0]; end
    endcase 

// Somehow the seg signals are in the wrong (reverse) order
// g..a rather than a..g??
// 7'b0000000  all on
// 7'b1111111  all off

always @(*)
    case (nib)
      0: seg = 7'b1000000;    // rev
      1: seg = 7'b1111001;    // rev
      2: seg = 7'b0100100;    // rev
      3: seg = 7'b0110000;    // rev
      4: seg = 7'b0011001;    // rev
      5: seg = 7'b0010010;    // rev
      6: seg = 7'b0000010;    // rev
      7: seg = 7'b1111000;    // rev
      8: seg = 7'b0000000;    // sym
      9: seg = 7'b0010000;    // rev
      'hA : seg = 7'b0001000; // sym
      'hB : seg = 7'b0000011; // rev
      'hC : seg = 7'b1000110; // rev
      'hD : seg = 7'b0100001; // rev
      'hE : seg = 7'b0000110; // rev
      'hF : seg = 7'b0001110; // rev
      default: seg = 7'b1111111;
   endcase 
 
  
// Count should go 0, 1, 2, 3, 0, 1, ...
always @(posedge clk or posedge reset)
  if (reset)
    count <= 0;
  else if (clken)
    count <= count+1;

endmodule