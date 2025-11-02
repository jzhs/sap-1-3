
module tb_keypad();

reg sysclk;
reg reset;
reg [3:0] row;
wire [3:0] col;

wire [15:0] value_out;

pmod_hexpad
keypad(
  .clk(sysclk),
  .reset(reset),
  .row(row),
  .col(col),
  .value_out(value_out)

);

wire [19:0] kp_count = keypad.counter;
wire [15:0] kp_press = keypad.value;
reg key4;
always @(*)
  if (key4) begin
    if (col == 4'b0111) 
      row <= 4'b1011;
    else
      row <= 4'b1111;
  end

always #1 sysclk = ~sysclk;

initial begin
  sysclk = 0;
  reset = 1;
  #2;
  reset = 0;
  #2;
  key4 = 1;
  #100;
  key4 = 0;
  #500;
  $finish;
end

endmodule