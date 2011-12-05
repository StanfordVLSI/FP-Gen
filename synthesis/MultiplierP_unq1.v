
module MultiplierP_unq1(a,b,out0,out1);
  parameter width=53;
  input  [width-1:0]    a,b;
  output [2*width+1:0] out0,out1;

								  
DW02_multp #(width, width, 2*width+2, 3) U1 ( .a(a), .b(b),.tc(1'b0), .out0(out0), .out1(out1) );

endmodule

