// We think this is the same functionality as DW01_csa(...)

module DWSUB01_csa #(parameter W=8)
   (
    input [W-1:0]  a, b, c,
    input          ci, 
    output [W-1:0] carry, sum,
    output         co
    );
   generate
      if (W==1)
        // Rules are different for width-1 CSA
        my_csa_1 csa(a,b,c,ci,  carry,sum,co);
      else
        my_csa_n   #(W) csa(a,b,c,ci,  carry,sum,co);
   endgenerate
endmodule // my_csa

module my_csa_n #(parameter W=8)
   (
    input [W-1:0]  a, b, c,
    input          ci, 
    output [W-1:0] carry, sum,
    output         co
    );
   initial if (W==1) $error("my_csa only valid for bitwidths > 1; for one-bit csa use my_csa_1");

   assign carry[0] = c[0];
   assign carry[1] = (a[0] & b[0]) | ((a[0] ^ b[0]) & ci);
   assign sum[0]   = a[0] ^ b[0] ^ ci;

   genvar i;
   generate
      for (i = 1; i <= W-2; i = i + 1) begin 
         assign carry[i+1] = (a[i] & b[i]) | ((a[i] ^ b[i]) & c[i]);
         assign sum[i]     = a[i] ^ b[i] ^ c[i];
      end // loop
   endgenerate
   assign sum[W-1] =  a[W-1] ^ b[W-1] ^ c[W-1];
   assign co       = (a[W-1] & b[W-1]) | ((a[W-1] ^ b[W-1]) & c[W-1]);
endmodule

// Rules are different for width-1 CSA
module my_csa_1
   (
    input  a, b, c, ci,
    output carry, sum, co
    );
   assign carry = c;
   assign sum   = a ^ b ^ ci;
   assign co    = (a & b) | ((a ^ b) & ci);
endmodule
