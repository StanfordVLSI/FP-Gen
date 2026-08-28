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

# If all three final checks pass, this will yield something like "Antenna DRC LVS" etc
function result0 { awk '/Passed/{printf " "p}{p=$NF}' $1 | cut -b 2-; }

function getclk0 { awk '/^clk/{print $2;exit}' $(latest $1 dpnr)/clock.rpt; }
function critpath0 { cat $(latest $1 dpnr)/max.rpt | awk '/arrival/{print $1;exit}'; }

# E.g. `get_tech runs/RUN_2026-08-19_15-50-26` => "sky130_fd_sc_hd__tt_025C_1v80.lib"
function get_tech {
  cat $1/*/yosys-synthesis.log | awk -F/ '/^1. Executing Liberty/{print $NF}'
}

# How many wires were used after initial synthesis? E.g.
# E.g. `nwires runs/RUN_2026-08-19_15-50-26` => 3420
# function nwires { egrep '[-] wires$' $1/*/yosys-synthesis.log | tail -1; }
function nwires { tac $1/*/yosys-synthesis.log | awk '/[-] wires$/{print $1;exit}'; }

# How many std cells / seq elements as % of total area etc.
# E.g. `area runs/RUN_2026-08-19_15-50-26` => "13429 33.00%"
# extracted from matched line e.g. "of which used for sequential elements: 13429 (33.00%)"
function area { tac $1/*/yosys-synthesis.log | sed -n '/of which/{s/[.][0-9]*//;s/.*: //;s/[()]//g;p;q}'; }
                
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


# Report warnings, errors, and violations found in the log

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


# Given a run dir "$1", find the `state_out.json` file with the most recent timestamp
# e.g. `final_state RUN_2026...10` => "RUN_2026...10/76-misc-repo.../state_out.json"
function final_state { \ls -t $1/*/state_out.json | head -1; }

# Given a json file "$1", report corners that have negative setup/hold slack e.g.
# `get_wns runs/RUN_2026-08-25_15-11-02` => "WARNING setup violation:  max_ss_100C_1v60  -45.15 ns"
# "tac" lists results in reverse order so we only report the LAST result in the dir
function get_wns {
   d=$1; cat $(final_state $d) | awk -F'[:, "]*' '
      /hold__wns__corner/  {which="hold"}
      /setup__wns__corner/ {which="setup"}
      /wns__corner/ {
        corn=$3; ns=$4; if (ns>=0) next;
        # printf("%5s violation - %s %7.2f ns\n", which, corn, ns)
        printf("%s %5s %9.2f ns\n", corn, which, ns)
   }' | sort -k3,3rn
}
# get_wns /my_designs/fpgen/runs/RUN_2026-08-25_15-11-02

function getrun { echo -n runs/; grep -m 1 RUN $1 | tr "'." ' ' | xargs -n 1 | grep RUN; }
topdir=$(pwd)
for log in $*; do
    cd $topdir
    run=$(getrun $log)
    # echo "FOUND RUN" $run
    echo $log $run; cd $(dirname $log)
    blog=$(basename $log)

    # run=runs/$(getrun $log)
    if test -d $run; then
      getclk0 $run   | awk '{printf("            Clock %5.1fns (%dMHz)\n", $1, 1000/$1)}'
      get_tech $run  | awk '{printf("       Technology  %s\n",      $1)}'
      comp="$(nwires $run) $(area $run)"
      echo $comp     | awk '{printf("       Complexity  %s wires, cell_area %su (%s of total)\n", $1, $2, $3)}'
      critpath0 $run | awk '{printf("    Critical path  %5.2fns\n", $1)}'
      printf "       Setup/Hold  %.2fns / %.2fns (slack)\n" $(setup0 $run) $(hold0 $run)
    else
        echo "          WARNING  Cannot find run directory $run"
    fi

    # Setup/hold warnings
    getwarn $blog | egrep 'Setup|hold' | sed 's/^/      /'

    # Setup/hold violations, if any
    sh=$(get_wns $run)
    if [ "$sh" ]; then
        echo "$sh" | sed 's/^/                   .../'
        # hline="        -------------------------------------------------------"; echo "$hline"
    fi

    # Other warnings
    getwarn $blog | egrep -v 'Setup|hold' | sed 's/^/      /'

    # If goodslew message exists, print the goodslew message
    awk '/./{printf("         BUT ALSO \"%s\"\n", $0)}' <<< "$(goodslew $blog)"

    # 
    res=$(result0 $blog)
    [ "$res" ] || printf "    FAILED final checks :(\n"  # [ "$res" ] || continue
    [ "$res" ] && printf "           PASSED  $res\n"
    if viol $run;
        then printf "            ERROR  Setup violation %5.2fns\n" $(setup0 $run)
        else geterr $blog | sed 's/^/            ERROR  /'
    fi

    echo ""
done
