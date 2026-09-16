#!/bin/bash

# Make sure you're in the right place maybe, using the dumbest possible test maybe
if ! test -f scripts/librelane.sh; then
    echo "ERROR: Must run test from top-level FPGen dir"
    exit 13
fi

# Helper function
function INFO { printf '\n[VBC] %s\n' "$*"; }

INFO 'Install genesis if it is not there already'
source scripts/setup.sh --genesis-only

INFO 'Generate the verilog'
make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-cma.cfg
echo Wait...
sleep 10
pwd; ls -l
if ! grep "Genesis Finished Generating Your Design" genesis.log; then
    echo "ERROR looks like verilog generation failed"
    exit 13
fi


# FIXME "TEST_FAIL" file in curdir is the horrible way we chose to tell if test passed, see TestBench_FPGen.vp
INFO 'Run the test'
set -x
test -f TEST_PASS && rm TEST_PASS
test -f TEST_FAIL && rm TEST_FAIL

#     -y      /cad/synopsys/syn/U-2022.12-SP1/dw/sim_ver/ \
#     +incdir+/cad/synopsys/syn/U-2022.12-SP1/dw/sim_ver/ \
#     -y      /cad/synopsys/syn/U-2022.12-SP1/packages/gtech/src_ver/ \
#     +incdir+/cad/synopsys/syn/U-2022.12-SP1/packages/gtech/src_ver/ \


# PARMS1='--timing --timescale 1ps/1ps --cc -y . +incdir+.'
PARMS1='--timing --timescale 1ps/1ps --cc'

PARMS2='./rtl/dwsub/DWSUB01_add.v ./rtl/dwsub/DWSUB01_csa.v ./rtl/dwsub/DWSUB_decode_en.v ./rtl/dwsub/DWSUB_lzd.v -f ./genesis_vlog.vf'


/bin/rm -rf obj_dir
verilator --binary -j 0 -Wno-fatal --top-module top_FPGen $PARMS1 $PARMS2 && obj_dir/Vtop_FPGen
test -e TEST_PASS || exit 13  # FAIL
exit                          # PASS
