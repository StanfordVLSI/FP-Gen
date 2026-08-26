#!/bin/bash

HELP='
    Given FPGen-generated verilog in dirs `./genesis_synth` and `./genesis_verif`,
    build and run a docker container that turns the verilog into a GDS-II tape.

    USAGE:
        '$0' < --clock_period [ time ] >

    EXAMPLE:
        make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-fma.cfg |& tee /tmp/bf-fma-gen.log
        '$0' 20ns | tee /tmp/bf-fma-tape.log
'
[ "$1" == "--help" ] && echo "$HELP" && exit

# Default values
CONTAINER=
CLOCK_PERIOD=50
while [ $# -gt 0 ] ; do
    case "$1" in
        -h|--help) echo "$HELP";    exit  ;;
        --clo*)    CLOCK_PERIOD=$2; shift ;;
        --clk*)    CLOCK_PERIOD=$2; shift ;;
        --cy*)     CLOCK_PERIOD=$2; shift ;;
        --con*)    CONTAINER=$2;    shift ;;
        *) echo "ERROR: did not recognize option '$1'"; echo "$HELP"; exit 13 ;;
    esac
    shift
done

# Clock period
# egrep -qi "^--(clo|clk|cy)" <<< "$1" && CLOCK_PERIOD=$2
units=$(tr -d '[0-9]' <<< "$CLOCK_PERIOD")          # E.g. "ns" or "ps"
CLOCK_PERIOD=$(tr -cd '[0-9]' <<< "$CLOCK_PERIOD")   # Just the digits e.g. "50" but not "50ns"
grep -qi ps <<< "$units" && echo "ERROR Picoseconds not supported (yet)"
grep -qi us <<< "$units" && echo "ERROR Microseconds not supported (yet)"
grep -qi ms <<< "$units" && echo "ERROR Milliseconds not supported (yet)"
echo "Will use clock period = $CLOCK_PERIOD ns"

# Make sure you're in the right place maybe, using the dumbest possible test maybe
# TODO: could have a command-line arg specifying where to find verilog files...

if ! test -f scripts/setup.sh; then
    echo "ERROR: Must run librelane driver from top-level FPGen dir"
    exit 13
fi

# Sanity check: does top-level module exist?
if   test -f genesis_synth/FMA_unq1.v; then TOP=FMA_unq1
elif test -f genesis_synth/CMA_unq1.v; then TOP=CMA_unq1
else
    echo "ERROR cannot find a top-level verilog file, should be one of '$testdir/rtl/[CF]MA_unq1.v'"
    exit 13
fi

# Helper function
function INFO {
    echo "                                                                             ."
    echo "=============================================================================="
    echo "INFO-FPGEN: $*"
    echo "=============================================================================="
}


# Default temp name for workspace, container, e.g. "tapeout_3435"
# testname=$(mktemp -u tapeout_XXXXX)
testname=$(printf "%04d" $[RANDOM%10000])


##############################################################################
INFO "Prepare a docker container"

# If user specified a container name, use that; else generate a random name
[ "$CONTAINER" ] && container="$CONTAINER" || container="tapeout_$testname"

# Make a list of existing librelane containers
containers=$(docker ps | awk '$2~/librelane/{print $NF}')
# if [ "$containers" ]; then echo "Found existing librelane container(s)"; echo "$containers" | sed 's/^/    - /'; fi

# If container exists already, then use that
if grep -q " $container " " $containers "; then
    echo "Will use existing container '$container' as requested"

# Else build a new container
else
    docker run -id --name $container --network host ghcr.io/librelane/librelane:3.0.4 sh
    echo "Built new docker container '$container'"
fi    


##############################################################################
INFO 'Prepare a workspace e.g. "./tmpdir/tapeout_ZRnNq/"'

testdir=tmpdir/$testname
mkdir -p $testdir/rtl
echo Workspace will be ./$testdir

##############################################################################
INFO 'FIND the verilog and add it to the workspace'



# Copy the verilog to the workspace
set -x
cp genesis_synth/*.v $testdir/rtl/
cp rtl/dwsub/DWSUB*.v $testdir/rtl/
rm $testdir/rtl/FPGen*  # Things break if we include the testbench-related files I will file an issue maybe
set +x


INFO 'Install librelane in docker container "$container"'

# Install the librelane
docker exec $container git clone https://github.com/librelane/librelane/ ./librelane
docker exec $container nix-shell ./librelane/shell.nix
docker exec $container mkdir -p ./my_designs/fpgen

# INFO 'Install gawk, sed, summarization script in the container'

# docker cp test/summarize_tapeout_log $container:./my_designs/fpgen
# 
# # docker exec $container nix-env --install --attr nixpkgs.gawk --dry-run
# docker exec $container nix-env --install --attr nixpkgs.gawk
# docker exec $container which awk
# 
# # docker exec $container nix-env --install --attr nixpkgs.gnused --dry-run
# docker exec $container nix-env --install --attr nixpkgs.gnused
# docker exec $container which sed

INFO 'Copy the verilog to the container and build a json config file'

set -x
# Copy the verilog to the container
docker cp $testdir/rtl $container:./my_designs/fpgen  # Successfully copied 288kB...

# Build a json config file
echo '{
  "DESIGN_NAME": "'$TOP'",
  "VERILOG_FILES": ["dir::rtl/*.v"],
  "CLOCK_PERIOD": '$CLOCK_PERIOD',
  "CLOCK_PORT": "clk"
}
' > $testdir/fpgen.json

# Copy json config file to container
docker cp $testdir/fpgen.json $container:./my_designs/fpgen  # Successfully copied 2.05kB
set +x

INFO 'Launch the librelane design flow!'

docker exec $container bash -c '(cd ./my_designs/fpgen && librelane fpgen.json |& tee fpgen.log)'
docker cp $container:./my_designs/fpgen/fpgen.log $testdir/fpgen.log


INFO 'Check the result'

if ! egrep -q '^[*] (Antenna|LVS|DRC)' $testdir/fpgen.log; then
    hline="==========================================================="
    echo "ERROR final check(s) not found - looks like we did not make it through the entire test"
    printf "$hline\n\n\n"
    exit 13
fi

function test_failed { false; }
for check in Antenna LVS DRC; do
    result=$(egrep -A 1 "^[*] $check" $testdir/fpgen.log | tr "\n" " ")
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

# docker cp $testdir/librelane.log $container:./my_designs/fpgen
# docker exec $container bash -c 'cd my_designs/fpgen; bash summarize_tapeout_log librelane.log'

# exec /tmp/libresum.sh: no such file or directory

scripts/libresum.sh $container:./my_designs/fpgen/fpgen.log
    #             Clock 100.0ns (10MHz)
    #     Critical path  36.89ns
    #        Setup/Hold  42.86ns 40.73ns
    #           WARNING  Max Slew violations found
    #            PASSED  Antenna LVS DRC


INFO 'GDS-II tape is here maybe:'

gds=$(sed -n '/Writing out GDS/,/INFO..Done/p' $testdir/fpgen.log \
  | tr -d '\n' | sed "s/^[^']*[']//" | sed "s/['].*//")
echo docker exec $container ls -lh $gds
docker exec $container ls -lh $gds

INFO 'Cleanup
    To clean up:
        docker kill $container
        /bin/rm -rf $testdir
        make clean
'
