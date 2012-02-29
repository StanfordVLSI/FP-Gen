This is a Floating Point Adder/Multiplier/Multiply-Accumulate generator and testbench

To run it, use:
  make clean [gen|run] [SIM_ENGINE=mentor] [GENESIS_HIERARCHY=new.xml] [GENESIS_CFG_XML=SysCfgs/changefile.xml]
Example:
  make clean gen GENESIS_CFG_XML=SysCfgs/my_config.xml
  make clean run GENESIS_CFG_XML=SysCfgs/your_config.xml


* gen|run -- choose to either just generate the design also run the testbench
* Replace SIM_ENGINE=mentor with SIM_ENGINE=synopsys for using synopsys simulation tools.
* GENESIS_HIERARCHY=new.xml redirect the OUTPUT xml file to file 'new.xml' (important for the gui)
* GENESIS_CFG_XML=SysCfgs/changefile.xml tells genesis to use the design configuration specified in 'changefile.xml'

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
