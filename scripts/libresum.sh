#!/bin/bash

cmd=$(basename "$0")
HELP='
  DESCRIPTION: Summarizes results for each run found in a given design directory.

  Two ways to use this script (this script = "'$cmd'"):

      # From inside docker container
      bash '$cmd' <log1> <log2> <log3> ...

      # From outside docker container
      '$cmd' <container-name>:<log>

  EXAMPLES - from inside a container
      librelane my_design.json > my_design.log1
      librelane my_design.json > my_design.log2
      '$cmd' my_design.log1       # Process one log
      bash '$cmd' *.log*          # Process ALL logs

  EXAMPLES - from outside the container
      '$cmd' bad_wolf:/root/my_design/build.log  # Process log in container "bad_wolf"
      '$cmd' bad_wolf:/root/my_design/\*.log     # Process all indicated logs (note escaped "*")
'
if [ "$1" == "--help" ]; then echo "$HELP"; exit; fi
if [ "$1" == ""       ]; then echo "$HELP"; exit; fi

# Unpack command-line args I dunno
if grep -q : <<< "$1"; then
    container=$(expr "$1" : '\(.*\):')
    log=$(      expr "$1" : '.*:\(.*\)')

    # Pass the command into the indicated container for execution
    # echo Found container=$container and log=$log
    docker cp $0 $container:/tmp
    exec docker exec $container bash /tmp/$cmd $log
fi

# This script requires sed and awk, neither of which exist on the default nix-based librelane docker instance
if ! type awk > /dev/null; then
    echo "OOPS awk not found, I will try and install it for you"
    echo nix-env --install --attr nixpkgs.gawk
    nix-env --install --attr nixpkgs.gawk
    type awk
    printf "==============================================================================\n\n"
fi
if ! type sed > /dev/null; then
    echo "OOPS sed not found, I will try and install it for you"
    echo nix-env --install --attr nixpkgs.gnused
    nix-env --install --attr nixpkgs.gnused
    type sed
    printf "==============================================================================\n\n"
fi

# Helper functions

# Find most-recent $1 subdir containing $2 pattern
# E.g. `latest runs/RUN_2026-08-19_15-50-26 dpnr` => "43-openroad-stamidpnr-3"
function latest { \ls -d $1/* | grep "$2" | tail -1; }

function did_it_pass { awk '/Passed/{printf " "p}{p=$NF}' $1 | cut -b 2-; }
function getrun { echo -n runs/; grep -m 1 RUN $1 | tr "'." ' ' | xargs -n 1 | grep RUN; }

function getclk0 { awk '/^clk/{print $2;exit}' $(latest $1 dpnr)/clock.rpt; }
function critpath0 { cat $(latest $1 dpnr)/max.rpt | awk '/arrival/{print $1;exit}'; }

# E.g. `get_tech  runs/RUN_2026-08-19_15-50-26` => "sky130_fd_sc_hd__tt_025C_1v80.lib"
function get_tech {
  cat $1/*/yosys-synthesis.log | awk -F/ '/^1. Executing Liberty/{print $NF}'
}

function lastword { cat $1 | xargs -n 1 | tail -1; }
function setup0 { lastword $(latest $1 dpnr)/ws.max.rpt; }
function hold0  { lastword $(latest $1 dpnr)/ws.min.rpt; }

# Sometimes get TWO conflicting slew reports in the log e.g.
#       WARNING  Max Slew violations found in the following
#       VERBOSE  No max slew violations found
# 
# Want to make sure we get the good notice as well as the bad
# So e.g. "goodslew <logfile>" should yield "No max slew violations found"
function goodslew { grep -o "No max slew violations found" $1 | head -1; }

sedwarn='
  /flow.py/d;               # comment1
  s/    .*//;               # get rid of long strings of blankspace
  s/^\[..:..:..\] //;       # get rid of timestamp at beginning of line
  s/^/    /;                # Indent every output line by 4 spaces
  s/ in the following.*//;  # Clean up da noise
'
sederr='/^\[/{tag=$2}/violation/ && tag~/ERROR/{$1=$1; print $0}'
function getwarn { egrep 'WARNING.*violations' $1 | sed "$sedwarn"; }
function geterr { awk "$sederr" $1 | sed 's/ in the following.*//'; }
function viol { echo $(setup0 $1) | awk '$1 >= 0 { exit 13 }'; }

for log in $*; do
    run=$(getrun $log)
    # echo "FOUND RUN" $run
    echo $log $run; cd $(dirname $log)
    blog=$(basename $log)

    # First see if we passed; if not, move on to the next test
    if ! [ "$(did_it_pass $blog)" ]; then printf "    FAILED\n\n"; continue; fi

    # run=runs/$(getrun $log)
    if test -d $run; then
      getclk0 $run   | awk '{printf("            Clock %5.1fns (%dMHz)\n", $1, 1000/$1)}'
      get_tech $run  | awk '{printf("       Technology  %s\n",      $1)}'
      critpath0 $run | awk '{printf("    Critical path  %5.2fns\n", $1)}'
      printf "       Setup/Hold  %5.2fns %5.2fns\n" $(setup0 $run) $(hold0 $run)
    else
        echo "          WARNING  Cannot find run directory $run"
    fi
    getwarn $blog | sed 's/^/      /'

    # If goodslew message exists, print the goodslew message
    awk '/./{printf("             Slew  %s\n", $0)}' <<< "$(goodslew $blog)"
    echo "           PASSED  $res"
    if viol $run;
        then printf "            ERROR  Setup violation %5.2fns\n" $(setup0 $run)
        else geterr $blog | sed 's/^/            ERROR  /'
    fi
    echo ""
done
