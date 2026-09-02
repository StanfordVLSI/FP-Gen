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
      '$cmd' mycontainer:/my_design/build.log  # Process log in container "mycontainer"
      '$cmd' mycontainer:/my_design/\*.log     # Process all indicated logs (note escaped "*")
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

# getconf: Search rundir=$1 config.json files for key $2, return first key-value found e.g.
#   getconf <rundir> DESIGN_NAME  => "DESIGN_NAME    FMA_unq1"
#   getconf <rundir> CLOCK_PERIOD => "CLOCK_PERIOD 30"
function getconf { cat $run/*/config.json | tr ',":' ' ' | awk '$1=="'$1'"{print;exit}'; }
function design_name      { getconf DESIGN_NAME;      }
function clock_period     { getconf CLOCK_PERIOD;     }
function std_cell_library { getconf STD_CELL_LIBRARY; }

# Find most-recent $1 subdir containing $2 pattern
# E.g. `latest runs/RUN_2026-08-19_15-50-26 dpnr` => "43-openroad-stamidpnr-3"
function latest { \ls -d $1/* | grep "$2" | tail -1; }
function critpath0 { cat $(latest $1 dpnr)/max.rpt | awk '/arrival/{print $1;exit}'; }

# Complexity in terms of nwires, area
function complexity {

    # How many wires were used after initial synthesis? E.g.
    # E.g. `nwires runs/RUN_2026-08-19_15-50-26` => 3420
    # (FIXME Treating $run as a global, FIXME should be capitalized I spose)
    function nwires { tac $run/*/yosys-synthesis.log | awk '/[-] wires$/{printf $1;exit}'; }

    # How many std cells / seq elements as % of total area etc.
    # E.g. `area runs/RUN_2026-08-19_15-50-26` => "13429 33.00%"
    # extracted from matched line e.g. "of which used for sequential elements: 13429 (33.00%)"
    function area { tac $run/*/yosys-synthesis.log | sed -n '/of which/{s/[.][0-9]*//;s/.*: //;s/[()]//g;p;q}'; }

    printf "%s wires, cell_area %su (%s of total)" $(nwires) $(area)
}

# nom_tt_ws: Find worst-case max/min (setup/hold) slack in nom_tt corner (pos or neg)
# E.g. `nom_tt_ws max` => "43-openroad-stamidpnr-3/ws.max.rpt:nom_tt_025C_1v80: -0.012046364247087247"
# Use "$run/" b/c "$run" does not work with "find" if "$run" is symlink
function nom_tt_ws { (cd $run; egrep ^nom_tt $(find * -name ws.$1.rpt) | awk 'END{print $2}'); }

# Sometimes get TWO conflicting slew reports in the log e.g.
#       WARNING  Max Slew violations found in the following
#       VERBOSE  No max slew violations found
# 
# Want to make sure we get the good notice as well as the bad
# So e.g. "goodslew <logfile>" should yield "No max slew violations found"
function goodslew { grep -o "No max slew violations found" $1 | head -1; }

# Find warnings, errors, and violations found in the log, e.g. slew violations are pretty common
function getwarn {
    sedwarn='
      /flow.py/d;               # comment1
      s/    .*//;               # get rid of long strings of blankspace
      s/^\[..:..:..\] //;       # get rid of timestamp at beginning of line
      s/^/    /;                # Indent every output line by 4 spaces
      s/ in the following.*//;  # Clean up da noise
    '
    egrep 'WARNING.*violations' $1 | sed "$sedwarn";
}

