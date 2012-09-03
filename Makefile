##############################################################################
################ Makefile Definitions
################################################################################


########### Generic Env Defs ############
#########################################
# Product is 
# - FPGen which is an FP multiply Accumulator (default)
# - FPMult which is an FP multiplier only
FPPRODUCT := FPGen

# This little trick finds where the makefile exists
DESIGN_HOME := $(realpath $(dir $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST))))
$(warning FPGEN home set to $(DESIGN_HOME))

# RUNDIR is where we are actually running
RUNDIR := $(realpath ./)
$(warning Work started at $(RUNDIR)) 

# this line enables a local Makefile to override values of the main makefile
-include Makefile.local


############# For Genesis2 ##############
#########################################
GENESIS_TOP = top_$(FPPRODUCT)
GENESIS_SYNTH_TOP_PATH = $(GENESIS_TOP).$(FPPRODUCT)


# list src folders and include folders
GENESIS_SRC := 	-srcpath ./			\
		-srcpath $(DESIGN_HOME)/rtl	\
		-srcpath $(DESIGN_HOME)/verif			

GENESIS_INC := 	-incpath ./			\
		-incpath $(DESIGN_HOME)/rtl	\
		-incpath $(DESIGN_HOME)/verif

GENESIS_CFG := 	-cfgpath ./			\
		-cfgpath $(DESIGN_HOME)/SysCfgs


# vpath directive tells where to search for *.vp and *.vph files
vpath 	%.vp  $(GENESIS_SRC)
vpath 	%.svp  $(GENESIS_SRC)
vpath 	%.vph $(GENESIS_INC)
vpath 	%.svph $(GENESIS_INC)
vpath 	%.cfg $(GENESIS_CFG)
vpath 	%.xml $(GENESIS_CFG)


# Now list all inputs to genesis: 
GENESIS_PRIMITIVES :=	

