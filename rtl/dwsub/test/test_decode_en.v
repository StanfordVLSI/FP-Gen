// For normal operation, set ERR="". To inject error, set ERR=1
// E.g. from command line can add vcs flag +define+ERR=1
`define ERR 0

module test_decode_en ();
   wire [9:1] success;

   // test_decode_en_W #(1) testo1(success);
   // test_decode_en_W #(4) testo4(success);

   generate
      genvar i;
      for (i=1; i<=9; i++) begin
         test_decode_en_W #(i) test_i(success[i]);
      end
   endgenerate
   
   initial begin
      //for (int i=1; i<(1+2+3+4+5+6+7+8+9); i++) #2000;
      for (int i=1; i<=9; i++) #2000;
      $display("Tests DONE at time %1t", $time);
      for (int i=1; i<=9; i++) begin
         if (success[i]) $display("%1d-bit test PASSED", i);
         else            $display("%1d-bit test FAILED *** ERROR", i);
      end         
      $display("");
      $finish(0);
   end
endmodule

module test_decode_en_W #(parameter W=4) (output reg success);

   // Input1 for DUT(my), gold(DW)
   localparam string a1  = "en";
   localparam int    wa1 = 1;
   logic [wa1-1:0]   arg1;
   
   // Input2 for DUT(my), gold(DW)
   localparam string a2 = "a";
   localparam int    wa2 = W;
   logic [wa2-1:0]   arg2;

   // Out1 for DUT(my), gold(DW)
   localparam string o1 = "b";
   localparam int    no1 = 2**W;
   wire [no1-1:0]    dw_out1, my_out1;

   string fmt_header = $sformatf("      %%%1ds %%%1ds %%%1ds %%%1ds", wa1, wa2, no1, no1);
   string header     = $sformatf(fmt_header, a1, a2, {o1,".GOLD"}, {o1,".DUT"});

   string fmt_test = $sformatf("[%%03d]  %%%1db %%%1db %%%1db %%%1db", wa1, wa2, no1, no1);
   // initial $display("fmt_test = %s", fmt_test); // DBG

   // DUT vs. gold
   DWSUB_decode_en #(W) my(.en(arg1), .a(arg2|1'b`ERR), .b(my_out1));  // DUT
   DW_decode_en    #(W) dw(.en(arg1), .a(arg2),         .b(dw_out1));  // GOLD

   initial begin
      for (int i=1; i<W; i++) #2000;
      $display("\n\n------------------------------------------------------------------------");
      $display("%1D-BIT TEST BEGINS at time %1t", W, $time);
      #1 success = 1;
      // #1 success = W%2;  // Here's another way to inject errors
      //$display("\n\n%1d-BIT TEST", W);
      $display(header);

      for (int bits1=0; bits1<(2**wa1); bits1++) begin
         for (int bits2=0; bits2<(2**wa2); bits2++) begin
            arg1 = bits1[wa1:0];
            arg2 = bits2[wa2:0];
            #1;
            $write(fmt_test, bits1*(2**wa2)+bits2, arg1, arg2, dw_out1, my_out1);
            if (my_out1 != dw_out1) begin
               success = 0;
               $write(" ***ERROR***");
            end
            $write("\n");
         end
         $write("\n");
      end

      if (success)
        $display("SUCCESS: %1d-BIT TEST PASSED\n", W);
      else
        $display("ERROR: %1d-BIT TEST FAILED; see details above maybe\n", W);
//      $display("------------------------------------------------------------------------");
   end
endmodule
