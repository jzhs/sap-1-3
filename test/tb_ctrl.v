`default_nettype none


module tb_control();

reg sysclk;
reg clk; 
reg clken;
reg clken_oop;
reg clear;
integer count;
localparam CLKLEN = 4;

always #1 sysclk <= ~sysclk ;

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



reg [7:0] ir;

wire [3:0] CU_counter = CU.T;
wire [11:0] cword = CU.cword;

wire pc_en;
wire pc_incr;
wire mar_load;

wire ir_en, ir_load;
wire mem_en;
wire a_en;
wire a_load;

controlunit CU(
  .sysclk(sysclk),
  .clken(clken),
  .clken_oop(clken_oop),
  .clear(clear),
  .ir(ir),
  .pc_en(pc_en),
  .pc_incr(pc_incr),
  .mar_load(mar_load),
  .ir_en(ir_en),
  .ir_load(ir_load),
  .mem_en(mem_en),
  .a_en(a_en),
  .a_load(a_load)
);

wire [5:0] T = CU.T;

initial begin
   clear = 1;
   sysclk = 0;
   count = 0;
   clk = 0;
   #1;
   clear = 0;
   #1;
   ir = 8'b00001001;
   
   #200;
   $finish;  
end

endmodule
