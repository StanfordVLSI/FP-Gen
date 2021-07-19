This is a Floating Point Adder/Multiplier/Multiply-Accumulate
generator and testbench

To run it:
  make clean [gen|run] [SIM_ENGINE=mentor] [GENESIS_HIERARCHY=new.xml] [GENESIS_CFG_XML=SysCfgs/changefile.xml]

Example:
  make clean gen GENESIS_CFG_XML=SysCfgs/my_config.xml
  make clean run GENESIS_CFG_XML=SysCfgs/your_config.xml
  make clean run GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg   # recommended

Explanation:
* gen|run -- choose to either just generate the design or also run the testbench
* Replace SIM_ENGINE=mentor with SIM_ENGINE=synopsys for using synopsys simulation tools.
* GENESIS_HIERARCHY=new.xml redirect the OUTPUT xml file to file 'new.xml' (important for the gui)
* GENESIS_CFG_XML=SysCfgs/changefile.xml tells genesis to use the design configuration specified in 'changefile.xml'
* GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg an alternative way to load a script for setting configuration

Environment:
You can use the command

    source scripts/setup.sh

to help prepare your environment. The script will check to see if you
have the necessary generator "Genesis2.pl" and, if not, will attempt
to install it locally for you. It will also check your environment for
the conditions described below.

For everything to work as intended, you'll need at least two CAD tools
in your path: `Genesis2.pl`, the generator tool, and `vcs`, the
Synopsys Verilog simulator. That is, if you do "command -v" for each
you should get a valid result, e.g.

    % command -v Genesis2.pl
      /usr/local/bin/Genesis2Tools//bin/Genesis2.pl

    % command -v vcs
      /cad/synopsys/vcs/Q-2020.03-SP2/bin/vcs

(Without vcs you can still generate Verilog, but you'll be on your own
for running the simulation test afterwards.)

Also (for vcs): you'll need to locate the libraries that vcs uses for testing.
The default locations are

  $SYNOPSYS/dw/sim_ver
  $SYNOPSYS/packages/gtech/src_ver

where SYNOPSYS=/hd/cad/synopsys/dc_shell/G-2012.06-SP5-1

If this is not where they exist on your system, you will need to
locate them and then set the SYNOPSYS makefile variable appropriately
when running the make command.

E.g. on your system suppose you find the designware libraries here:
  /mycaddir/synopsys/dc_shell/J-2014.09-SP3/dw/sim_ver

Then, instead of

   % make clean run \
       GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg

you would do

   % make clean run \
       GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg \
       SYNOPSYS=/mycaddir/synopsys/dc_shell/J-2014.09-SP3


Compare: For comparison, the directory "examples" contains the results
of a successful "make clean run" for the dp-fma config (which I guess
is some kind of double-precision multiply-add unit). Verilog for the
generated FMA is in the examples/genesis_verif directory and
standard-output from running the make command is in examples/make.log.


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
