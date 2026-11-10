This is a Floating Point Adder/Multiplier/Multiply-Accumulate generator and testbench

### QUICK DEMO

For a quick demo, run the command below. This should quickly produce
a set of verilog files "genesis_{synth,verif}/*.v" that implement
the default configuration: a 16-bit "bfloat" cascaded multiply-add
unit (also see doc/FPGen_user_guide.pdf).
```
    % make clean gen
```

### QUICK DEMO 2: QUICK TAPEOUT

If you have docker installed in your system, the script `test/tapeout-fma00bf.sh` 
will build a single-cycle bfloat mul-add unit, install librelane FOSS tools in a
docker container, and use them to produce a GDS-II tape for the librelane default
process (skywater 130 maybe).
```
    % ./test/tapeout-fma00bf.sh
```
For details, see `test/README.txt`.


### DETAILED INFO

To run the generator:
  make clean [gen|run] [SIM_ENGINE=synopsys] [GENESIS_HIERARCHY=new.xml] [GENESIS_CFG_XML=SysCfgs/changefile.xml]

Examples:
  make clean gen   # Build simple bfloat mul-add unit, no verification
  make clean run   # Build and verify simple bfloat mul-add unit

  make clean run SIMULATOR=VCS                           # Use VCS for verification instead of Verilator
  make clean run GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg   # Build and verify a double-precision (64-bit) FMA
  make clean run GENESIS_CFG_SCRIPT=DEFAULT              # Build using native default parameters(*).

(*) Native default parameters yield a double-precision 7-cycle FMA (fused mul-add)
unit with 3-cycle pipelined Wallace-tree Booth-2 multiplier.


Environment:
You can use the command

    source scripts/setup.sh

to help prepare your environment. The script will check to see if you have the necessary generator
"Genesis2" and, if not, will attempt to install it locally for you. It will also check your
environment for the conditions described below.

For everything to work as intended, you'll need at least two CAD tools in your path: `Genesis2.pl`,
the generator tool, and `vcs`, the Synopsys Verilog simulator. That is, if you do "command -v" for
each, you should get a valid result, e.g.

    % command -v Genesis2
      /usr/local/bin/Genesis2

    % command -v verilator
      /usr/local/bin/verilator

(Without Verilator you can still generate Verilog, but you'll be on your own
for running the simulation test afterwards.)

You can use the SIMULATOR=VCS option for verification, instead of Verilator, but
you might need to locate the libraries that VCS uses for testing. Default locations are
```
  $SYNOPSYS/dw/sim_ver
  $SYNOPSYS/packages/gtech/src_ver
```
where SYNOPSYS=/hd/cad/synopsys/dc_shell/G-2012.06-SP5-1

If this is not where they exist on your system, you will need to locate them and then set the
SYNOPSYS makefile variable appropriately when running the make command.

E.g. on your system suppose you find the designware libraries here:
```
  /mycaddir/synopsys/dc_shell/J-2014.09-SP3/dw/sim_ver
```
Then, instead of
```
   % make clean run GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg
```
you would do
```
   % make clean run SYNOPSYS=/mycaddir/synopsys/dc_shell/J-2014.09-SP3
```

Compare:

For comparison, the directory `examples` contains the results of a
successful `make clean run` for the dp-fma config.  Verilog for the
generated FMA is in the examples/genesis_verif directory and
standard-output from running the make command is in `examples/make.log`.


------------------------------------------------------------------------
EXTRAS

To use perl script to run jobs and to plot graphs, do following step:

0. To set up the environment, use
	source ./scripts/setup.csh	# for tcsh shell
	source ./scripts/setup.bash	# for bash shell, for example, cyclades

