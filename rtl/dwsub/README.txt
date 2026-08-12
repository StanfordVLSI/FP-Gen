Functional lookalikes to replace DW modules that probably should never have
been used in the first place. Use info in the "test/" subdirectory to verify
bitwise correctness versus functionality of the original modules.

Contents currently include four modules
    DW01_add.v
    DW01_csa.v
    DW_decode_en.v
    DW_lzd.v

To use these new modules, from top-level dir, do e.g. 
make clean run SYNOPSYS=$SYNOPSYS GEN="-parameter top_FPGen.WHICH_DW=DWSUB"
