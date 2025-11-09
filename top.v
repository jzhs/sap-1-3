`timescale 1ns / 1ps
module top(
  input wire CLOCK_100MHZ, 
  input wire [15:8] SW,  // the sixteen (now 8) switches
  output wire [15:0] LED,
  input wire btnC,  // Write
  input wire btnL,  // Clear
  input wire btnR,  // Step
  input wire btnU,  // ADR--
  input wire btnD,  // ADR++
  output wire [6:0] SEG, 
  output wire [3:0] AN,  
  //output wire DP,      // Decimal Point, unused
  inout wire [7:0] JB // some are in, some are out
  
);

wire CLOCK_1KHZ;
wire CLR;
wire CLOCK_MANUAL; // Manual clock (single step)
             // Malvino C25 input pin 2
wire [7:0] bus;
wire WRITE;
wire hlt;
wire clken_1khz;
wire clken_1khz_oop; // out of phase
wire clock_1khz;
wire clken, clken_oop;
wire [7:0] extra_out;
reg [7:0] pad_byte;
reg [3:0] ADDR;

assign LED[15:8] = extra_out;
assign LED[7:0] = bus;

clocken
clockenable1(
  .sysclk(CLOCK_100MHZ),
  .reset(CLR),
  .clken(clken_1khz),
  .clken2(clken_1khz_oop),
  .slowclk(clock_1khz) );
 
wire MANUAL, AUTO;
assign MANUAL = SW[15];
//debounce
//manual_deb(
//  .clock(CLOCK_100MHZ),
//  .clken(clken_1khz),
//  .reset(CLR),
//  .in(SW[15]),
//  .out(MANUAL) );

assign AUTO = ~MANUAL;

wire PROG;
debounce
progrun_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .reset(CLR),
  .in(SW[14]),
  .out(PROG),
  .out_rise(),
  .out_fall() );

debounce
clear_deb(
  .clock(CLOCK_100MHZ),
  .reset(CLR),
  .clken(clken_1khz),
  .in(btnL),
  .out(CLR),
  .out_rise(),
  .out_fall() );

wire man_clken, man_clken_oop;

debounce
singlestep_deb(
  .clock(CLOCK_100MHZ),
  .reset(CLR),
  .clken(clken_1khz),
  .in(btnR),
  .out(CLOCK_MANUAL),
  .out_rise(man_clken),
  .out_fall(man_clken_oop) );

wire writepress;

debounce
readwrite_deb(
  .clock(CLOCK_100MHZ),
  .reset(CLR),
  .clken(clken_1khz),
  .in(btnC),
  .out(writepress),
  .out_rise(),
  .out_fall() );
  
assign WRITE = PROG & writepress;

wire NEXTUP, NEXTDOWN;
debounce
nextadr_deb(
  .clock(CLOCK_100MHZ),
  .reset(CLR),
  .clken(clken_1khz),
  .in(btnD),
  .out(),
  .out_rise(NEXTUP),
  .out_fall(NEXTDOWN) );

wire PREVUP, PREVDOWN;
debounce
prevadr_deb(
  .clock(CLOCK_100MHZ),
  .reset(CLR),
  .clken(clken_1khz),
  .in(btnU),
  .out(),
  .out_rise(PREVUP),
  .out_fall(PREVDOWN) );


always @(posedge CLOCK_100MHZ)
  if (CLR)
     ADDR <= SW[11:8];
  else if (NEXTUP)
  begin
     ADDR = ADDR + 1;
  end
  else if (PREVUP)
  begin
     ADDR = ADDR - 1;
  end


wire [7:0] out;
wire [15:0] word;

assign word = PROG ? {ADDR, 4'b0, pad_byte} : out;

hexout 
display(
  .clk(CLOCK_100MHZ),
  .clken(clken_1khz),
  .reset(CLR),
  .word(word),
  .seg(SEG),
  .an(AN)
  //.dp(DP)
); 
  

reg RUN;

always @(posedge CLOCK_100MHZ)
begin
  if (hlt)
    RUN <= 1'b0;
  else if (CLR)
    RUN <= 1'b1;
end

wire [15:0] pad_value;

pmod_hexpad
pad(
  .clk(CLOCK_100MHZ),
  .reset(CLR),
  .row(JB[7:4]),
  .col(JB[3:0]),
  .value_out(pad_value)
);

wire key = | pad_value;
wire keypress;
wire keyrelease;

debounce
keypress_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .reset(CLR),
  .in(key),
  .out(),
  .out_rise(keypress),
  .out_fall(keyrelease) );
  

always @(posedge CLOCK_100MHZ)
  if (CLR) begin
     pad_byte <= bus;
  end else if (NEXTDOWN | PREVDOWN)
     pad_byte <= bus;
  else begin
     if (keypress)
     case (pad_value)
       16'b1000_0000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0001}; // 1
       16'b0000_1000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0100}; // 4
       16'b0000_0000_1000_0000: pad_byte <= {pad_byte[3:0], 4'b0111}; // 7
       16'b0000_0000_0000_1000: pad_byte <= {pad_byte[3:0], 4'b0000}; // 0
       16'b0100_0000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0010}; // 2
       16'b0000_0100_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0101}; // 5
       16'b0000_0000_0100_0000: pad_byte <= {pad_byte[3:0], 4'b1000}; // 8
       16'b0000_0000_0000_0100: pad_byte <= {pad_byte[3:0], 4'b1111}; // F
       
       16'b0010_0000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0011}; // 3
       16'b0000_0010_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0110}; // 6
       16'b0000_0000_0010_0000: pad_byte <= {pad_byte[3:0], 4'b1001}; // 9
       16'b0000_0000_0000_0010: pad_byte <= {pad_byte[3:0], 4'b1110}; // E

       16'b0001_0000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b1010}; // A
       16'b0000_0001_0000_0000: pad_byte <= {pad_byte[3:0], 4'b1011}; // B
       16'b0000_0000_0001_0000: pad_byte <= {pad_byte[3:0], 4'b1100}; // C
       16'b0000_0000_0000_0001: pad_byte <= {pad_byte[3:0], 4'b1101}; // D

       default: pad_byte <= pad_byte;
     endcase
  end


assign clken = (clken_1khz & AUTO) | (man_clken & MANUAL);
assign clken_oop = (clken_1khz_oop & AUTO) | (man_clken_oop & MANUAL);

// Instantiate the sap1 core, connect to board 

sap1 SAP(
   .sysclk(CLOCK_100MHZ),
   .clken(RUN & clken),
   .clken_oop(RUN & clken_oop),
   .fp_clear(CLR),
   .fp_prog(PROG),
   .halt(hlt),
   .fp_write(WRITE),
   .fp_adr(ADDR),
   .fp_data(pad_byte),
   .w_bus(bus),
   .o_out(out),
   .eo_sel(SW[13:12]),
   .extra_out(extra_out) 
   );

endmodule
