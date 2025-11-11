// Connect Digilent PMOD hex pad

// Drive column pin low and read row pins.

`timescale 1ns / 1ps
`default_nettype none

module pmod_hexpad(
  input wire clk,      // 100 MHz
  input wire reset,
  input wire [3:0] row,
  output reg [3:0] col,
  output reg [15:0] value_out
);

localparam MilliS = 100000;
localparam MicroS = 100;

reg [19:0] counter;
reg [15:0] value;

always @(posedge clk or posedge reset)
begin
  if (reset | (counter == 5*MilliS + 1))
    counter = 0;
  else
    counter = counter + 1;
end

always @(posedge clk)
begin
  case (counter) 
    0 : begin
      value <= 0;
      //value_out <= 0;
    end
    
    1*MilliS : begin
       col <= 4'b0111;
    end
    
    1*MilliS + 1*MicroS: begin
      case (row)
        4'b0111: value <= 16'b1000_0000_0000_0000; // 1
        4'b1011: value <= 16'b0000_1000_0000_0000; // 4
        4'b1101: value <= 16'b0000_0000_1000_0000; // 7
        4'b1110: value <= 16'b0000_0000_0000_1000; // 0
        default: value <= value;
      endcase
    end
    
    2*MilliS : begin
      col <= 4'b1011;
    end
    
    2*MilliS + 1*MicroS: begin
      case (row)
        4'b0111: value <= 16'b0100_0000_0000_0000; // 2
        4'b1011: value <= 16'b0000_0100_0000_0000; // 5
        4'b1101: value <= 16'b0000_0000_0100_0000; // 8
        4'b1110: value <= 16'b0000_0000_0000_0100; // F
        default: value <= value;
      endcase
    end
    
    3*MilliS: begin
      col <= 4'b1101;
    end
    
    3*MilliS + 1*MicroS: begin
      case (row)
        4'b0111: value <= 16'b0010_0000_0000_0000; // 3
        4'b1011: value <= 16'b0000_0010_0000_0000; // 6
        4'b1101: value <= 16'b0000_0000_0010_0000; // 9
        4'b1110: value <= 16'b0000_0000_0000_0010; // E
        default: value <= value;
      endcase
    end
      
    4*MilliS: begin
       col <= 4'b1110;
    end
       
    4*MilliS + 1*MicroS: begin
      case (row)
        4'b0111: value <= 16'b0001_0000_0000_0000; // A
        4'b1011: value <= 16'b0000_0001_0000_0000; // B
        4'b1101: value <= 16'b0000_0000_0001_0000; // C
        4'b1110: value <= 16'b0000_0000_0000_0001; // D
        default: value <= value;
      endcase
    end
    
    5*MilliS:
      //if (value != value_out) begin
        value_out <= value;
      //end
    5*MilliS + 1: begin
      //value_out <= 16'b0;
      //counter <= 16'b0;
    end
  endcase
end
endmodule
