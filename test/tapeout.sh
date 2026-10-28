#!/bin/bash

config=SysCfgs/bf-cma.cfg  # Default to bf-cma...
[ "$1" ] && config="$1"    # but can override w cmd-line arg

if ! test -f $config; then
    echo "ERROR cannot find config file '$config'" >&2
fi

# Make sure you're in the right place maybe, using a fairly-dumb test
if ! test -f rtl/FMA.vp; then
    echo "ERROR: Must run test from top-level FPGen dir"
    exit 13
fi

# Helper function
function INFO { printf '\n[BFTEST] %s\n' "$*"; }

INFO 'Install genesis if it is not there already'
source scripts/setup.sh --genesis-only

INFO 'Generate the verilog, record to /tmp/make-gen.log'
echo TIME0 $(date)
export SIMULATOR=VERILATOR
make clean gen GENESIS_CFG_SCRIPT=$config |& tee /tmp/make-gen.log
echo TIME1 $(date)
if ! grep "Genesis Finished Generating Your Design" genesis.log; then
    echo "ERROR looks like verilog generation failed"
    exit 13
fi

INFO 'Run the librelane tapeout script "scripts/librelane.sh"'
# scripts/librelane.sh --container fpgen-$USER
make tapeout
echo TIME2 $(date)
