#!/bin/bash

# Make sure you're in the right place maybe, using the dumbest possible test maybe
if ! test -f scripts/librelane.sh; then
    echo "ERROR: Must run test from top-level FPGen dir"
    exit 13
fi

# Helper function
function INFO { printf '\n[BFTEST] %s\n' $*; }

INFO 'Install genesis if it is not there already'
source scripts/setup.sh --genesis-only

INFO 'Generate the verilog'
make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-fma00.cfg |& tee $testdir/make-gen.log
if ! grep "Genesis Finished Generating Your Design" genesis.log; then
    echo "ERROR looks like verilog generation failed"
    exit 13
fi

INFO 'Run the librelane tapeout script "scripts/librelane.sh"'
scripts/librelane.sh
