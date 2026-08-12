// We think this is same as DW_01_csa(a, b, c, ci,   carry, sum, co)
// Ish. This one does not work for 1-bit CSA, while the real DW throws a warning.

// For normal operation, set ERR="". To inject error, set ERR=1
// E.g. from command line can add vcs flag +define+ERR=1
`define ERR 0

module test_csa( );
   wire [9:1] success;

   generate
      genvar i;
      for (i=1; i<=9; i++) test_csa_W #(i) test_i(success[i]);
   endgenerate

   initial begin
      for (int i=1; i<=9; i++) #2000;
      $display("\nTests DONE at time %1t\n", $time);
      for (int i=1; i<=9; i++) begin
         if (success[i]) $display("    %1d-bit test PASSED", i);
         else            $display("    %1d-bit test FAILED *** ERROR", i);
      end         
      $display("");
      $finish(0);
   end
endmodule

module test_csa_W #(parameter W=4) (output reg success);
   import "DPI-C" function int getpid();  // In case we want different answers every time...

    /* example:
        3-BIT TEST BEGINS at time 4000

                 a   b   c ci   carry sum  co
        [000]  000 000 000  0    000 000  0 (dw/GOLD)
        [000]  000 000 000  0    000 000  0 (my/DUT)

        [001]  000 000 000  1    000 001  0 (dw/GOLD)
        [001]  000 000 000  1    000 001  0 (my/DUT)

        [002]  000 000 001  0    001 000  0 (dw/GOLD)
        [002]  000 000 001  0    001 000  0 (my/DUT)

        [659]  101 001 001  1    011 101  0 (dw/GOLD)
        [659]  101 001 001  1    011 101  0 (my/DUT)

        [1023] 111 111 111  1    111 111  1 (dw/GOLD)
        [1023] 111 111 111  1    111 111  1 (my/DUT)

        SUCCESS: 3-BIT TEST PASSED
     */
   // DUT v. GOLD inputs
   localparam int wa1 = W; logic [wa1-1:0] arg1; localparam string a1  = "a";
   localparam int wa2 = W; logic [wa2-1:0] arg2; localparam string a2  = "b";
   localparam int wa3 = W; logic [wa3-1:0] arg3; localparam string a3  = "c";
   localparam int wa4 = 1; logic           arg4; localparam string a4  = "ci";

   // DUT v. GOLD outputs
   localparam int no1 = W; wire [no1-1:0] dw_out1, my_out1; localparam string o1 = "carry";
   localparam int no2 = W; wire [no2-1:0] dw_out2, my_out2; localparam string o2 = "sum";
   localparam int no3 = 1; logic          dw_out3, my_out3; localparam string o3 = "co";

   // Purty
   string fmt_header = $sformatf
          ("       %%%1ds %%%1ds %%%1ds %%%1ds   %%%1ds %%%1ds  %%%1ds",
           wa1, wa2, wa3, wa4, no1, no2, no3);
   string header = $sformatf
          (fmt_header, a1, a2, a3, a4, o1, o2, o3);

   string fmt_test = $sformatf
          ("[%%03d]  %%%1db %%%1db %%%1db  %%%1db    %%%1db %%%1db  %%%1db",
           wa1, wa2, wa3, wa4, no1, no2, no3);

   // initial $display("fmt_test = %s", fmt_test); // DBG

   // DUT vs. gold
   DWSUB01_csa  #(W) my(.a(arg1), .b(arg2), .c(arg3), .ci(arg4),   .carry(my_out1), .sum(my_out2), .co(my_out3));
   DW01_csa     #(W) dw(.a(arg1), .b(arg2), .c(arg3), .ci(arg4),   .carry(dw_out1), .sum(dw_out2), .co(dw_out3));

   initial begin

      // Can do exhaustive tests if W<=3 (10bits' worth of inputs)
      integer max1 = $min(3,W);  // At most eight values for arg1
      integer max2 = $min(3,W);  // At most eight values for arg2
      integer max3 = $min(3,W);  // At most eight values for arg3
      integer max4 = 1;          // Always one bit regardless of W, see? for arg4

      integer seed = 0;
      integer testnum = 0;

      for (int i=1; i<W; i++) #2000;  // Wait for earlier tests to finish
      $display("\n------------------------------------------------------------------------");
      $display("%1d-BIT TEST BEGINS at time %1t\n", W, $time);
      #1 success = 1;
      // #1 success = W%2;  // Here's another way to inject errors

      $display(header);

      for (int bits1=0; bits1<(2**max1); bits1++) begin
         for (int bits2=0; bits2<(2**max2); bits2++) begin
            for (int bits3=0; bits3<(2**max3); bits3++) begin
               for (int bits4=0; bits4<(2**max4); bits4++) begin

                  //arg1 = bits1[wa1:0];  // Set input, then wait a tick
                  arg1 = (W<=max1) ? bits1[wa1:0] : $random(seed)%(2**W);  // Set input
                  arg2 = (W<=max2) ? bits2[wa2:0] : $random(seed)%(2**W);  // Set input
                  arg3 = (W<=max3) ? bits3[wa3:0] : $random(seed)%(2**W);  // Set input
                  arg4 = bits4;
                  #1;
                  // Read results and update testnum
                  $write({fmt_test, " (dw/GOLD)\n"}, testnum, arg1, arg2, arg3, arg4,  dw_out1, dw_out2, dw_out3);
                  $write({fmt_test, " (my/DUT)"},    testnum, arg1, arg2, arg3, arg4,  my_out1, my_out2, my_out3);
                  testnum = testnum + 1;

                  // Error check
                  if (my_out1 != dw_out1) begin success = 0; $write(" ***ERROR %s ***", o1); end
                  if (my_out2 != dw_out2) begin success = 0; $write(" ***ERROR %s ***", o2); end
                  if (my_out3 != dw_out3) begin success = 0; $write(" ***ERROR %s ***", o3); end
                  $write("\n\n");

               end // bits4
            end // bits3
         end // bits2
      end // bits1
         
      // Final report
      if (success)
        $display("SUCCESS: %1d-BIT TEST PASSED", W);
      else
        $display("ERROR: %1d-BIT TEST FAILED; see details above maybe", W);
   end
endmodule
