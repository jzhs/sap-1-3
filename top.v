
module top(
  input wire CLOCK_100MHZ, 
  input wire [15:0] SW,  // the sixteen switches
  input wire btnC,  // Write
  input wire btnL,  // Clear
  input wire btnR,  // Step
  //input wire btnU,
  input wire btnD,
  output wire [15:0] LED, // the sixteen LEDs
  output wire [6:0] SEG,
  output wire [3:0] AN,
  output wire DP,
  inout wire [7:0] JB // some are in, some are out
);

wire CLOCK_1KHZ;

wire CLR;
wire CLOCK_MANUAL; // Manual clock (single step)
             // Malvino C25 input pin 2

wire WRITE;
//wire clk;
wire hlt;
wire clken_1khz;
wire clken_1khz_oop; // out of phase
wire clock_1khz;

clocken
clockenable1(
  .sysclk(CLOCK_100MHZ),
  .clken(clken_1khz),
  .clken2(clken_1khz_oop),
  .slowclk(clock_1khz) );
 

wire MANUAL, AUTO;

debounce
manual_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .in(SW[15]),
  .out(MANUAL) );

assign AUTO = ~MANUAL;



wire PROG;
debounce
progrun_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .in(SW[14]),
  .out(PROG) );


debounce
clear_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .in(btnL),
  .out(CLR) );

wire man_clken, man_clken_oop;

debounce
singlestep_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .in(btnR),
  .out(CLOCK_MANUAL),
  .out_rise(man_clken),
  .out_fall(man_clken_oop) );

debounce
readwrite_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .in(btnC),
  .out(WRITE) );

reg [3:0] ADDR;
wire NEXTADR;
debounce
nextadr_deb(
  .clock(CLOCK_100MHZ),
  .clken(clken_1khz),
  .in(btnD),
  .out_rise(NEXTADR) );


always @(posedge CLOCK_100MHZ or posedge CLR)
  if (CLR)
     ADDR <= SW[11:8];
  else if (NEXTADR)
     ADDR <= ADDR + 1;

hexout 
display(
  .clk(CLOCK_100MHZ),
  .clken(clken_1khz),
  .reset(CLR),
  .word({ADDR, 4'b0, pad_byte}),
  .seg(SEG),
  .an(AN),
  .dp(DP)
); 

reg RUN;

always @(posedge CLOCK_100MHZ)
begin
  if (hlt)
    RUN <= 0;
  else if (CLR)
    RUN <= 1;
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
  .out_rise(keypress),
  .out_fall(keyrelease) );
  

reg [8:0] pad_byte;

always @(posedge CLOCK_100MHZ or posedge CLR)
  if (CLR) begin
     pad_byte <= 8'b0;
  end else 
  begin
     if (keypress)
     case (pad_value)
       16'b1000_0000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0001}; // 1
       16'b0000_1000_0000_0000: pad_byte <= {pad_byte[3:0], 4'b0100}; // 4
       16'b0000_0000_1000_0000: pad_byte <= {pad_byte[3:0], 4'b0111}; // 7
       16'b0000_0000_0000_1000: pad_byte <= {pad_byte[3:0], 4'b0000}; // 0
       default: pad_byte <= pad_byte;
     endcase
  end


wire clken, clken_oop;

assign clken = ~hlt & ((clken_1khz & AUTO) | (man_clken & MANUAL));
assign clken_oop = ~hlt & ((clken_1khz_oop & AUTO) | (man_clken_oop & MANUAL));

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
   .fp_data(SW[7:0]),
   //.o_out(LED[7:0]),
   .eo_sel(SW[13:12])
   //.extra_out(LED[15:8]) 
   );

endmodule
