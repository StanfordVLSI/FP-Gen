Most of this directory appears to be scripts related to generating numbers/data for papers.

There's maybe two useful general tools though maybe:

summarize_gen_params.py - show major parameters used for a given run
  EXAMPLE: python summarize_gen_params.py FPGen.xml
  ...
  top_FPGen.FPGen.Architecture = FMA
  Which architecture implements Multiply Add?
  ...
  top_FPGen.FPGen.FMA.FractionWidth = 52
  Width of the Fraction for the multiplier (default is IEEE Double, 52 bit) 
  ...

list_gen_params.pl
  - extract all parms form a.xml file??
  - seems to be broken...?
  - oops! no, it just takes awhile
  EXAMPLE: list_gen_params.pl ../FPGen.xml  
    TOP.top_FPGen => No Immutable Params
    TOP.top_FPGen.top_FPGen.VERIF_MODE VERIF_MODE OFF !mutable! 
    TOP.top_FPGen.top_FPGen.SYNTH_MODE SYNTH_MODE ON !mutable! 
    TOP.top_FPGen.FPGen.FPGen.FractionWidth FractionWidth 52 !immutable! 
    TOP.top_FPGen.FPGen.FPGen.ExponentWidth ExponentWidth 11 !immutable! 


==============================================================================
Here's the other files and what I think they do maybe


*.m files appear to be ? perl ? function definitions?

Not sure what these do...?


BB_rollup.pl
  - extracts power and energy info from a design? for some kind of report maybe?
BB_setup.sh
  - sets up a bunch of cad stuff maybe
  - sets env vars FPGEN_{PATH,FILES,LICENSE}
CFP2000_test_latency_matrix.csv
  - looks like some knod of test vectors maybe...?
checkRun.pl
  - Scrubs a given log file, looks for one of "Fatal:", "Error.*CMD", "Abort"
collectResults.pl
  - Collects results from "work/" directory, saves them to "results/" dir
converter.pl
  - Extracts result info from *.fpres files
graph.pl
  - runs ?matlab? maybe? to make plots? for a paper maybe?
jsub
  - perl script front-end for Torque job-submission system I guess

Regression.pl
  - "This script is used to run regression tests in parallel on a cluster."

run.pl
  - runs a bunch of different configs maybe?

RunSingleTest.pl
  - does a "run_ibm" maybe? with like randomized ish parms or some such?

setup.sh
setup_kiwi.bash (SEVERELY DEPRECATED)
setup_kiwi.csh (SEVERELY DEPRECATED)
setup_neva.csh (SEVERELY DEPRECATED)
  - setup cad environment etc. for indicated machine and shell

------------------------------------------------------------------------
numbers_cfgs/*.yml => bunch of different configs. In YAML???  Sure why not.

numbers_cfgs/create_yaml_from_csv.pl
  - turns a csv file into a yaml file?
numbers_cfgs/gen_multp_MP.pl
  - "generate yml file for MultiplierP configs" (double MP)
numbers_cfgs/gen_multp.pl
  - "generate yml file for MultiplierP configs" (half, single, double, quad)
numbers_cfgs/gen_test_smpl_all.pl
  - runs a bunch of tests maybe
numbers_cfgs/gen_test_smpl.pl
  - runs a bunch of tests w a different set of parms maybe

------------------------------------------------------------------------
synthesis_runs/runLatency.sh
- script for doing a bunch of runs I guess

------------------------------------------------------------------------
test/runMake/README.txt
- how to run a bunch of tests I guess?

test/numbers/eval.sh
- list of "numbers.pl" commands for various configs
- what seems to be missing: "numbers.pl" (!!)

test/numbers/report.sh
- same as eval.sh but with a different set of configs

test/numbers/*.design
- config params in rough ascii format "<long-name> <short-name> <value>" like
test/numbers/*.cfg
- config params for some top-level run script (numbers.pl I suppose)




