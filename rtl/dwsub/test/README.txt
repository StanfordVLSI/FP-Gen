These tests compare functionality of local "fake" dw-modules (dwsub)
vs. actual modules from synopsys (dw).

## SETUP
* Use e.g. # FP-Gen/scripts/setup.sh to setup vcs, dc_shell, $SYNOPSYS, etc.
```
test -z SYNOPSYS && SYNOPSYS=/cad/synopsys/syn/U-2022.12-SP1
DW="-y $SYNOPSIS/dw/sim_ver +libext+.v"
INC="+incdir+/cad/synopsys/syn/U-2022.12-SP1/dw/sim_ver"
VCS="vcs -sverilog $DW $INC"
SIMV="simv -no_save"
```

## TESTS
```
(./vcsclean; $VCS test_add.v       ../DWSUB01_add.v     && simv -no_save) |& tee test_add.out
(./vcsclean; $VCS test_csa.v       ../DWSUB01_csa.v     && simv -no_save) |& tee test_csa.out
(./vcsclean; $VCS test_decode_en.v ../DWSUB_decode_en.v && simv -no_save) |& tee test_decode_en.out
(./vcsclean; $VCS test_lzd.v       ../DWSUB_lzd.v       && simv -no_save) |& tee test_lzd.out
```
You can compare the *.out files with those in the results/ subdirectory e.g.
```
  diff test_add.out <(gunzip -c results/test_add.out.gz)
```
