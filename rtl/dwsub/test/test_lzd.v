// For normal operation, set ERR="". To inject error, set ERR=1
// E.g. from command line can add vcs flag +define+ERR=1
`define ERR 0

module test_lzd ();
   wire [9:1] success;

   // test_lzd_W #(7) testo1(success[7]);
   // test_lzd_W #(8) testo1(success[8]);
   // test_lzd_W #(9) testo1(success[9]);

   generate
      genvar i;
      for (i=1; i<=9; i++) begin
         test_lzd_W #(i) test_i(success[i]);
      end
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


module test_lzd_W #(parameter W=8) (output reg success);
    /* example:
        8-BIT TEST
                 a      enc(ff1)      dec
        [000] 00000000    1111     00000000
        [001] 00000001    0111     00000001
        [002] 00000010    0110     00000010
        [003] 00000011    0110     00000010
        [004] 00000100    0101     00000100
        [005] 00000101    0101     00000100
        ...
        [253] 11111101    0000     10000000
        [254] 11111110    0000     10000000
        [255] 11111111    0000     10000000
    */

   // Input1 for DUT(my), gold(DW)
   localparam string a1  = "a";
   localparam int    wa1 = W;
   logic [wa1-1:0]   arg1;    // 4 bits => $size(arg1) = ?2?
   
   // Out1 for DUT(my), gold(DW)
   localparam string o1 = "enc";


   localparam int    no1 = $max(2, $clog2(W)+1);    // E.g. W=(1, 2,3, 4,5,6,7, 8) $size=(1, 2,2, 3,3,3,3, 4)?
   //The following 2-bit expression is connected to 1-bit port "enc" of module 


   // localparam int    no1 = $clog2(W)+1;    // E.g. W=(1, 2,3, 4,5,6,7, 8) $size=(1, 2,2, 3,3,3,3, 4)?
   // The following 1-bit expression is connected to 2-bit port "enc" of module 
   // "DW_lzd", instance "dw".


   wire [no1-1:0]    dw_out1, my_out1;   // When W=4 this wants to be 3
   //wire [5:0]  dw_out1, my_out1;   // When W=4 this wants to be 3


   // Out2 for DUT(my), gold(DW)
   localparam string o2 = "dec";
   localparam int    no2 = W;
   wire [no2-1:0]    dw_out2, my_out2;

   // Purty
   string fmt_header = $sformatf("       %%%1ds   %%%1ds  %%%1ds", wa1, no1, no2);
   string header     = $sformatf(fmt_header, a1, o1, o2);

   string fmt_test = $sformatf("[%%03d]  %%%1db    %%%1db  %%%1db", wa1, no1, no2);
   // initial $display("fmt_test = %s", fmt_test); // DBG

   // DUT vs. gold
   DWSUB_lzd #(W) my(.a(arg1|1'b`ERR),   .enc(my_out1), .dec(my_out2));  // DUT
   DW_lzd    #(W) dw(.a(arg1),           .enc(dw_out1), .dec(dw_out2));  // GOLD

   initial begin
      for (int i=1; i<W; i++) #2000;  // Wait for earlier tests to finish
      $display("\n------------------------------------------------------------------------");
      $display("%1D-BIT TEST BEGINS at time %1t\n", W, $time);
      #1 success = 1;
      // #1 success = W%2;  // Here's another way to inject errors

      $display(header);     // "  a enc  dec"
      for (int bits1=0; bits1<(2**wa1); bits1++) begin
         arg1 = bits1[wa1:0];  // Set input
         #1;                   // Wait for things to settle maybe
         $write({fmt_test, " (dw/GOLD)\n"}, bits1, arg1, dw_out1, dw_out2);
         $write({fmt_test, " (my/DUT)"}, bits1, arg1, my_out1, my_out2);
         
         // Error check
         if (my_out1 != dw_out1) begin
            success = 0;
            $write(" ***ERROR %s ***", o1);
         end
         if (my_out2 != dw_out2) begin
            success = 0;
            $write(" ***ERROR %s ***", o2);
         end
         $write("\n\n");
      end

      // Final report
      if (success)
        $display("SUCCESS: %1d-BIT TEST PASSED", W);
      else
        $display("ERROR: %1d-BIT TEST FAILED; see details above maybe", W);
   end
endmodule
