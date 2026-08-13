#!/bin/bash

# Make sure you're in the right place maybe, using the dumbest possible test maybe

if ! test -f scripts/setup.sh; then
    echo "ERROR: Must run test from top-level FPGen dir"
    exit 13
fi

echo '
==============================================================================
TAPEOUT: Install genesis if it is not there already
'
source scripts/setup.sh --genesis-only


echo '
==============================================================================
TAPEOUT: Prepare a workspace
'
testname=$(mktemp -u tapeout_XXXXX)
testdir=tmpdir/$testname
mkdir -p $testdir/rtl
echo Workspace will be ./$testdir



echo '
==============================================================================
TAPEOUT: Generate the verilog and add it to the workspace
'
make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-fma00.cfg |& tee $testdir/make-gen.log
if ! grep "Genesis Finished Generating Your Design" $testdir/make-gen.log; then
    echo "ERROR looks like verilog generation failed"
    exit 13
fi


echo '
==============================================================================
TAPEOUT: Copy verilog to test dir
'
set -x
cp genesis_synth/*.v $testdir/rtl/
cp rtl/dwsub/DWSUB*.v $testdir/rtl/
rm $testdir/rtl/FPGen*  # Things break if we include the testbench-related files I will file an issue maybe
set +x

# (Could do a "make clean" here if we were not so paranoid maybe)


echo '
==============================================================================
TAPEOUT: Install librelane in a docker container
'
container=tmp_$testname
docker run -id --name $container --network host ghcr.io/librelane/librelane:3.0.4 sh
echo "Built new docker container '$container'"

docker exec $container git clone https://github.com/librelane/librelane/ ./librelane
docker exec $container nix-shell ./librelane/shell.nix
docker exec $container mkdir -p ./my_designs/fma00bf


echo '
==============================================================================
TAPEOUT: Install gawk, sed, summarization script in the container
'
docker cp test/summarize_tapeout_log $container:./my_designs/fma00bf

# docker exec $container nix-env --install --attr nixpkgs.gawk --dry-run
docker exec $container nix-env --install --attr nixpkgs.gawk
docker exec $container which awk

# docker exec $container nix-env --install --attr nixpkgs.gnused --dry-run
docker exec $container nix-env --install --attr nixpkgs.gnused
docker exec $container which sed


echo '
==============================================================================
TAPEOUT: Copy the verilog to the container and build a json config file
'
set -x
docker cp $testdir/rtl $container:./my_designs/fma00bf  # Successfully copied 288kB...
echo '{
  "DESIGN_NAME": "FMA_unq1",
  "VERILOG_FILES": ["dir::rtl/*.v"],
  "CLOCK_PERIOD": 100,
  "CLOCK_PORT": "clk"
}
' > $testdir/FMA.json

docker cp $testdir/FMA.json $container:./my_designs/fma00bf  # Successfully copied 2.05kB
set +x


echo '
==============================================================================
TAPEOUT: Launch the librelane design flow!
'
docker exec $container bash -c '(cd ./my_designs/fma00bf && librelane FMA.json)' |& tee $testdir/librelane.log


echo '
==============================================================================
TAPEOUT: Check the result
'
if ! egrep '^[*] (Antenna|LVS|DRC)' $testdir/librelane.log; then
    hline="==========================================================="
    echo "ERROR looks like we did not make it through the entire test"
    printf "$hline\n\n\n"
    exit 13
fi

function test_failed { false; }
for check in Antenna LVS DRC; do
    result=$(egrep -A 1 "^[*] $check" $testdir/librelane.log | tr "\n" " ")
    echo "$result"
    if ! echo "$result" | grep -q Passed; then
        printf "ERROR looks like $check check FAILED\n\n"
        function test_failed { true; }
    fi
done
printf '\n\n'
if test_failed; then
    printf "\nERROR one or more checks seem to have failed\n\n"
    exit 13
fi

docker cp $testdir/librelane.log $container:./my_designs/fma00bf
docker exec $container bash -c 'cd my_designs/fma00bf; bash summarize_tapeout_log librelane.log'
    #             Clock 100.0ns (10MHz)
    #     Critical path  36.89ns
    #        Setup/Hold  42.86ns 40.73ns
    #           WARNING  Max Slew violations found
    #            PASSED  Antenna LVS DRC


echo '
==============================================================================
TAPEOUT: GDS-II tape is here maybe:
'
gds=$(sed -n '/Writing out GDS/,/INFO..Done/p' $testdir/librelane.log \
  | tr -d '\n' | sed "s/^[^']*[']//" | sed "s/['].*//")
echo docker exec $container ls -lh $gds
docker exec $container ls -lh $gds


echo '
==============================================================================
TAPEOUT: Cleanup
'
echo "
To clean up:
  docker kill $container
  /bin/rm -rf $testdir
  make clean
"