GENESIS_ENV :=		$(wildcard $(DESIGN_HOME)/verif/*.vp) $(wildcard $(DESIGN_HOME)/verif/*.svp)
GENESIS_ENV :=		$(notdir $(GENESIS_ENV)) 

GENESIS_DESIGN := 	$(wildcard $(DESIGN_HOME)/rtl/*.vp) $(wildcard $(DESIGN_HOME)/rtl/*.svp)
GENESIS_DESIGN := 	$(notdir $(GENESIS_DESIGN))

GENESIS_INPUTS :=	$(GENESIS_PRIMITIVES) $(GENESIS_ENV) $(GENESIS_DESIGN) 

# debug level
GENESIS_DBG_LEVEL := 0

# List of generated verilog files
GENESIS_VLOG_LIST := genesis_vlog.vf
GENESIS_SYNTH_LIST := $(GENESIS_VLOG_LIST:%.vf=%.synth.vf)
GENESIS_VERIF_LIST := $(GENESIS_VLOG_LIST:%.vf=%.verif.vf)

# Input xml/cfg files, input parameters
GENESIS_CFG_XML	:=
GENESIS_CFG_SCRIPT	:=
GENESIS_PARAMS	:=

# output xml hierarchy file
ifndef GENESIS_HIERARCHY
GENESIS_HIERARCHY := $(FPPRODUCT).xml
else
  $(warning WARNING: GENESIS_HIERARCHY set to $(GENESIS_HIERARCHY))
endif

# For more Genesis parsing options, type 'Genesis2.pl -help'
#        [-parse]                    ---   should we parse input file to generate perl modules?
#        [-sources|srcpath dir]      ---   Where to find source files
#        [-includes|incpath dir]     ---   Where to find included files
#        [-input file1 .. filen]     ---   List of top level files
#                                    ---   The default is STDIN, but some functions
#                                    ---   (such as "for" or "while")
#                                    ---   may not work properly.
#        [-perl_modules modulename]  ---   Additional perl modules to load
GENESIS_PARSE_FLAGS := 	-parse $(GENESIS_SRC) $(GENESIS_INC) -input $(GENESIS_INPUTS) 		

# For more Genesis parsing options, type 'Genesis2.pl -help'
#        [-generate]                 ---   should we generate a verilog hierarchy?
#        [-top topmodule]            ---   Name of top module to start generation from
#        [-depend filename]          ---   Should Genesis2 generate a dependency file list? (list of input files)
#        [-product filename]         ---   Should Genesis2 generate a product file list? (list of output files)
#        [-hierarchy filename]       ---   Should Genesis2 generate a hierarchy representation tree?
#        [-cfgpath|configs dir]		# Where to find config files (xml/scripts)
#        [-xml filename]             ---   Input XML representation of definitions
#        [-cfg filename]                 # Config file to specify parameter values as a Perl script (overrides xml definitions)
#	 [-parameter path.to.prm1=value1 path.to.another.prm2=value2] --- List of parameter override definitions
#					  				  from command line (overrides xml and cfg definitions)
GENESIS_GEN_FLAGS :=	-gen -top $(GENESIS_TOP) 				\
			-synthtop $(GENESIS_SYNTH_TOP_PATH)			\
			-depend depend.list					\
			-product $(GENESIS_VLOG_LIST)				\
			-hierarchy $(GENESIS_HIERARCHY)				\
			$(GENESIS_CFG)

ifneq ($(strip $(GENESIS_CFG_SCRIPT)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -cfg $(GENESIS_CFG_SCRIPT)
  $(warning WARNING: GENESIS_CFG_SCRIPT set to $(GENESIS_CFG_SCRIPT))
endif
ifneq ($(strip $(GENESIS_CFG_XML)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -xml $(GENESIS_CFG_XML)
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
endif
ifneq ($(strip $(GENESIS_PARAMS)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -parameter $(GENESIS_PARAMS)
  $(warning WARNING: GENESIS_PARAMS set to $(GENESIS_PARAMS))
endif


##### FLAGS FOR SYNOPSYS VCS COMPILATION #####
##############################################
SIMV = $(RUNDIR)/simv

SIM_TOP = top_$(FPPRODUCT)

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=  	$(VERILOG_ENV)	$(VERILOG_DESIGN)					

SYNOPSYS := /hd/cad/synopsys/dc_shell/latest

VERILOG_LIBS := 	-y $(RUNDIR) +incdir+$(RUNDIR)			\
			-y $(SYNOPSYS)/dw/sim_ver/			\
			+incdir+$(SYNOPSYS)/dw/sim_ver/			\
			-y $(SYNOPSYS)/packages/gtech/src_ver/		\
			+incdir+$(SYNOPSYS)/packages/gtech/src_ver/

ifndef TCBN45GS_VERILOG
  $(error ERROR TCBN45GS_VERILOG not defined)
endif
ifndef TCBN45GSLVT_VERILOG
  $(error ERROR TCBN45GSLVT_VERILOG not defined)
endif
ifndef TCBN45GSHVT_VERILOG
  $(error ERROR TCBN45GSHVT_VERILOG not defined)
endif

VERILOG_GATE_LIBS :=	-v $(TCBN45GS_VERILOG)                          \
			-v $(TCBN45GSLVT_VERILOG)                       \
			-v $(TCBN45GSHVT_VERILOG)


# "-sverilog" enables system verilog
# "+lint=PCWM" enables linting error messages
# "+libext+.v" specifies that library files (imported by the "-y" directive) ends with ".v"
# "-notice" used to get details when ports are coerced to inout
# "-full64" for 64 bit compilation and simulation
# "+v2k" for verilog 2001 constructs such as generate
# "-timescale=1ns/1ns" sets the time unit and time precision for the entire design
# "+noportcoerce" compile-time option to shut off the port coercion for the entire design
# "-top topModuleName" specifies the top module
# "-f verilogFiles.list" specifies a file that contains list of verilog files to compile
# "+memcbk" Enables callbacks for memories and multi-dimensional arrays (MDAs). 
VERILOG_COMPILE_FLAGS := 	-sverilog 					\
				+cli 						\
                                +memcbk                                         \
				+lint=PCWM					\
				+libext+.v					\
				-notice						\
				-full64						\
				+v2k						\
				-debug_pp					\
				-timescale=1ps/1ps				\
				+noportcoerce         				\
				-ld $(VCS_CC) 					\
				-top $(SIM_TOP)					\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "+vpdbufsize+100" limit the internal buffer to 100MB (forces flushing to disk)
# "+vpdports" Record information about ports (signal/in/out)
# "+vpdfileswitchsize+1000" limits the wave file to 1G (then switch to next file)
VERILOG_SIMULATION_FLAGS := 	$(VERILOG_SIMULATION_FLAGS) 			\
				-l simv.log					\
				+vpdbufsize+100					\
				+vpdfileswitchsize+100
##### END OF FLAGS FOR SYNOPSYS COMPILATION ####




##### FLAGS FOR IBM's FPGEN #####
#################################
IBM_FPGEN_SEED := 12345
IBM_FPGEN_CLUSTER_SIZE := 100
IBM_FPGEN_CLUSTER_INDEX := 0
IBM_FPGEN_TYPE := fmadd
IBM_SRC_DIR := $(DESIGN_HOME)/IBM-TestVectors
IBM_TRGT_DIR := IBM-GenVectors
IBM_COVERAGE_MODEL := ch-5-1-2-3-All-Exponents.fpdef
IBM_FPDEF_FILE := $(IBM_SRC_DIR)/GenericTP/$(IBM_COVERAGE_MODEL)
IBM_FPRES_FILE := $(IBM_COVERAGE_MODEL)_$(IBM_FPGEN_CLUSTER_SIZE)_$(IBM_FPGEN_CLUSTER_INDEX).fpres
IBM_FPLOG_FILE := $(IBM_COVERAGE_MODEL)_$(IBM_FPGEN_CLUSTER_SIZE)_$(IBM_FPGEN_CLUSTER_INDEX).fplog
IBM_TESTVEC_FILE := $(IBM_COVERAGE_MODEL)_$(IBM_FPGEN_CLUSTER_SIZE)_$(IBM_FPGEN_CLUSTER_INDEX).fpvec
IBM_FPGEN_FLAGS := 	-o $(IBM_TRGT_DIR)		\
		-r $(IBM_FPRES_FILE)			\
		-l $(IBM_FPLOG_FILE)			\
		-S $(IBM_FPGEN_SEED)			\
		-C $(IBM_FPGEN_CLUSTER_SIZE)		\
		-i $(IBM_FPGEN_CLUSTER_INDEX)		\
		-M $(IBM_FPGEN_TYPE)
######## END OF FLAGS FOR IBM's FPGEN #####



##### FLAGS FOR SYNOPSYS DC-SHELL #####
#######################################
VT 		?= svt
VOLTAGE 	?= 1v0
IO2CORE 	?= 30
SYN_CLK_PERIOD 	?= 1.5
SYN_CLK_PERIOD_PS = $(strip $(shell echo $(SYN_CLK_PERIOD)*1000 | bc ))
TARGET_DELAY 	?= $(SYN_CLK_PERIOD_PS)
SMART_RETIMING 	?= 0
CLK_GATING 	?= 1
USE_SAIF	?= 1
USE_GATE_SAIF	?= 1
USE_ICC_GATE_SAIF ?= $(USE_GATE_SAIF)
# flags for dc/icc
DESIGN_TARGET	= $(FPPRODUCT)
SYNTH_DIR_NAME 	:= syn_$(VT)_$(VOLTAGE)_$(TARGET_DELAY)
ifdef APPENDIX
  SYNTH_DIR_NAME 	:= $(SYNTH_DIR_NAME)_$(APPENDIX)
endif
SYNTH_HOME	= $(DESIGN_HOME)/synthesis
SYNTH_RUNDIR	= $(RUNDIR)/synthesis/$(SYNTH_DIR_NAME)
SYNTH_SAIF	= $(SYNTH_RUNDIR)/SAIF
SYNTH_LOGS	= $(SYNTH_RUNDIR)/log
DC_NETLIST	= $(DESIGN_TARGET).${VT}_${VOLTAGE}.$(TARGET_DELAY).mapped.v
ICC_NETLIST	= $(DESIGN_TARGET).${VT}_${VOLTAGE}.$(TARGET_DELAY).routed.v
ICC_OPT_NETLIST = $(DESIGN_TARGET).${VT}_${VOLTAGE}_optimized.$(TARGET_DELAY).routed.v
DC_LOG	= $(SYNTH_LOGS)/dc.log
DC_PWR_LOG = $(SYNTH_LOGS)/pwr_dc.log 
DC_SIMV	= $(SYNTH_SAIF)/dc_simv


SET_SYNTH_PARAMS = 	set DESIGN_HOME $(DESIGN_HOME); 	\
			set RUNDIR $(RUNDIR); 			\
			set DESIGN_TARGET $(DESIGN_TARGET); 	\
			set VT  $(VT); 				\
			set Voltage $(VOLTAGE); 		\
			set target_delay $(TARGET_DELAY); 	\
			set io2core $(IO2CORE);  		\
			set SmartRetiming $(SMART_RETIMING);  	\
			set EnableClockGating $(CLK_GATING);    \
			set USE_GATE_SAIF $(USE_GATE_SAIF);     \
			set USE_ICC_GATE_SAIF $(USE_ICC_GATE_SAIF); \
                        set DC_NETLIST $(DC_NETLIST);		\
                        set ICC_NETLIST $(ICC_NETLIST);		\
                        set ICC_OPT_NETLIST $(ICC_OPT_NETLIST);


DC_COMMAND_STRING = "$(SET_SYNTH_PARAMS) source -echo -verbose $(SYNTH_HOME)/multiplier_dc.tcl"
DC_PWR_COMMAND_STRING= "$(SET_SYNTH_PARAMS) source -echo -verbose $(SYNTH_HOME)/report_power_dc.tcl"

## Additional Flags for ICC
ICC_LOG 		:= $(SYNTH_LOGS)/icc.log
ICC_PWR_LOG 		:= $(SYNTH_LOGS)/pwr_icc.log
ICC_SIMV 		:= $(SYNTH_SAIF)/icc_simv

ICC_OPT_LOG 		:= $(SYNTH_LOGS)/icc_opt.log
ICC_OPT_PWR_LOG 	:= $(SYNTH_LOGS)/pwr_icc_opt.log
ICC_OPT_SIMV 		:= $(SYNTH_SAIF)/icc_opt_simv

ICC_COMMAND_STRING = "$(SET_SYNTH_PARAMS)  source -echo -verbose $(SYNTH_HOME)/multiplier_icc.tcl"
ICC_PWR_COMMAND_STRING= "$(SET_SYNTH_PARAMS) source -echo -verbose $(SYNTH_HOME)/report_power_icc.tcl"

ICC_OPT_COMMAND_STRING = "set ENABLE_MANUAL_PLACEMENT 1; $(SET_SYNTH_PARAMS)  source -echo -verbose $(SYNTH_HOME)/multiplier_icc.tcl"
ICC_OPT_PWR_COMMAND_STRING = "set ENABLE_MANUAL_PLACEMENT 1; $(SET_SYNTH_PARAMS)  source -echo -verbose $(SYNTH_HOME)/report_power_icc.tcl"



# For activity factor extraction (SAIF)
SAIF_FILE 	= $(SYNTH_RUNDIR)/$(FPPRODUCT).saif
DC_ADD_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).dc.add.saif
DC_MUL_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).dc.mul.saif
DC_AVG_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).dc.avg.saif
DC_MULADD_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).dc.muladd.saif
ICC_ADD_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc.add.saif
ICC_MUL_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc.mul.saif
ICC_AVG_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc.avg.saif
ICC_MULADD_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc.muladd.saif
ICC_OPT_ADD_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc_opt.add.saif
ICC_OPT_MUL_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc_opt.mul.saif
ICC_OPT_AVG_SAIF_FILE	= $(SYNTH_SAIF)/$(FPPRODUCT).icc_opt.avg.saif
ICC_OPT_MULADD_SAIF_FILE= $(SYNTH_SAIF)/$(FPPRODUCT).icc_opt.muladd.saif


# No saif dependency if not USE_SAIF
ifneq ($(USE_SAIF),0)
  SAIF_DEPENDENCY = $(SAIF_FILE)
endif

ifneq ($(USE_GATE_SAIF),0)
  DC_SAIF_DEPENDENCY = $(DC_AVG_SAIF_FILE) $(DC_MULADD_SAIF_FILE) $(DC_MUL_SAIF_FILE) $(DC_ADD_SAIF_FILE)
endif

ifneq ($(USE_ICC_GATE_SAIF),0)
  ICC_SAIF_DEPENDENCY = $(ICC_AVG_SAIF_FILE) $(ICC_MULADD_SAIF_FILE) $(ICC_MUL_SAIF_FILE) $(ICC_ADD_SAIF_FILE)
  ICC_OPT_SAIF_DEPENDENCY = $(ICC_OPT_AVG_SAIF_FILE) $(ICC_OPT_MULADD_SAIF_FILE) $(ICC_OPT_MUL_SAIF_FILE) $(ICC_OPT_ADD_SAIF_FILE)
endif


# Each one of the following weights control the relative frequency of that type of fp number generated. 
# Except for 'SignIsPos' which is percent positive numbers, the weights are relative to 
# one another, not to any absolute number.
SAIF_RUNTIME_ARGS:= 	+SAIF +clk_period=$(SYN_CLK_PERIOD_PS)	\
			+NumTrans=1000				\
			+Silent					\
			+SignIsPos_DistWeight=50		\
			+Zero_DistWeight=10	 		\
			+Denorm100_DistWeight=1			\
			+DenormFFF_DistWeight=1			\
			+Denorm001_DistWeight=1			\
			+DenormRnd_DistWeight=1			\
			+QuietNaN_DistWeight=1			\
			+SignalingNaN_DistWeight=1		\
			+Min_DistWeight=1			\
			+Max_DistWeight=1			\
			+Inf_DistWeight=1			\
			+One_DistWeight=10			\
			+PointOneOneOne_DistWeight=1		\
			+EzAndSml_DistWeight=1			\
			+Random_DistWeight=200

######## END OF FLAGS FOR SYNOPSYS DC-SHELL #####


################################################################################
################ Makefile Rules
################################################################################
#default rule: 
all: run


###### Genesis2 rules: ######
#############################
# phony rules for verilog generation process
.PHONY: gen genesis_clean
gen: $(GENESIS_VLOG_LIST) $(GENESIS_SYNTH_LIST) $(GENESIS_VERIF_LIST)

# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the genesis (.vp) program.
# Use "make gen GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST) $(GENESIS_SYNTH_LIST) $(GENESIS_VERIF_LIST): $(GENESIS_INPUTS) $(GENESIS_CFG_XML) $(GENESIS_CFG_SCRIPT)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_GEN_FLAGS) $(GEN) $(GENESIS_PARSE_FLAGS) -debug $(GENESIS_DBG_LEVEL) 
	locDesignMap.pl TCL=gen_params.tcl INPUT_XML=small_$(GENESIS_HIERARCHY) DESIGN_FILE=BB_$(FPPRODUCT).design LOC_DESIGN_MAP_FILE=/dev/null PARAM_LIST_FILE=/dev/null PARAM_ATTRIBUTE_FILE=/dev/null > /dev/null

genesis_clean:
	@echo ""
	@echo Cleanning previous runs of Genesis
	@echo ===================================
	@if test -f "genesis_clean.cmd"; then 	\
		 ./genesis_clean.cmd;		\
	fi
	\rm -rf $(GENESIS_VLOG_LIST) $(GENESIS_SYNTH_LIST) $(GENESIS_VERIF_LIST)
###### END OF Genesis2 Rules #######



# VCS compile rules:
#####################
# compile rules:
# use "make COMP=+define+<compile_time_flag[=value]>" to add compile time flags
.PHONY: comp
comp: $(SIMV)

$(SIMV):$(GENESIS_VLOG_LIST)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	sleep 1;
	vcs  $(VERILOG_COMPILE_FLAGS) -f $(RUNDIR)/$(GENESIS_VLOG_LIST) $(COMP) 2>&1 | tee comp_bb.log 


# IBM's fpgen rules:
#####################
.PHONY: ibm_fpgen

ibm_fpgen: $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)

$(IBM_TRGT_DIR)/$(IBM_FPRES_FILE):$(IBM_FPDEF_FILE)
	@echo ""
	@echo Now Running IBM\'s fpgen tool, generating $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)
	@echo =======================================================================
	sleep 1;
	if test ! -d "$(IBM_TRGT_DIR)"; then 	\
		mkdir $(IBM_TRGT_DIR);		\
	fi
	fpgen $(IBM_FPDEF_FILE) $(IBM_FPGEN_FLAGS)


$(IBM_TRGT_DIR)/$(IBM_TESTVEC_FILE): $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)
	@echo ""
	@echo Now Converting $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)
	@echo =======================================================================
	$(DESIGN_HOME)/scripts/converter.pl $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)



# Simulation rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: run run_ibm
run: $(SIMV)
	@echo ""
	@echo Now Running simv
	@echo ==================================================
	$(SIMV) $(VERILOG_SIMULATION_FLAGS) $(RUN) -l run_bb.log

run_ibm: $(SIMV) $(IBM_TRGT_DIR)/$(IBM_TESTVEC_FILE)
	@echo ""Architecture
	@echo Now Running simv using IBM\'s fpgen generated vectors
	@echo ==================================================
	$(SIMV) $(VERILOG_SIMULATION_FLAGS) $(RUN) +File=$(IBM_TRGT_DIR)/$(IBM_TESTVEC_FILE) -l run_bb.log


# DC & ICC Run rules:
############################
$(SAIF_FILE): $(SIMV)
	@echo ""
	@echo Now Running simv for RTL level SAIF extraction: Making $@ because of $?
	@echo ==================================================
	@if test ! -d "$(SYNTH_RUNDIR)"; then 					\
		mkdir -p $(SYNTH_RUNDIR);					\
	fi
	cd $(SYNTH_RUNDIR); 							\
	$(SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) $(RUN) -l $(SIMV).rtl_saif.log


# Design Compiler rules:
.PHONY: force_dc run_dc dc_clean

force_dc: dc_clean run_dc
run_dc: $(DC_PWR_LOG)
$(DC_LOG): $(SAIF_DEPENDENCY) $(GENESIS_SYNTH_LIST) $(SYNTH_HOME)/multiplier_dc.tcl
	@echo ""
	@echo Now Running DC SHELL: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 					\
		mkdir -p $(SYNTH_LOGS);						\
	fi
	@echo "Host: `hostname -A`" > $(SYNTH_RUNDIR)/run_dc.stats
	@echo "Start: `date`" >> $(SYNTH_RUNDIR)/run_dc.stats
	cd $(SYNTH_RUNDIR); dc_shell-xg-t -64bit -topo -x $(DC_COMMAND_STRING) 2>&1 | tee -i $(DC_LOG)
	@echo "Finish: `date`" >> $(SYNTH_RUNDIR)/run_dc.stats
	perl $(DESIGN_HOME)/scripts/checkRun.pl $(DC_LOG)

$(DC_SIMV): $(DC_LOG)
	@echo ""
	@echo Now Compiling Gate Level SAIF testbench : Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_SAIF)"; then 					\
		mkdir -p $(SYNTH_SAIF);						\
	fi
	cd $(SYNTH_SAIF);								\
	if test ! -d "genesis_verif"; then ln -sf $(RUNDIR)/genesis_verif; fi;		\
	if test ! -d "genesis_synth"; then ln -sf $(RUNDIR)/genesis_synth; fi;		\
	vcs $(VERILOG_COMPILE_FLAGS) $(VERILOG_GATE_LIBS) $(SYNTH_SAIF)/$(DC_NETLIST)   \
	    -f $(RUNDIR)/$(GENESIS_VERIF_LIST) -o $(DC_SIMV) $(COMP) 2>&1 | tee comp_dc_bb.log


$(DC_AVG_SAIF_FILE) $(DC_ADD_SAIF_FILE) $(DC_MUL_SAIF_FILE) $(DC_MULADD_SAIF_FILE): $(DC_SIMV)
	@echo ""
	@echo Now Running dc_simv for gate level SAIF extraction: Making $@ because of $?
	@echo ==============================================================
	@sleep 1;
	cd $(SYNTH_SAIF);					 			\
	$(DC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=30 	\
	     +AddWeight=40 $(RUN) -l $(DC_SIMV).avg_saif.log;				\
	mv $(FPPRODUCT).saif $(FPPRODUCT).dc.avg.saif;					\
	$(DC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=0 	\
	     +AddWeight=100 $(RUN) -l $(DC_SIMV).add_saif.log;				\
	mv $(FPPRODUCT).saif $(FPPRODUCT).dc.add.saif;					\
	$(DC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=100 	\
	     +AddWeight=0 $(RUN) -l $(DC_SIMV).mul_saif.log;				\
	mv $(FPPRODUCT).saif $(FPPRODUCT).dc.mul.saif;					\
	$(DC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=0 	\
	     +AddWeight=0 $(RUN) -l $(DC_SIMV).muladd_saif.log;				\
	mv $(FPPRODUCT).saif $(FPPRODUCT).dc.muladd.saif;


$(DC_PWR_LOG): $(DC_SAIF_DEPENDENCY) $(DC_LOG) $(SYNTH_HOME)/report_power_dc.tcl
	@echo ""
	@echo Now Running DC SHELL: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	cd $(SYNTH_RUNDIR);	 							\
	dc_shell-xg-t -64bit -topo -x $(DC_PWR_COMMAND_STRING) 2>&1 | tee -i $(DC_PWR_LOG)
	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(DC_PWR_LOG)

dc_clean:
	@echo ""
	@echo Removing previous DC run log
	@echo =============================================
	\rm -f $(DC_LOG) $(DC_PWR_LOG)

# IC Compiler rules:
.PHONY: force_icc run_icc icc_clean
.PHONY: force_icc_opt run_icc_opt icc_opt_clean

force_icc: icc_clean run_icc
run_icc: $(ICC_PWR_LOG)
force_icc_opt: icc_opt_clean run_icc_opt
run_icc_opt: $(ICC_OPT_PWR_LOG)

$(ICC_LOG): $(DC_PWR_LOG) $(GENESIS_SYNTH_LIST) $(SYNTH_HOME)/multiplier_icc.tcl
	@echo ""
	@echo Now Running IC Compiler: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	@echo "Host: `hostname -A`" > $(SYNTH_RUNDIR)/run_icc.stats
	@echo "Start: `date`" >> $(SYNTH_RUNDIR)/run_icc.stats
	cd $(SYNTH_RUNDIR); icc_shell -64bit -x $(ICC_COMMAND_STRING) 2>&1 | tee -i $(ICC_LOG)	
	@echo "Finish: `date`" >> $(SYNTH_RUNDIR)/run_icc.stats
#	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(ICC_LOG)

$(ICC_SIMV): $(ICC_LOG)
	@echo ""
	@echo Now Compiling Gate Level SAIF testbench : Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_SAIF)"; then 	\
		mkdir -p $(SYNTH_SAIF);		\
	fi
	cd $(SYNTH_SAIF);								\
	if test ! -d "genesis_verif"; then ln -sf $(RUNDIR)/genesis_verif; fi;		\
	if test ! -d "genesis_synth"; then ln -sf $(RUNDIR)/genesis_synth; fi;		\
	vcs $(VERILOG_COMPILE_FLAGS) $(VERILOG_GATE_LIBS) $(SYNTH_SAIF)/$(ICC_NETLIST) 	\
	    -f $(RUNDIR)/$(GENESIS_VERIF_LIST) -o $(ICC_SIMV) $(COMP) 2>&1 | tee comp_icc_bb.log


$(ICC_AVG_SAIF_FILE) $(ICC_ADD_SAIF_FILE) $(ICC_MUL_SAIF_FILE) $(ICC_MULADD_SAIF_FILE): $(ICC_SIMV)
	@echo ""
	@echo Now Running icc_simv for gate level SAIF extraction: Making $@ because of $?
	@echo ==============================================================
	@sleep 1;
	cd $(SYNTH_SAIF); 								\
	$(ICC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=30 	\
	      +AddWeight=40 +IgnoreErrors $(RUN) -l $(ICC_SIMV).avg_saif.log;		\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.avg.saif;					\
	$(ICC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=0 	\
	      +AddWeight=100 +IgnoreErrors $(RUN) -l $(ICC_SIMV).add_saif.log;		\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.add.saif;					\
	$(ICC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=100 	\
	      +AddWeight=0 +IgnoreErrors $(RUN) -l $(ICC_SIMV).mul_saif.log;		\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.mul.saif;					\
	$(ICC_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=0 	\
	      +AddWeight=0 +IgnoreErrors $(RUN) -l $(ICC_SIMV).muladd_saif.log;		\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.muladd.saif;


$(ICC_PWR_LOG): $(ICC_SAIF_DEPENDENCY) $(ICC_LOG) $(SYNTH_HOME)/report_power_icc.tcl
	@echo ""
	@echo Now Running ICC SHELL: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	cd $(SYNTH_RUNDIR); 								\
	icc_shell -64bit -x $(ICC_PWR_COMMAND_STRING) 2>&1 | tee -i $(ICC_PWR_LOG)
	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(ICC_PWR_LOG)


icc_clean:
	@echo ""
	@echo Removing previous ICC run log
	@echo =============================================
	\rm -f $(ICC_LOG)

$(ICC_OPT_LOG): $(SAIF_DEPENDENCY) $(DC_PWR_LOG) $(GENESIS_SYNTH_LIST) $(SYNTH_HOME)/multiplier_icc.tcl
	@echo ""
	@echo Now Running IC Compiler OPT: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	@echo "Host: `hostname -A`" > $(SYNTH_RUNDIR)/run_icc_opt.stats
	@echo "Start: `date`" >> $(SYNTH_RUNDIR)/run_icc_opt.stats
	cd $(SYNTH_RUNDIR); icc_shell -64bit -x $(ICC_OPT_COMMAND_STRING) 2>&1 | tee -i $(ICC_OPT_LOG)
	@echo "Finish: `date`" >> $(SYNTH_RUNDIR)/run_icc_opt.stats
#	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(ICC_OPT_LOG)

$(ICC_OPT_SIMV): $(ICC_OPT_LOG)
	@echo ""
	@echo Now Compiling Gate Level optimized ICC SAIF testbench : Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_SAIF)"; then 	\
		mkdir -p $(SYNTH_SAIF);		\
	fi
	cd $(SYNTH_SAIF);								\
	if test ! -d "genesis_verif"; then ln -sf $(RUNDIR)/genesis_verif; fi;		\
	if test ! -d "genesis_synth"; then ln -sf $(RUNDIR)/genesis_synth; fi;		\
	vcs $(VERILOG_COMPILE_FLAGS) $(VERILOG_GATE_LIBS) $(SYNTH_SAIF)/$(ICC_OPT_NETLIST) 	\
	    -f $(RUNDIR)/$(GENESIS_VERIF_LIST) -o $(ICC_OPT_SIMV) $(COMP) 2>&1 | tee comp_icc_bb.log

$(ICC_OPT_AVG_SAIF_FILE) $(ICC_OPT_ADD_SAIF_FILE) $(ICC_OPT_MUL_SAIF_FILE) $(ICC_OPT_MULADD_SAIF_FILE): $(ICC_OPT_SIMV)
	@echo ""
	@echo Now Running icc_opt_simv for gate level SAIF extraction: Making $@ because of $?
	@echo ==============================================================
	@sleep 1;
	cd $(SYNTH_SAIF); 								\
	$(ICC_OPT_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=30 	\
	      +AddWeight=40 +IgnoreErrors $(RUN) -l $(ICC_OPT_SIMV).avg_saif.log;	\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.avg.saif;					\
	$(ICC_OPT_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=0 	\
	      +AddWeight=100 +IgnoreErrors $(RUN) -l $(ICC_OPT_SIMV).add_saif.log;	\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.add.saif;					\
	$(ICC_OPT_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=100 \
	      +AddWeight=0 +IgnoreErrors $(RUN) -l $(ICC_OPT_SIMV).mul_saif.log;	\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.mul.saif;					\
	$(ICC_OPT_SIMV) $(VERILOG_SIMULATION_FLAGS) $(SAIF_RUNTIME_ARGS) +MulWeight=0 	\
	      +AddWeight=0 +IgnoreErrors $(RUN) -l $(ICC_OPT_SIMV).muladd_saif.log;	\
	mv $(FPPRODUCT).saif $(FPPRODUCT).icc.muladd.saif;



$(ICC_OPT_PWR_LOG): $(ICC_OPT_SAIF_DEPENDENCY) $(ICC_OPT_LOG) $(SYNTH_HOME)/report_power_icc.tcl
	@echo ""
	@echo Now Running ICC SHELL: Making $@ because of $?
	@echo =============================================
	@sleep 1;
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	cd $(SYNTH_RUNDIR); 							\
	icc_shell -64bit -x $(ICC_OPT_PWR_COMMAND_STRING) 2>&1 | tee -i $(ICC_OPT_PWR_LOG)
	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(ICC_OPT_PWR_LOG)


icc_opt_clean:
	@echo ""
	@echo Removing previous ICC run log
	@echo =============================================
	\rm -f $(ICC_OPT_LOG)

# One more rule to clean all synthesis/pnr related stuff
.PHONY: synthesis_clean
synthesis_clean:
	\rm -rf $(SYNTH_RUNDIR)

#Rollup Rules:
##############################
DESIGN_TITLE ?= $(FPPRODUCT)
ROLLUP_TARGET ?= $(DESIGN_TITLE)_Rollup.target

.PHONY: rollup1  rollup2 rollup3 report_results

ROLLUP_CMD = perl $(DESIGN_HOME)/scripts/BB_rollup.pl -d $(FPPRODUCT) \
		 			 	 -t $(ROLLUP_TARGET) \
						 DC_LOG=$(DC_LOG) \
						 ICC_LOG=$(ICC_LOG) \
						 ICC_OPT_LOG=$(ICC_OPT_LOG) \
						 DESIGN_FILE=BB_$(FPPRODUCT).design \
	                                   	 VT=$(VT) \
						 Voltage=$(VOLTAGE) \
						 target_delay=$(TARGET_DELAY) \
						 io2core=$(IO2CORE) \
						 SmartRetiming=$(SMART_RETIMING) \
						 EnableClockGating=$(CLK_GATING)

rollup1: 
	$(ROLLUP_CMD) 2>&1 | tee -i rollup_bb.log

rollup2: 
	$(ROLLUP_CMD)

rollup3: 
	$(ROLLUP_CMD)

rollup4: 
	$(ROLLUP_CMD)



report_results:
	cd synthesis ; perl report_results.pl ;

#Design Space Map Rules:
###################################
design_map:
	locDesignMap.pl INPUT_XML=small_$(GENESIS_HIERARCHY) DESIGN_FILE=BB_$(FPPRODUCT).design LOC_DESIGN_MAP_FILE=/dev/null PARAM_LIST_FILE=/dev/null PARAM_ATTRIBUTE_FILE=/dev/null


#PipeLine Hack:
###############################

#Eval Rules
##############################
.PHONY: eval eval2 eval3 eval4
eval: gen comp rollup1 run rollup2 gen_syn run_synthesis rollup3 report_results
eval2: gen comp run gen_syn run_synthesis
eval3: gen comp run gen_syn run_dc rollup1 report_results
eval4: gen comp run gen_syn run_dc

# Cleanup rules:
#####################
.PHONY: clean cleanall 
clean: genesis_clean synthesis_clean
	@echo ""
	@echo Cleanning old files, objects, logs and garbage
	@echo ==================================================
	\rm -rf $(SIMV) simv.*
	\rm -f *.tcl
	\rm -f *.info
	\rm -rf csrc
	\rm -rf *.daidir
	\rm -rf *.log
	\rm -rf *.pvl
	\rm -rf *.syn
	\rm -rf *.mr
	\rm -rf *.pvk
	\rm -rf *.flc
	\rm -rf ucli.key
	\rm -rf *~
	\rm -rf top.v
	\rm -rf top_*.v
	\rm -f graph_*.m
	\rm -rf $(IBM_TRGT_DIR)
	\rm -f $(SAIF_FILE)

cleanall: clean 
	\rm -rf DVE*
	\rm -rf vcdplus.vpd
	\rm -rf genesis*
	\rm -f TEST_PASS
	\rm -f TEST_FAIL
