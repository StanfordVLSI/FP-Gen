// We think this is the same functionality as DW01_add(A, B, CI,   SUM, CO)

module DWSUB01_add #(parameter W=8)
   (
    input [W-1:0]  A,
    input [W-1:0]  B,
    input          CI,
    output [W-1:0] SUM,
    output         CO
    );
   wire [W:0] CS;
   assign CS  = A + B + CI;
   assign CO  = CS[W];
   assign SUM = CS[W-1:0];
   //always @(*) $display("FOO%1d %3t A=%h B=%h CO=%h CO==%h SUM=%h", W, $time, A, B, CI, CO, SUM);
endmodule
