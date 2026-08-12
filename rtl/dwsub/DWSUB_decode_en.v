// We think this is the same functionality as DW_decode_en(en, a,    b)

// It's like a one-hot thing, right? Something like
//    en    a       b
//     0   xx    0000
//     1   00    0001
//     1   01    0010
//     1   10    0100
//     1   11    1000

module DWSUB_decode_en #(parameter W=8)
   (
    input               en,
    input [W-1:0]       a,
    output [(1<<W)-1:0] b
    );
   assign b = en ? 1'b1<<a : 0;
endmodule