# Given a json file "$1", report corners that have negative setup/hold slack e.g.
# `get_wns RUN_2026-08-25_15 setup` => "min_ss_80C_1v -6.48 ns\nnom_ss_80C_1v -6.79 ns"
function get_wns {
    # Given a run dir "$1", find the `state_out.json` file with the most recent timestamp
    # e.g. `final_state RUN_2026...10` => "RUN_2026...10/76-misc-repo.../state_out.json"
    rundir=$1; final_state=$(\ls -t $rundir/*/state_out.json | head -1)
    sh=$2; cat $final_state | awk -F'[:, "]*' '
        /'$sh'__wns__corner/ { corn=$3; ns=$4; if (ns>=0) next   }
        /'$sh'__wns__corner/ { printf("%s %7.2f ns\n", corn, ns) }
    ' | sort -k2,2rn
}

# Print errors but/and also save them to print at the end
function printerr { echo "$1"; deferred_errors="$deferred_errors$1\n"; }
function finalerr { echo "$deferred_errors"; }

# bookmark

function getrun { echo -n runs/; grep -m 1 RUN $1 | tr "'." ' ' | xargs -n 1 | grep RUN; }
topdir=$(pwd)
for log in $*; do
    cd $topdir          # Back to safety
    run=$(getrun $log)  # Find the rundir associated with this log file
    deferred_errors=""  # Errors for this log will be recorded in "deferred_errors"

    echo $log $run; cd $(dirname $log)
    blog=$(basename $log)

    if test -d $run; then
      design_name      | awk '{printf("%17s  %s\n", $1, $2)}'                    # "FMA_unq1"
      clock_period     | awk '{printf("%17s  %.1fns (%dMHz)\n",$1,$2,1000/$2)}'  # "30"
      std_cell_library | awk '{printf("%17s  %s\n", $1, $2)}'                    # "sky130_fd_sc_hd"
      complexity       | awk '{printf("%17s  %s\n","Complexity", $0)}'
#bookmark
      critpath0 $run | awk '{printf("    Critical path  %5.2fns\n", $1)}'
      printf "       Setup/Hold  %.2fns / %.2fns (slack, nom_tt)\n" $(nom_tt_ws max) $(nom_tt_ws min)
    else
        echo "          WARNING  Cannot find run directory $run"
    fi

    # "WARNING Setup violations found" => *Warning* if setup violations in non-tt corner
    setup_warn=$(printf "%17s  %s"  "WARNING" "Setup violations found")
    egrep -q "WARNING.*Setup viol" $blog && echo "$setup_warn"
    get_wns $run setup | grep -v tt | awk '{printf("%17s  ...%s\n", "", $0)}'

    # "ERROR Setup violations in tt corner"
    setup_err=$(printf "%17s  %s"  "ERROR" "Setup violations found in tt corner")
    grep -A 6 ERROR $blog | grep -q 'Setup violations found' && printerr "$setup_err"
    get_wns $run setup | grep tt | awk '{printf("%17s  ...%s\n", "", $0)}'

    # "ERROR Hold violations found" => *Error* if hold violations found in any corner :(
    hold_err=$(printf "%17s  %s\n"  "ERROR" "Hold violations found")
    grep -A 6 ERROR $blog | grep -q 'Hold violations found' && printerr "$hold_err"
    get_wns $run hold | awk '{printf("%17s  ...%s\n", "", $0)}'

    # Other (not setup or hold) warnings, e.g. slew violations are pretty common
    getwarn $blog | egrep -v 'Setup|hold' | sed 's/^/      /'

    # If goodslew message exists, print the goodslew message
    awk '/./{printf("         BUT ALSO \"%s\"\n", $0)}' <<< "$(goodslew $blog)"

    # If all three final checks pass, this will yield something like "Antenna DRC LVS" etc
    res=$(awk '/Passed/{printf " "p}{p=$NF}' $blog | cut -b 2-)

    [ "$res" ] || printf "    FAILED final checks :(\n"  # [ "$res" ] || continue
    [ "$res" ] && printf "           PASSED  $res\n"

    # Recap errors at end of summary
    echo -e "$deferred_errors"  # "-e" prints "\n" as newline see?
done


# TRASH
# FIXED maybe ready to delete maybe
# # FIXME This is not good; should instead look at final value(s) in final state*.json see?
# function lastword { cat $1 | xargs -n 1 | tail -1; }
# function setup0 { lastword $(latest $1 dpnr)/ws.max.rpt; }

# function hold0  { lastword $(latest $1 dpnr)/ws.min.rpt; }

