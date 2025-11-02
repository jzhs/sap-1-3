//`timescale 1ns / 1ps
`default_nettype none


module tb();

reg clk;
reg sysclk;
reg clken;
reg clken_oop;
reg reset;
wire hlt;
wire [7:0] w_bus;
integer count;

localparam CLKLEN = 4;

always #1 sysclk <= ~sysclk & ~hlt;

always @(posedge sysclk)
begin
  if (count == CLKLEN-1) 
  begin
     clk <= ~clk;
     if (clk == 0)
       clken <= 1;
     else
       clken_oop <= 1;
     count <= 0;
  end else begin
     count <= count + 1;
     clken <= 0;
     clken_oop <= 0;
  end
end  


always #1  sysclk = ~sysclk & ~hlt;


// Make instance of sap1
sap1 SAP(
         .sysclk(sysclk),
         .clken(clken),
         .clken_oop(clken_oop),
         .fp_clear(reset),
         .fp_prog(1'b0),
         .fp_write(1'b0),
         .fp_adr(4'b0000),
         .fp_data(8'b00000000),
         .eo_sel(2'b01),
         .w_bus(w_bus),
         .halt(hlt)
         );

// Pull some data out of the SAP module for debug display         
wire [4:0] tbits = SAP.control.T;
wire [11:0] cword = SAP.control.cword;
//wire pc_en = SAP.pc_en;
//wire ir_en = SAP.ir_en;
//wire mem_en = SAP.mem_en;
//wire a_en = SAP.a_en;
//wire alu_en = SAP.alu_en;
wire [3:0] pc_value = SAP.pc_value;
wire [3:0] marbits = SAP.mar_value;
wire [7:0] membits = SAP.mem_value;
wire [7:0] ir_value = SAP.ir_value;
wire [7:0] a_out = SAP.a_value;
wire [7:0] b_out = SAP.b_value;
wire [7:0] o_out = SAP.o_value;
wire [7:0] eo = SAP.extra_out;

initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars;
  $monitor("time: %t, T=%b, W=%b, PC=%b, MAR=%b" , 
     $time, SAP.control.T, w_bus,
     pc_value,
     marbits
     );
  sysclk = 0;
  clk = 0;
  clken = 0;
  count = 0;
  
  reset = 1;
  #1;
  reset = 0;
  #500;
  $finish;
end

endmodule
