// sap1 module 

// It is instantiated in top.v for actual devboard use, and in tb.v for
// simulation.

`default_nettype none 

module sap1(
  input wire sysclk,
  input wire clken,
  input wire clken_oop,
  input	wire fp_clear,
  input wire fp_prog,
  input wire fp_write,
  input wire [3:0] fp_adr,
  input wire [7:0] fp_data,
  output wire [7:0] o_out,
  input wire [1:0] eo_sel,
  output reg [7:0] extra_out,
  output wire [7:0] w_bus,
  output wire halt
);


wire pc_en;
wire pc_incr;
wire [3:0] pc_value;
wire [3:0] pc_next;
assign pc_next = pc_value + 4'b1;

newregister #(.size(4))
pc(
  .sysclk(sysclk),
  .clken(clken),
  .reset(fp_clear),
  .load(pc_incr),
  .data_in(pc_next),
  .value(pc_value) );

assign w_bus[7:0] = (pc_en) ? {4'bZZZZ, pc_value} : 8'bZZZZZZZZ;


wire mar_load;
wire [3:0] mar_value;

newregister #(.size(4))
mar(
  .sysclk(sysclk),
  .clken(clken),
  .reset(fp_clear),
  .load(mar_load),
  .data_in(w_bus[3:0]),
  .value(mar_value) );


wire mem_en;
wire [7:0] mem_value;

RAM
#(.ADDR_WIDTH(4))
mem (
  .clk(sysclk),
  //.clken(clken_oop),
  //.reset(fp_clear),
  .rw(fp_write),
  .addr((fp_prog) ?  fp_adr : mar_value),
  .data_in(fp_data),
  .data_out(mem_value) );

assign w_bus = (mem_en | fp_prog) ? mem_value : 8'bZZZZZZZZ;


wire ir_en;
wire ir_load;
wire [7:0] ir_value;

newregister 
ir(
  .sysclk(sysclk),
  .clken(clken),
  .reset(fp_clear),
  .load(ir_load),
  .data_in(w_bus),
  .value(ir_value) );

assign w_bus[3:0] = ir_en ? ir_value[3:0] : 4'bZZZZ;


wire a_en;
wire a_load;
wire [7:0] a_value;

newregister a(
  .sysclk(sysclk),
  .clken(clken),
  .reset(1'b0),  // has no reset
  .load(a_load),
  .data_in(w_bus),
  .value(a_value) );

assign w_bus = a_en ? a_value : 8'bZZZZZZZZ;

   
wire b_load;
wire [7:0] b_value;

newregister b(
  .sysclk(sysclk),
  .clken(clken),
  .reset(1'b0), // no reset
  .load(b_load),
  .data_in(w_bus),
  .value(b_value) );

   
wire alu_en;
wire [7:0] alu_value;

alu ALU(
  .a(a_value),
  .b(b_value),
  .op(sub),
  .value(alu_value) );

assign w_bus = alu_en ? ALU.value : 8'bZZZZZZZZ;

wire o_load;
wire [7:0] o_value;

newregister o(
   .sysclk(sysclk),
   .clken(clken),
   .reset(fp_clear), // no reset
   .load(o_load),
   .data_in(w_bus),
   .value(o_value) );

assign o_out = o_value;

//// Control unit

//wire [3:0] opcode = ir_value[7:4];
//assign halt = (opcode == 4'b1111);

// Twelve control signals
wire [11:0] cword;

wire sub;

controlunit control(
   .sysclk(sysclk),
   //.clken(),  // unused
   .clken_oop(clken_oop),
   .clear(fp_clear),
   .ir_opc(ir_value[7:4]),
   .cword(cword),
   .halt(halt)
   );


assign pc_en = cword[11];
assign pc_incr = cword[10];
assign mar_load = cword[9];
assign ir_en = cword[8];
assign ir_load = cword[7];
assign mem_en = cword[6];
assign a_en = cword[5];
assign a_load = cword[4];
assign b_load = cword[3];
assign alu_en = cword[2];
assign o_load = cword[1];
assign sub = cword[0];

// Debug helper - set SW[13], SW[12] to get various extra output
always @(posedge sysclk)
begin
    case (eo_sel)
      2'b00 : extra_out <= {7'b0, fp_write};
      2'b01 : extra_out <= {4'b0000, pc_value};
      2'b10 : extra_out <= mem_value;
      2'b11 : extra_out <=  ir_value; //{4'b0, fp_adr}; //{4'b000000, clken, clken_oop, halt, fp_clear};
      default: 
        extra_out = 8'b00000000;
    endcase
end

endmodule
