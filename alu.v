module alu (
	    input wire [7:0]  a,
	    input wire [7:0]  b,
	    input wire	      op,
	    output wire [7:0] value  
);

assign value = (op ? a - b : a + b);

endmodule	     
