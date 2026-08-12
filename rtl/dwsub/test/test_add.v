// For normal operation, set ERR="". To inject error, set ERR=1
// E.g. from command line can add vcs flag +define+ERR=1
`define ERR 0

module test_add( );
   wire [9:1] success;

   generate
      genvar i;
      for (i=1; i<=9; i++) test_add_W #(i) test_i(success[i]);
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

module test_add_W #(parameter W=4) (output reg success);
   import "DPI-C" function int getpid();  // In case we want different answers every time...

    /* example:
        4-BIT TEST BEGINS at time 6000
        ........................................
                  A    B  CI    SUM  CO
        [000]  0000 0000  0    0000  0 (dw/GOLD)
        [000]  0000 0000  0    0000  0 (my/DUT)
        .....
        [001]  0000 0000  1    0001  0 (dw/GOLD)
        [001]  0000 0000  1    0001  0 (my/DUT)
        .....
        [002]  0000 0001  0    0001  0 (dw/GOLD)
        [002]  0000 0001  0    0001  0 (my/DUT)
        .....
        [345]  1010 1100  1    0111  1 (dw/GOLD)
        [345]  1010 1100  1    0111  1 (my/DUT)
        .....
        [511]  1111 1111  1    1111  1 (dw/GOLD)
        [511]  1111 1111  1    1111  1 (my/DUT)
        ........................................
        SUCCESS: 4-BIT TEST PASSED
     */

   // DUT v. GOLD inputs
   localparam int wa1 = W; logic [wa1-1:0] arg1; localparam string a1  = "A";
   localparam int wa2 = W; logic [wa2-1:0] arg2; localparam string a2  = "B";
   localparam int wa3 = 1; logic           arg3; localparam string a3  = "CI";

   // DUT v. GOLD outputs
   localparam int no1 = W; wire [no1-1:0] dw_out1, my_out1; localparam string o1 = "SUM";
   localparam int no2 = 1; logic          dw_out2, my_out2; localparam string o2 = "CO";

   // Purty
   string fmt_header = $sformatf
          ("       %%%1ds %%%1ds  %%%1ds   %%%1ds  %%%1ds",
           wa1, wa2, wa3, no1, no2);
   string header = $sformatf
          (fmt_header, a1, a2, a3, o1, o2);

   string fmt_test = $sformatf
          ("[%%03d]  %%%1db %%%1db  %%%1db    %%%1db  %%%1db",
           wa1, wa2, wa3, no1, no2);

   // initial $display("fmt_test = %s", fmt_test); // DBG

   // DUT vs. gold
   DWSUB01_add  #(W) my(.A(arg1), .B(arg2), .CI(arg3),           .SUM(my_out1), .CO(my_out2));
   DW01_add     #(W) dw(.A(arg1), .B(arg2), .CI(arg3),           .SUM(dw_out1), .CO(dw_out2));

   initial begin

      // Can do exhaustive tests if W<=3 (10bits' worth of inputs)
      integer max1 = $min(4,W);  // At most 2^4 values for arg1
      integer max2 = $min(5,W);  // At most 2^5 values for arg2
      integer max3 = 1;                // Always one bit regardless of W, see? for arg3

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

                  //arg1 = bits1[wa1:0];  // Set input, then wait a tick
                  arg1 = (W<=max1) ? bits1[wa1:0] : $random(seed)%(2**W);  // Set input
                  arg2 = (W<=max2) ? bits2[wa2:0] : $random(seed)%(2**W);  // Set input
                  arg3 = bits3;  // Always one bit regardless of W, see?
                  #1;
                  // Read results and update testnum
                  $write({fmt_test, " (dw/GOLD)\n"}, testnum, arg1, arg2, arg3,  dw_out1, dw_out2);
                  $write({fmt_test, " (my/DUT)"},    testnum, arg1, arg2, arg3,  my_out1, my_out2);
                  testnum = testnum + 1;

                  // Error check
                  if (my_out1 != dw_out1) begin success = 0; $write(" ***ERROR %s ***", o1); end
                  if (my_out2 != dw_out2) begin success = 0; $write(" ***ERROR %s ***", o2); end
                  $write("\n\n");

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
