// A 16-byte memory. It is initialized with a simple program
// that produces the output 0x1C on the LEDs. 

`default_nettype none

module memory(
  input wire sysclk,
  input wire clken,
  input wire reset,
  input wire write,
  input	wire [3:0] adr,
  input	wire [7:0] data_in,
  output reg [7:0] value
);

reg [7:0] mem [0:15];
reg here;

always @(posedge sysclk or posedge reset)
if (reset) begin
  here = 1'b0;
  mem[0] =  8'b0000_1001;  // LDA 0x09   0x09     Acc = 0x0f
  mem[1] =  8'b0001_1010;  // ADA 0x0A   0x1a     Acc = 1d
  mem[2] =  8'b0010_1011;  // SUB 0x0B   0x2b     Acc = 1c
  mem[3] =  8'b1110_0000;  // OUT        0xe0    (should be 1c)
  mem[4] =  8'b1111_0000;  // HLT        0xf0
  mem[5] =  8'b0001_0100;
  mem[6] =  8'b0000_0101;
  mem[7] =  8'b0000_0110;
  mem[8] =  8'b0000_0111;
  mem[9] =  8'b0000_1111;   // 0x0F
  mem[10] = 8'b0000_1110;  // 0x0E
  mem[11] = 8'b0000_0001;  // 0x01  
 
end else begin
 if (clken) begin
   if (write) begin
     here = 1'b1;
//     mem[adr] <= data_in;
//     value <= data_in;
   end //else
//     //value <= mem[adr];
 end
  value = mem[adr];  
end

endmodule
