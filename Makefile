##############################################################################
################ Makefile Definitions
################################################################################


########### Generic Env Defs ############
#########################################
# Product is 
# - FPGen which is an FP multiply Accumulator (default)
# - FPMult which is an FP multiplier only
PRODUCT := FPGen

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
GENESIS_TOP = top_$(PRODUCT)
GENESIS_SYNTH_TOP_PATH = $(GENESIS_TOP).$(PRODUCT)


# list src folders and include folders
GENESIS_SRC := 	-srcpath ./			\
		-srcpath $(DESIGN_HOME)/rtl	\
		-srcpath $(DESIGN_HOME)/verif			

GENESIS_INC := 	-incpath ./			\
		-incpath $(DESIGN_HOME)/rtl	\
		-incpath $(DESIGN_HOME)/verif

# vpath directive tells where to search for *.vp and *.vph files
vpath 	%.vp  $(GENESIS_SRC)
vpath 	%.svp  $(GENESIS_SRC)
vpath 	%.vph $(GENESIS_INC)
vpath 	%.svph $(GENESIS_INC)


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

# Input xml/cfg files, input parameters
GENESIS_CFG_XML	:=
GENESIS_CFG_SCRIPT	:=
GENESIS_PARAMS	:=

# output xml hierarchy file
ifndef GENESIS_HIERARCHY
GENESIS_HIERARCHY := $(PRODUCT).xml
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
#        [-xml filename]             ---   Input XML representation of definitions
#        [-cfg filename]                 # Config file to specify parameter values as a Perl script (overrides xml definitions)
#	 [-parameter path.to.prm1=value1 path.to.another.prm2=value2] --- List of parameter override definitions
#					  				  from command line (overrides xml and cfg definitions)
GENESIS_GEN_FLAGS :=	-gen -top $(GENESIS_TOP) 				\
			-synthtop $(GENESIS_SYNTH_TOP_PATH)			\
			-depend depend.list					\
			-product $(GENESIS_VLOG_LIST)				\
			-hierarchy $(GENESIS_HIERARCHY)

