`timescale 1ns/1ps
`default_nettype none

module controlunit(
  input wire sysclk,
  //input wire clken,
  input wire clken_oop,
  input wire [3:0] ir_opc,
  input wire clear,
  output wire [11:0] cword,
  output wire halt
);


`define NOP    12'b000000000000
`define PC_EN  12'b100000000000
`define PC_INC 12'b010000000000
`define MAR_LD 12'b001000000000
`define IR_EN  12'b000100000000
`define IR_LD  12'b000010000000
`define MEM_EN 12'b000001000000
`define A_EN   12'b000000100000
`define A_LD   12'b000000010000
`define B_LD   12'b000000001000
`define ALU_EN 12'b000000000100
`define O_LD   12'b000000000010
`define SUB    12'b000000000001

// Address ROM 16x5
reg [4:0] AROM [0:15];

// Control ROM 32x12
reg [11:0] CROM [0:31];
reg [4:0] T;
wire [3:0] opcode;

assign cword = CROM[T];
assign opcode = ir_opc;
assign halt = (opcode == 4'b1111);
always @(posedge sysclk or posedge clear)
begin
  if (clear) begin
    T <= 0; 
    AROM[0] =  4'b0100;  // LDA,  4
    AROM[1] =  4'b0111;  // ADD,  7
    AROM[2] =  4'b1011;  // SUB,  11 (0xD)
    
    AROM[3] = 4'b0000; AROM[4] = 4'b0000; AROM[5] = 4'b0000; AROM[6] = 4'b0000;
    AROM[7] = 4'b0000; AROM[8] = 4'b0000; AROM[9] = 4'b0000; AROM[10] = 4'b0000;
    AROM[11] = 4'b0000; AROM[12] = 4'b0000; AROM[13] = 4'b0000; 
    
    AROM[14] = 4'b1111;  // OUT,  15 (0xF)
    AROM[15] = 4'b0000;
    CROM[0] = `PC_EN | `MAR_LD;  // T1   0xa00
    CROM[1] = `PC_INC;           // T2 
    CROM[2] = `MEM_EN | `IR_LD;  // T3
    // skip #3
    CROM[3] = `NOP;
    CROM[4] = `IR_EN | `MAR_LD;  // LDA T4
    CROM[5] = `MEM_EN | `A_LD;   // LDA T5
    CROM[6] = `NOP;              // LDA T6
  
    CROM[7] = `IR_EN | `MAR_LD;  // ADD T4 
    CROM[8] = `MEM_EN | `B_LD;   // ADD T5
    CROM[9] = `ALU_EN | `A_LD;   // ADD T6
    CROM[10] = `NOP;
  
    CROM[11] = `IR_EN | `MAR_LD;  // SUB T4
    CROM[12] = `MEM_EN | `B_LD;  // SUB T5
    CROM[13] = `SUB | `ALU_EN | `A_LD; // SUB T6
    CROM[14] = `NOP;
    CROM[15] = `A_EN | `O_LD ; // OUT T4
    CROM[16] = `NOP;
    CROM[17] = `NOP; CROM[18] = `NOP; CROM[19] = `NOP;
    CROM[20] = `NOP; CROM[21] = `NOP; CROM[22] = `NOP; CROM[23] = `NOP; 
    CROM[24] = `NOP; CROM[25] = `NOP; CROM[26] = `NOP; CROM[27] = `NOP; 
    CROM[28] = `NOP; CROM[29] = `NOP; CROM[30] = `NOP; CROM[31] = `NOP;
   
  end else if (cword == `NOP)
    T <= 0;
  else if (clken_oop) begin
    if (T == 2)
      T <= {1'b0, AROM[opcode]};
    else
      T <= T+1;
  end
end


endmodule 
