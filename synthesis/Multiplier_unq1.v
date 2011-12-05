
module Multiplier_unq1(a,b,out0,out1);
  parameter width=53;
  input  [width-1:0]    a,b;
  output [2*width-1:0] out;

  assign out = a * b;

endmodule