ifneq ($(strip $(GENESIS_CFG_XML)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -xml $(GENESIS_CFG_XML)
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
endif
ifneq ($(strip $(GENESIS_CFG_SCRIPT)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -cfg $(GENESIS_CFG_SCRIPT)
  $(warning WARNING: GENESIS_CFG_SCRIPT set to $(GENESIS_CFG_SCRIPT))
endif
ifneq ($(strip $(GENESIS_PARAMS)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -parameter $(GENESIS_PARAMS)
  $(warning WARNING: GENESIS_PARAMS set to $(GENESIS_PARAMS))
endif


##### FLAGS FOR SYNOPSYS VCS COMPILATION #####
##############################################
SIM_TOP = top_$(PRODUCT)

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=  	$(VERILOG_ENV)	$(VERILOG_DESIGN)					

SYNOPSYS := /hd/cad/synopsys/dc_shell/latest

VERILOG_LIBS := 	-y $(SYNOPSYS)/dw/sim_ver/		\
			+incdir+$(SYNOPSYS)/dw/sim_ver/	\
			-y $(SYNOPSYS)/packages/gtech/src_ver/	\
			+incdir+$(SYNOPSYS)/packages/gtech/src_ver/  


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
VERILOG_COMPILE_FLAGS := 	-sverilog 					\
				+cli 						\
				+lint=PCWM					\
				+libext+.v					\
				-notice						\
				-full64						\
				+v2k						\
				-debug_pp					\
				-timescale=1ps/1ps				\
				+noportcoerce         				\
				-ld $(VCS_CC) -debug_pp				\
				-top $(SIM_TOP)				\
				-f $(GENESIS_VLOG_LIST) 			\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "+vpdbufsize+100" limit the internal buffer to 100MB (forces flushing to disk)
# "+vpdports" Record information about ports (signal/in/out)
# "+vpdfileswitchsize+1000" limits the wave file to 1G (then switch to next file)
VERILOG_SIMULATION_FLAGS := 	$(VERILOG_SIMULATION_FLAGS) 			\
				-l simv.log					\
				+vpdbufsize+100					\
				+vpdfileswitchsize+100                          \
                                +clk_period=$(SYN_CLK_PERIOD)
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
SAIF_FILE 	= $(PRODUCT).saif
VT 		?= svt
VOLTAGE 	?= 1v0
IO2CORE 	?= 30
SYN_CLK_PERIOD ?= 1.5
TARGET_DELAY 	?= $(shell echo $(SYN_CLK_PERIOD)*1000 | bc )
SMART_RETIMING 	?= 0
CLK_GATING 	?= 1



DESIGN_TARGET	= $(PRODUCT)
SYNTH_DIR_NAME 	= syn_$(VT)_$(VOLTAGE)_$(TARGET_DELAY)
ifdef APPENDIX
  SYNTH_DIR_NAME 	= $(SYNTH_DIR_NAME)_$(APPENDIX)
endif
SYNTH_HOME	= $(DESIGN_HOME)/synthesis
SYNTH_RUNDIR 	= $(RUNDIR)/synthesis/$(SYNTH_DIR_NAME)
SYNTH_LOGS	= $(SYNTH_RUNDIR)/log
DC_LOG 		= $(SYNTH_LOGS)/dc.log

SET_SYNTH_PARAMS = 	set DESIGN_HOME $(DESIGN_HOME); 	\
			set RUNDIR $(RUNDIR); 			\
			set DESIGN_TARGET $(DESIGN_TARGET); 	\
			set VT  $(VT); 				\
			set Voltage $(VOLTAGE); 		\
			set target_delay $(TARGET_DELAY); 	\
			set io2core $(IO2CORE);  		\
			set SmartRetiming $(SMART_RETIMING);  	\
			set EnableClockGating $(CLK_GATING);
DC_COMMAND_STRING = "$(SET_SYNTH_PARAMS) source -echo -verbose $(SYNTH_HOME)/multiplier_dc.tcl"

## Additional Flags for ICC
ICC_LOG 		:= $(SYNTH_LOGS)/icc.log
ICC_OPT_LOG 		:= $(SYNTH_LOGS)/icc_opt.log

ICC_COMMAND_STRING = "$(SET_SYNTH_PARAMS)  source -echo -verbose $(SYNTH_HOME)/multiplier_icc.tcl"
ICC_OPT_COMMAND_STRING = "set ENABLE_MANUAL_PLACEMENT 1; $(SET_SYNTH_PARAMS)  source -echo -verbose $(SYNTH_HOME)/multiplier_icc.tcl"

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
gen: $(GENESIS_VLOG_LIST) $(GENESIS_SYNTH_LIST)

# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the genesis (.vp) program.
# Use "make gen GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST) $(GENESIS_SYNTH_LIST): $(GENESIS_INPUTS) $(GENESIS_CFG_XML)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_GEN_FLAGS) $(GEN) $(GENESIS_PARSE_FLAGS) -debug $(GENESIS_DBG_LEVEL)

genesis_clean:
	@echo ""
	@echo Cleanning previous runs of Genesis
	@echo ===================================
	@if test -f "genesis_clean.cmd"; then 	\
		tcsh genesis_clean.cmd;	\
	fi
	\rm -rf $(GENESIS_VLOG_LIST) $(GENESIS_SYNTH_LIST)
###### END OF Genesis2 Rules #######


design_map: $(GENESIS_VLOG_LIST)
	locDesignMap.pl TCL=/dev/null INPUT_XML=small_$(GENESIS_HIERARCHY) DESIGN_FILE=BB_$(DESIGN_TITLE).design LOC_DESIGN_MAP_FILE=/dev/null PARAM_LIST_FILE=/dev/null PARAM_ATTRIBUTE_FILE=/dev/nulll


# VCS compile rules:
#####################
# compile rules:
# use "make COMP=+define+<compile_time_flag[=value]>" to add compile time flags
.PHONY: comp
comp: simv

simv:	$(GENESIS_VLOG_LIST)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	vcs  $(VERILOG_COMPILE_FLAGS) $(COMP) 2>&1 | tee comp_bb.log 


# IBM's fpgen rules:
#####################
.PHONY: ibm_fpgen

ibm_fpgen: $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)

$(IBM_TRGT_DIR)/$(IBM_FPRES_FILE):$(IBM_FPDEF_FILE)
	@echo ""
	@echo Now Running IBM\'s fpgen tool, generating $(IBM_TRGT_DIR)/$(IBM_FPRES_FILE)
	@echo =======================================================================
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
run: simv
	@echo ""
	@echo Now Running simv
	@echo ==================================================
	./simv $(VERILOG_SIMULATION_FLAGS) $(RUN) 2>&1 | tee run_bb.log

run_ibm: simv $(IBM_TRGT_DIR)/$(IBM_TESTVEC_FILE)
	@echo ""Architecture
	@echo Now Running simv using IBM\'s fpgen generated vectors
	@echo ==================================================
	./simv $(VERILOG_SIMULATION_FLAGS) $(RUN) +File=$(IBM_TRGT_DIR)/$(IBM_TESTVEC_FILE) 2>&1 | tee run_bb.log


# DC & ICC Run rules:
############################
$(SAIF_FILE): simv
	@echo ""
	@echo Now Running simv for SAIF extraction: Making $@ because of $?
	@echo ==============================================================
	@echo "FIXME: For now just making stuff up ;-)"
	touch FIXME.$(SAIF_FILE)

# Design Compiler rules:
.PHONY: force_dc run_dc dc_clean

force_dc: dc_clean run_dc
run_dc: $(DC_LOG)
$(DC_LOG): $(SAIF_FILE) $(GENESIS_SYNTH_LIST)
	@echo ""
	@echo Now Running DC SHELL: Making $@ because of $?
	@echo =============================================
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	(cd $(SYNTH_RUNDIR); 			\
	dc_shell-xg-t -64bit -x $(DC_COMMAND_STRING) 2>&1 | tee -i $(DC_LOG)	\
	)
	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(DC_LOG)

dc_clean:
	@echo ""
	@echo Removing previous DC run log
	@echo =============================================
	\rm -f $(DC_LOG)

# IC Compiler rules:
.PHONY: force_icc run_icc icc_clean
.PHONY: force_icc_opt run_icc_opt icc_opt_clean

force_icc: icc_clean run_icc
run_icc: $(ICC_LOG)
force_icc_opt: icc_opt_clean run_icc_opt
run_icc_opt: $(ICC_OPT_LOG)

$(ICC_LOG): $(SAIF_FILE) $(DC_LOG) $(GENESIS_SYNTH_LIST)
	@echo ""
	@echo Now Running IC Compiler: Making $@ because of $?
	@echo =============================================
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	(cd $(SYNTH_RUNDIR); 			\
	icc_shell -64bit -x $(ICC_COMMAND_STRING) 2>&1 | tee -i $(ICC_LOG)	\
	)
	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(ICC_LOG)

icc_clean:
	@echo ""
	@echo Removing previous ICC run log
	@echo =============================================
	\rm -f $(ICC_LOG)

$(ICC_OPT_LOG): $(SAIF_FILE) $(DC_LOG) $(GENESIS_SYNTH_LIST)
	@echo ""
	@echo Now Running IC Compiler (OPT): Making $@ because of $?
	@echo =============================================
	@if test ! -d "$(SYNTH_LOGS)"; then 	\
		mkdir -p $(SYNTH_LOGS);		\
	fi
	(cd $(SYNTH_RUNDIR); 			\
	icc_shell -64bit -x $(ICC_OPT_COMMAND_STRING) 2>&1 | tee -i $(ICC_LOG)	\
	)
	@perl $(DESIGN_HOME)/scripts/checkRun.pl $(ICC_OPT_LOG)

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
ROLLUP_TARGET ?= $(DESIGN_TITLE)_Rollup.target

.PHONY: rollup1  rollup2 rollup3 report_results
rollup1: 
	perl scripts/BB_rollup.pl -d $(DESIGN_TITLE) -t $(ROLLUP_TARGET) DESIGN_FILE=BB_$(DESIGN_TITLE).design \
                                   VT=$(VT) Voltage=$(VOLTAGE) target_delay=$(TARGET_DELAY) io2core=$(IO2CORE)
rollup2: 
	perl scripts/BB_rollup.pl -d $(DESIGN_TITLE) -t $(ROLLUP_TARGET) DESIGN_FILE=BB_$(DESIGN_TITLE).design \
                                   VT=$(VT) Voltage=$(VOLTAGE) target_delay=$(TARGET_DELAY) io2core=$(IO2CORE)
rollup3: 
	perl scripts/BB_rollup.pl -d $(DESIGN_TITLE) -t $(ROLLUP_TARGET) DESIGN_FILE=BB_$(DESIGN_TITLE).design \
                                   VT=$(VT) Voltage=$(VOLTAGE) target_delay=$(TARGET_DELAY) io2core=$(IO2CORE)
report_results:
	cd synthesis ; perl report_results.pl ;

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
	\rm -rf simv simv.*
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
	\rm -rf synthesis*