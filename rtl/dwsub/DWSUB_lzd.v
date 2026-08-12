// We think this is the same functionality as DW_lzd(a, dec,    b)

// It's like a one-hot thing, right? Combined with a find-first-one like
// The opposite of DW_encode_en maybe, i.e decoder instead of encoder.
// Something like (found by blakc-box test)
/*
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

function int my_max(input int a, input int b);
   my_max = (a>b) ? a : b;
endfunction

module DWSUB_lzd #(parameter W=8)
   (
    `define ENCWIDTH  my_max(1,$clog2(W))

    input [W-1:0]         a,   // One-hot array (sh)
    output [ `ENCWIDTH:0] enc, // First "1"
    output [W-1:0]        dec  // Decoded array
    );

   wire [  `ENCWIDTH:0] ff1     [W];
   wire [W-1:0]         specdec [W];

   // If "a" is all zeroes, the answer is all ones; else maybe (W-1) leading zeroes?
   assign ff1[0]     = a[W-1:0] ? (W-1) : {W{1'b1}};
   assign specdec[0] = a[W-1:0] ? 1     : 0;
   
   // Find how many leading zeroes in a number; e.g. if a="001011", ff1="2"
   // As a side effect, go ahead and calculate "dec" using successive "specdec" approzimations.
   generate
      genvar i;
      for (i=1; i<W; i++) begin
         // If top n bits are zero, answer is prev ff1; else speculatively set to (n-1) like
         assign ff1[i]     = a[W-1:i] ? (W-1-i) : ff1[i-1];
         assign specdec[i] = a[W-1:i] ? (1<<i)  : specdec[i-1];
      end
   endgenerate

   /* special case for W=1:
          a   enc dec
          0    11  0
          1    00  1
    */
   assign enc = W > 1 ? ff1[W-1] : (a ? 2'b00 : 2'b11);
   
   // assign dec = (a==0) ? 0 : (1 << (W-1-enc));  // This won't build an adder, will it???
   // I don't trust it, we'll use specdec instead
   assign dec = specdec[W-1];
endmodule
