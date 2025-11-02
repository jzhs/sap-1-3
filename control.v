module controlunit(
  input wire sysclk,
  input wire clken,
  input wire clken_oop,
  input wire [7:0] ir,
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

assign cword = CROM[T];

initial begin
  AROM[0] =  5'b00100;  // LDA,  4
  AROM[1] =  5'b00111;  // ADD,  7
  AROM[2] =  5'b01011;  // SUB,  11
  AROM[14] = 5'b01111;  // OUT,  15
end

always @(posedge sysclk or posedge clear)
begin
  if (clear | (cword == `NOP))
    T <= 0;
  else if (clken_oop)
  begin
    if (T == 2)
      T <= AROM[ir[7:4]];
    else
      T <= T+1;
  end
end


initial begin
  CROM[0] = `PC_EN | `MAR_LD;  // T1   0xa00
  CROM[1] = `PC_INC;           // T2 
  CROM[2] = `MEM_EN | `IR_LD;  // T3
  // skip #3
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
   
  end
  
  
endmodule 
