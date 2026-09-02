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

# How many wires were used after initial synthesis? E.g.
# E.g. `nwires runs/RUN_2026-08-19_15-50-26` => 3420
# function nwires { egrep '[-] wires$' $1/*/yosys-synthesis.log | tail -1; }
function nwires { tac $1/*/yosys-synthesis.log | awk '/[-] wires$/{print $1;exit}'; }

# How many std cells / seq elements as % of total area etc.
# E.g. `area runs/RUN_2026-08-19_15-50-26` => "13429 33.00%"
# extracted from matched line e.g. "of which used for sequential elements: 13429 (33.00%)"
function area { tac $1/*/yosys-synthesis.log | sed -n '/of which/{s/[.][0-9]*//;s/.*: //;s/[()]//g;p;q}'; }
                
# bookmark
# FIXME This is not good; should instead look at final value(s) in final state*.json see?
function lastword { cat $1 | xargs -n 1 | tail -1; }
function setup0 { lastword $(latest $1 dpnr)/ws.max.rpt; }

# function hold0  { lastword $(latest $1 dpnr)/ws.min.rpt; }

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

# bookmark

# Report warnings, errors, and violations found in the log
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
function geterr {
    sederr='/^\[/{tag=$2}/violation/ && tag~/ERROR/{$1=$1; print $0}'
    awk "$sederr" $1 | sed 's/ in the following.*//'
}
function viol { echo $(setup0 $1) | awk '$1 >= 0 { exit 13 }'; }





# function getwarn { egrep 'WARNING.*violations' $1 | sed "$sedwarn"; }