1. To compile .vp file and to run synthesis jobs, use:
	./scripts/run.pl [--cluster] [--jobs=50] --xml=XMLFILE --synth=SYNTHSCRIPT

   Example:
	./scripts/run.pl -c -x=Designware_16_syn.xml -s=run_lvt_16.sh -x=Designware_32_syn.xml -s=run_lvt_32.sh  -x=Designware_64_syn.xml -s=run_lvt_64.sh -x=Designware_128_syn.xml -s=run_lvt_128.sh -x=WlcBth2Sqr_16_syn.xml -s=run_lvt_16.sh -x=WlcBth3Sqr_16_syn.xml -s=run_lvt_16.sh -x=WlcBth2Sqr_32_syn.xml -s=run_lvt_32.sh -x=WlcBth3Sqr_32_syn.xml -s=run_lvt_32.sh -x=WlcBth2Sqr_64_syn.xml -s=run_lvt_64.sh -x=WlcBth3Sqr_64_syn.xml -s=run_lvt_64.sh -x=WlcBth2Sqr_128_syn.xml -s=run_lvt_128.sh -x=WlcBth3Sqr_128_syn.xml -s=run_lvt_128.sh

  Description:
	Compile and run Genesis .vp file for each XMLFILE in ./work directory,
	and then run synthesis with target delay script SYNTHSCRIPT.

  Options:
	-c, --cluster: whether you are on a cluster
	-j, --jobs: the maximum jobs to run on the cluster. The default is 50.
	-x, --xml: input xml config file in ./SysCfgs folder to run genesis
	-s, --synth: target delay script in ./synthesis folder to run synthesis
	
	**NOTE: input option XMLFILE must be followed by its SYNTHSCRIPT, 
	and more than one pairs of XMLFILE and SYNTHSCRIPT can be set, but
	the numbers of input XMLFILE and SYNTHSCRIPT must be the same.


2. To collect the synthesis results, use:
	./scripts/collectResults.pl [--folder=FOLDER] -xml=XMLFILE

   Example:
	./scripts/collectResults.pl -x=Designware_16_syn.xml -x=Designware_32_syn.xml -x=Designware_64_syn.xml -x=Designware_128_syn.xml -x=WlcBth2Sqr_16_syn.xml -x=WlcBth3Sqr_16_syn.xml -x=WlcBth2Sqr_32_syn.xml -x=WlcBth3Sqr_32_syn.xml -x=WlcBth2Sqr_64_syn.xml -x=WlcBth3Sqr_64_syn.xml -x=WlcBth2Sqr_128_syn.xml -x=WlcBth3Sqr_128_syn.xml

   Description:
	Collect results for each XMLFILE, the output csv files will be saved
	in FOLDER folder.

   Options:
	-f, --folder: define the folder to save csv files. The default is ./results


3. To plot the graphs, use:
	./scripts/graph.pl [--folder=FOLDER] [--nodisplay] [--Vdd=VDD] [--Vth=VTH] --csv=CSVFILE --desinware=DESIGNWARE_CSV

   Example:
	./scripts/graph.pl -c=WlcBth2Sqr_64_syn.csv -c=WlcBth3Sqr_64_syn.csv -d=Designware_64_syn.csv
	./scripts/graph.pl -n -c=WlcBth2Sqr_64_syn.csv -c=WlcBth3Sqr_64_syn.csv -d=Designware_64_syn.csv 
	./scripts/graph.pl -f=MultP_results -c=WlcBth2Sqr_64_syn.csv -c=WlcBth3Sqr_64_syn.csv -d=Designware_64_syn.csv

   Description:
	Generate a MATLAB script to plot a graph of several result csv files.
	Then run MATLAB, generate the graph and save a pdf version in
	FOLDER folder. --nodisplay option is available for non-GUI
	environment.

   Options:
	-f, --folder: define the folder to get csv files and save pdf file. The default is ./results
	-n, --nodisplay: do not launch MATLAB GUI
	--Vdd: the Vdd we use to plot the graph. The default is 1.0.
	--Vth: the Vth we use to plot the graph. The default is lvt.

#### Designware

The main build is supposed to be free of proprietary software e.g. Designware, but apparently some of it snuck in.

Rather than rewrite the existing rtl, I made some clean lookalike modules and put them in the local directory "rtl/dwsub".
```
% (cd rtl/dwsub/; ls -1 *.v | sed 's/^/    /')
    DWSUB01_add.v
    DWSUB01_csa.v
    DWSUB_decode_en.v
    DWSUB_lzd.v
```
To use the clean version, specify parameter top_FPGen.WHICH_DW=DWSUB in your cfg file. And/or you can specify it on the command line like so:
```
  make clean run SYNOPSYS=$SYNOPSYS GEN="-parameter top_FPGen.WHICH_DW=DWSUB"
```
