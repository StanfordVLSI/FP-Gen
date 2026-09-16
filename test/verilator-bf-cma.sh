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

INFO 'Run the test'

# Clean up from possible previous runs
/bin/rm -rf obj_dir
test -f TEST_PASS && rm TEST_PASS
test -f TEST_FAIL && rm TEST_FAIL

# New run
PARMS='--timing --timescale 1ps/1ps --cc -y rtl/dwsub -f genesis_vlog.vf'
verilator --binary -j 0 -Wno-fatal --top-module top_FPGen $PARMS && obj_dir/Vtop_FPGen

# Check the result
# FIXME "TEST_FAIL" file in curdir is the horrible way we chose to tell if test passed, see TestBench_FPGen.vp
test -e TEST_PASS || exit 13  # FAIL
exit                          # PASS