# Given a run dir "$1", find the `state_out.json` file with the most recent timestamp
# e.g. `final_state RUN_2026...10` => "RUN_2026...10/76-misc-repo.../state_out.json"
function final_state { \ls -t $1/*/state_out.json | head -1; }

# Given a json file "$1", report corners that have negative setup/hold slack e.g.
# `get_wns RUN_2026-08-25_15 setup`
#     => "min_ss_100C_1v60 -6.48 ns\nnom_ss_100C_1v60 -6.79 ns"
function get_wns {
   d=$1; sh=$2; cat $(final_state $d) | awk -F'[:, "]*' '
      /'$sh'__wns__corner/ { corn=$3; ns=$4; if (ns>=0) next   }
      /'$sh'__wns__corner/ { printf("%s %7.2f ns\n", corn, ns) }
      ' | sort -k2,2rn
}
# get_wns /my_designs/fpgen/runs/RUN_2026-08-25_15-11-02

# function setup_error {

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
      design_name      | awk '{printf("%17s  %s\n", $1, $2)}'                    # "FMA_unq1"
      clock_period     | awk '{printf("%17s  %.1fns (%dMHz)\n",$1,$2,1000/$2)}'  # "30"
      std_cell_library | awk '{printf("%17s  %s\n", $1, $2)}'                    # "sky130_fd_sc_hd"
      
      comp="$(nwires $run) $(area $run)"
      echo $comp     | awk '{printf("       Complexity  %s wires, cell_area %su (%s of total)\n", $1, $2, $3)}'
      critpath0 $run | awk '{printf("    Critical path  %5.2fns\n", $1)}'
      printf "       Setup/Hold  %.2fns / %.2fns (slack, nom_tt)\n" $(nom_tt_ws max) $(nom_tt_ws min)
    else
        echo "          WARNING  Cannot find run directory $run"
    fi

    deferred_errors=""

    # "WARNING Setup violations found" => *Warning* if setup violations in non-tt corner
    setup_error=$(printf "%17s  %s\n"  "WARNING" "Setup violations found")
    egrep -q "WARNING.*Setup viol" $blog && echo "$setup_error" && deferred_errors="$deferred_errors$setup_error\n"
    get_wns $run setup | grep -v tt | awk '{printf("%17s  ...%s\n", "", $0)}'

    # "ERROR Setup violations in tt corner"
    grep -A 6 ERROR $blog | grep -q 'Setup violations found' && \
        printf "%17s  %s\n"  "ERROR" "Setup violations found in tt corner"
    get_wns $run setup | grep tt | awk '{printf("%17s  ...%s\n", "", $0)}'

    # "ERROR Hold violations found" => *Error* if hold violations found in any corner :(
    grep -A 6 ERROR $blog | grep -q 'Hold violations found' && \
        printf "%17s  %s\n"  "ERROR" "Hold violations found"
    get_wns $run hold | awk '{printf("%17s  ...%s\n", "", $0)}'



#     printf "%17s  %s\n" <<< $(get_wns $run | grep -i setup)
#     exit
#     get_wns $run | grep -i hold

# TODO "ERROR Hold violations found


    # Other (not setup or hold) warnings
    getwarn $blog | egrep -v 'Setup|hold' | sed 's/^/      /'

    # If goodslew message exists, print the goodslew message
    awk '/./{printf("         BUT ALSO \"%s\"\n", $0)}' <<< "$(goodslew $blog)"

    # If all three final checks pass, this will yield something like "Antenna DRC LVS" etc
    res=$(awk '/Passed/{printf " "p}{p=$NF}' $blog | cut -b 2-)

    [ "$res" ] || printf "    FAILED final checks :(\n"  # [ "$res" ] || continue
    [ "$res" ] && printf "           PASSED  $res\n"
    if viol $run;
        then printf "            ERROR  Setup violation %5.2fns\n" $(setup0 $run)
        else geterr $blog | sed 's/^/            ERROR  /'
    fi

    echo ""
done


# TRASH
# function result0 { awk '/Passed/{printf " "p}{p=$NF}' $1 | cut -b 2-; }


# Get clock period from pnr report
# function getclk0 { awk '/^clk/{print $2;exit}' $(latest $1 dpnr)/clock.rpt; }

# BETTER
#         awk '{printf("%17s  %s\n", "Name", $2)}'                       <<< $(getconf DESIGN_NAME)   # "FMA_unq1"
#         awk '{printf("%17s  %.1fns (%dMHz)\n", "Clock", $2, 1000/$2)}' <<< $(getconf CLOCK_PERIOD)  # "30"
#         awk '{printf("%17s  %s\n", "Name", $2)}'              <<< $(getconf $run DESIGN_NAME)   # "FMA_unq1"
#         awk '{printf("%17s  %.1fns (%dMHz)\n", $2, 1000/$2)}' <<< $(getconf $run CLOCK_PERIOD)  # "30"
#         awk '{printf("%17s  %s\n", "Name", $2)}'                       <<< $(design_name)   # "FMA_unq1"
#         awk '{printf("%17s  %.1fns (%dMHz)\n", "Clock", $2, 1000/$2)}' <<< $(clock_period)  # "30"

#         design_name  | awk '{printf("%17s  %s\n", "Name", $2)}'                        # "FMA_unq1"
#         clock_period | awk '{printf("%17s  %.1fns (%dMHz)\n", "Clock", $2, 1000/$2)}'  # "30"

# function getclk0 { getconf $1 CLOCK_PERIOD; }  # E.g. "30" (30ns)
# function getname { getconf $1 DESIGN_NAME | sed 's/_unq.*//'; }  # E.g. "FMA"

# function getconf { cat $1/*/config.json | awk -F'"' '$1=="'$2'"{print $3}'; }
# function getconf { cat $1/*/config.json | awk -F'"' '$2=="'$2'"{print $2,$4; exit}'; }
# function getconf { cat $1/*/config.json | awk -F'"' '/DESIGN_NAME/{print $2,$4; exit}' | head
#                    
#                    cat $1/*/config.json | awk -F'"' '/DESIGN_NAME/{print $2,$4; exit}' | head
# getconf $run DESIGN_NAME
# cat $run/*/config.json | tr ',":' ' ' | awk '$1=="'$key'"{print}' | head



# function getconf { cat $1/*/config.json | tr ',":' ' ' | awk '$1=="'$2'"{print;exit}'; }
      # getclk0 $run   | awk '{printf("            Clock  %.1fns (%dMHz)\n", $2, 1000/$2)}'
      # get_tech $run  | awk '{printf("       Technology  %s\n",      $1)}'

# # E.g. `get_tech runs/RUN_2026-08-19_15-50-26` => "sky130_fd_sc_hd__tt_025C_1v80.lib"
# function get_tech {
#   cat $1/*/yosys-synthesis.log | awk -F/ '/^1. Executing Liberty/{print $NF}'

# function nom_tt_ws_max { cat $(find $run -name ws.max.rpt) | egrep ^nom_tt | tail -1; }
# function nom_tt_ws_min { cat $(find $run -name ws.min.rpt) | egrep ^nom_tt | tail -1; }

# function nom_tt_ws_max { tac $(find $run/ -name ws.max.rpt) | awk '/^nom_tt/{print $2; exit}'; }
# function nom_tt_ws_min { tac $(find $run/ -name ws.min.rpt) | awk '/^nom_tt/{print $2; exit}'; }

# E.g. `nom_tt_ws max` => "43-openroad-stamidpnr-3/ws.max.rpt:nom_tt_025C_1v80: -0.012046364247087247"
# Use "$run/" b/c "$run" does not work with "find" if "$run" is symlink
# function nom_tt_ws { egrep ^nom_tt $(find $run/ -name ws.$1.rpt); }

# function nom_tt_ws { egrep ^nom_tt $(find $run/ -name ws.$1.rpt) | awk 'END{print $2}'; }
# function nom_tt_ws { egrep ^nom_tt $(find $run/ -name ws.$1.rpt) | tail -1; }

# nom_tt_ws max
# nom_tt_ws min

# FIXED!!!
# okay but look we still got this problem:
# ./my_designs/fpgen/0828-1843-FMA-11.log runs/RUN_2026-08-28_18-43-59
#        Setup/Hold  -2.91ns / 0.21ns (slack, nom_tt)
#           WARNING  Setup violations found
#                    ...nom_tt_025C_1v80 setup     -0.32 ns

# nom_tt_ws_max
# nom_tt_ws_min

      # printf "       Setup/Hold  %.2fns / %.2fns (slack, nom_tt)\n" $(setup0 $run) $(hold0 $run)
      # printf "       Setup/Hold  %.2fns / %.2fns (slack, nom_tt)\n" $(nom_tt_ws_max $run) $(hold0 $run)
      # printf "       Setup/Hold  %.2fns / %.2fns (slack, nom_tt)\n" $(nom_tt_ws_max) $(nom_tt_ws_min)

#     # Setup/hold violations, if any
#     sh=$(get_wns $run)
#     if [ "$sh" ]; then
#         echo "$sh" | sed 's/^/                   .../'
#         # hline="        -------------------------------------------------------"; echo "$hline"
#     fi

# Linearize weird librelane log e.g.
# INPUT
# [10:33:23] ERROR    The following error was encountered while    __main__.py:189
#                     running the flow:                                           
#                     One or more deferred errors were                            
#                     encountered:                                                
#                     Hold violations found in the following                      
#                     corners:                                                    
#                     * max_ss_100C_1v60                                          
# OUTPUT
# [10:33:23] ERROR    The following error was encountered while    __main__.py:189
#                     running the flow:                                           
#                     One or more deferred errors were                            
#                     encountered:                                                
#                     Hold violations found in the following                      
#                     corners:                                                    

#     get_wns $run | grep -i setup
