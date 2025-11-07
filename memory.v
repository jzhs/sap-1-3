`timescale 1ns / 1ps
`default_nettype none

module RAM
#(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8)
(
  input wire clk, 
  input wire rw, 
  input wire [ADDR_WIDTH-1:0] addr, 
  input wire [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

integer i;

always @(negedge clk) begin
    if( rw == 1 )
        mem[addr] <= data_in;
    data_out = mem[addr];
end
endmodule  