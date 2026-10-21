This is a floating-point multiplier-adder generator and testbench.

### QUICK DEMO I: QUICK RTL

For a quick demo, run the command below. In about 3 minutes, it should
produce a set of verilog files `"genesis_{synth,verif}/*.v"` that implement

a fast 16-bit bfloat [cascade multiply add unit (CMA)](doc/FPGen_user_guide.pdf) and testbench.
```
    make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-cma.cfg
```

### QUICK DEMO II: QUICK VERIFICATION

If you have the Synopsys VCS verilog simulator installed, you can run the testbench and
verify your design by simply doing
```
    make run
```
If you do not have access to VCS, you can install [Verilator](https://www.veripool.org/verilator),
a FOSS simulator. You will need to generate a verilator-compatible(*) version of the RTL
by setting the SIMULATOR environment variable. The command below will do that, and then it will verify
the design, using Verilator instead of VCS.
```
    SIMULATOR=VERILATOR make clean run GENESIS_CFG_SCRIPT=SysCfgs/bf-cma.cfg 
```
> (\*) *Default `"make gen"` RTL has links to proprietary IP (Designware)*
> *available only to people with a valid Synopsys license.*<br/>
> *`"SIMULATOR=VERILATOR"` instead uses custom handwritten substitutes.*

Note that VCS-based verification may require setting a `"SYNOPSYS"` environment variable,
see the *Environment* section below for more information.


### QUICK DEMO III: QUICK TAPEOUT

If you have [Docker](https://www.docker.com) installed in your system, the script `"test/tapeout-fma00bf.sh"` 
will build a single-cycle bfloat mul-add unit, install librelane FOSS tools in a
docker container, and use them to produce a GDS-II tape for the librelane default
process (skywater 130 maybe).
```
    % ./test/tapeout-fma00bf.sh
```
The process is definitely "quick" for a tapeout, historically, but it's still going to
take awhile, maybe 30 minutes to an hour depending on your system. The final tape will
be in a docker container in a directory called something like `"my_designs/fpgen/runs/RUN*/final/"`,
you should be able to find it by doing `"docker ps"` etc.

For more details, see `test/README.txt`.


### DETAILED INFO

#### To run the generator:
```
  make clean [gen|run] [GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg] [SIMULATOR=VERILATOR]
```
#### Examples:
```
  # Build default mul-add unit(*), no verification
  make clean gen              

  # Build and verify default mul-add unit
  export SIMULATOR=VCS          # Use VCS to verify the RTL testbench OR
  export SIMULATOR=VERILATOR    # Use Verilator to verify the RTL testbench
  make clean run                # Build and verify

  # Build and verify a 32-bit single-precision cascaded multiply-add unit
  make clean run GENESIS_CFG_SCRIPT=SysCfgs/sp-cma.cfg
```
_(*) The default configuration is a double-precision 7-cycle FMA (fused mul-add)
unit with 3-cycle pipelined Wallace-tree Booth-2 multiplier._


<!--
XXX #### Explanation:
XXX 
XXX * `"gen|run"` just generate the design (gen) or generate and then also run a testbench (gen)
XXX * `"GENESIS_CFG_XML=SysCfgs/changefile.xml"` tells genesis to use the design configuration specified in `changefile.xml`
XXX * `"GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg"` -- an alternative way to load a script for setting configuration
XXX * Replace `SIM_ENGINE=synopsys` with `SIM_ENGINE=mentor` to use mentor simulation tools.
XXX * `"GENESIS_HIERARCHY=new.xml"` redirect the output xml file to file `new.xml` (important for the (unsupported) gui)
-->

#### Environment:
You can do this to help prepare your environment:
```
    source scripts/setup.sh
```
Among other things, the script will check to see if you have the necessary generator
"Genesis2" and, if not, will attempt to install it locally for you.

For everything to work as intended, you'll need at least two CAD tools in your path:
`Genesis2`, the generator tool, and a supported Verilog simulator. We currently support
Synopsys "vcs" and a FOSS alternative, "verilator." In addition, `"Genesis2"` requires
that Perl 5 be installed on your system.

That is, if you do "command -v" for the required tools, you should get a valid result, e.g.
```
    % command -v Genesis2
      /usr/local/bin/Genesis2

    % command -v vcs
      /cad/synopsys/vcs/Q-2020.03-SP2/bin/vcs

    % command -v verilator
      /usr/local/bin/verilator

    % perl --version
      This is perl 5, version 34... (does not have to be 34 maybe)
```
Without a vcs or verilator simulator, you can still generate Verilog, but you'll be on your own
for running the simulation test afterwards.

Also, for vcs, you'll need to locate the libraries that vcs uses for testing. Default locations are
```
  $SYNOPSYS/dw/sim_ver
  $SYNOPSYS/packages/gtech/src_ver
```
where SYNOPSYS=/hd/cad/synopsys/dc_shell/G-2012.06-SP5-1

If this is not where they exist on your system, you will need to locate them and then set the
SYNOPSYS environment/makefile variable appropriately when running the make command.

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
   % make clean run GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg \
       SYNOPSYS=/mycaddir/synopsys/dc_shell/J-2014.09-SP3
```

#### Designware

The main build is supposed to be free of proprietary software i.e. Synopsys Designware, but apparently some of it snuck in.
So, rather than rewrite the existing RTL, I made some clean lookalike modules and put them in the local directory "rtl/dwsub".
```
    % (cd rtl/dwsub/; ls -1 *.v | sed 's/^/    /')
        DWSUB01_add.v
        DWSUB01_csa.v
        DWSUB_decode_en.v
        DWSUB_lzd.v
```
To use the clean version, specify parameter top_FPGen.WHICH_DW=DWSUB in your cfg file.
And/or you can specify it on the command line as shown below. Or, if you specify
`"SIMULATOR=VERILATOR"` during code generation, this will be set automatically.
Also, certain configurations set this parameter by default, e.g. `"SysCfgs/bf-cma.cfg"`.
```
    # Any one of these will suffice to compile Designware-free RTL
    make clean run GEN="-parameter top_FPGen.WHICH_DW=DWSUB"
    SIMULATOR=VERILATOR make clean run
    make clean gen GENESIS_CFG_SCRIPT=SysCfgs/bf-cma.cfg
```

### Pre-Built Examples For Comparison

For comparison, the directory `examples` contains the results of a successful `make clean run`
for the "dp-fma" config (a double-precision fused-multiply-add unit).
Verilog for the generated FMA is in the `examples/genesis_verif` directory and standard-output
from running the `make` command is in `examples/make.log`.

## EXTRAS
```
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
```
