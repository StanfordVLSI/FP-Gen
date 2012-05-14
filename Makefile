##############################################################################
################ Makefile Definitions
################################################################################
# This little trick finds where the makefile exists
# DESIGN_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
DESIGN_HOME := $(dir $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST)))
$(warning WARNING: FPGEN home set to $(DESIGN_HOME)) 

# this line enables a local Makefile to override values of the main makefile
-include Makefile.local

########### Generic Env Defs ############
#########################################
ifndef SIM_ENGINE
SIM_ENGINE := synopsys
  $(warning WARNING: SIM_ENGINE not specified. Using default SIM_ENGINE=synopsys) 
  $(warning WARNING: Rerun with SIM_ENGINE=synopsys or SIM_ENGINE=mentor)
# ifndef SYNOPSYS
#  $(error ERROR: Path to SYNOPSYS not set)
# endif
endif


############# For Genesis2 ##############
#########################################
# tile is the top of the pre-processed hierarchy

SYN_CLK_PERIOD ?= 1.5

PARAM_STRING ?= 
SAIF_MODE ?= 0
SYNTH_PARAM_STRING ?= 
VERIF_PARAM_STRING ?= 

ifndef DESIGN_NAME
  DESIGN_NAME:=MultiplierP
  $(warning WARNING: Running with default design.  DESIGN_NAME=$(DESIGN_NAME))
endif

ifeq ($(DESIGN_NAME),MultiplierP)
  INST_NAME ?= MultiplierP
  MOD_NAME ?= MultiplierP
  TOP_NAME ?= top
  ROLLUP_TARGET ?= MultiplierP_Rollup.target
endif 

ifeq ($(DESIGN_NAME),FPMult)
  INST_NAME ?= FPMult
  MOD_NAME ?= FPMult
  TOP_NAME ?= top_FPMult
  ROLLUP_TARGET ?= FPMult_Rollup.target
endif 

ifeq ($(DESIGN_NAME),FMA)
  INST_NAME ?= FMA
  MOD_NAME ?= FMA
  TOP_NAME ?= top_FMA
  ROLLUP_TARGET ?= FMA_Rollup.target

  PIPELINE_PARAM ?= top_FMA.FMA.PipelineDepth
  RETIME_PARAM ?= top_FMA.FMA.Retiming
  DW_PARAM ?= top_FMA.FMA.Designware_MODE
  INC_PARAM ?= top_FMA.FMA.UseInc
  VERIF_PARAM_1 ?= top_FMA.FMA.VERIF_MODE
  SYNTH_PARAM_1 ?= top_FMA.FMA.SYNTH_MODE
  VERIF_PARAM_2 ?= top_FMA.VERIF_MODE
  SYNTH_PARAM_2 ?= top_FMA.SYNTH_MODE
  SAIF_PARAM ?= top_FMA.SAIF_MODE

  ifeq ($(PIPE_CNT),0)
    RETIME_STATUS ?= 0
  else
    RETIME_STATUS ?= 1
  endif

  over_params =   
  over_params1 =   
  over_params2 =   

  ifdef  PIPE_CNT
   over_params1 = $(PIPELINE_PARAM)=$(PIPE_CNT) $(RETIME_PARAM)=$(RETIME_STATUS)
  endif

  ifeq ($(DW_MODE),1) 
    DW_MODE_STRING ?= ON
    INC_MODE_STRING ?= NO
    FORCE_PARAMS = 1
    over_params2 = $(INC_PARAM)=$(INC_MODE_STRING) $(DW_PARAM)=$(DW_MODE_STRING)
  else
    DW_MODE_STRING ?= "OFF"
  endif

  ifeq ($(SAIF_MODE),1)
    VERIF_STRING := top_FMA.FMA.VERIF_MODE=OFF top_FMA.FMA.SYNTH_MODE=ON top_FMA.VERIF_MODE=OFF top_FMA.SYNTH_MODE=ON top_FMA.SAIF_MODE=ON
    SYNTH_STRING := top_FMA.FMA.VERIF_MODE=OFF top_FMA.FMA.SYNTH_MODE=ON top_FMA.VERIF_MODE=OFF top_FMA.SYNTH_MODE=ON top_FMA.SAIF_MODE=ON
  else
    VERIF_STRING := top_FMA.FMA.VERIF_MODE=ON  top_FMA.FMA.SYNTH_MODE=OFF top_FMA.VERIF_MODE=ON  top_FMA.SYNTH_MODE=OFF top_FMA.SAIF_MODE=OFF
    SYNTH_STRING := top_FMA.FMA.VERIF_MODE=OFF top_FMA.FMA.SYNTH_MODE=ON  top_FMA.VERIF_MODE=OFF top_FMA.SYNTH_MODE=ON  top_FMA.SAIF_MODE=OFF
  endif	

  over_params = $(over_params1) $(over_params2)
  PARAM_STRING += $(over_params)
  SYNTH_PARAM_STRING += $(PARAM_STRING) $(SYNTH_STRING)
  VERIF_PARAM_STRING += $(PARAM_STRING) $(VERIF_STRING)

endif 

ifeq ($(DESIGN_NAME),Multiplier)
  INST_NAME ?= Multiplier
  MOD_NAME ?= Multiplier
  TOP_NAME ?= top_Multiplier
  ROLLUP_TARGET ?= Multiplier_Rollup.target
endif 

ifeq ($(DESIGN_NAME),FPMult)
  INST_NAME ?= FPMult
  MOD_NAME ?= FPMult
  TOP_NAME ?= top_FPMult
  ROLLUP_TARGET ?= FPMult_Rollup.target
endif 

ifeq ($(DESIGN_NAME),adder)
  INST_NAME ?= adder
  MOD_NAME ?= adder
  TOP_NAME ?= top_adder
  ROLLUP_TARGET ?= adder_Rollup.target
endif 

TOP_MODULE ?= $(TOP_NAME)


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

# Input xml program
ifndef GENESIS_CFG_XML
  GENESIS_CFG_XML := 	$(DESIGN_HOME)/empty.xml
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
else
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
endif

# xml hierarchy file
ifndef GENESIS_HIERARCHY
GENESIS_HIERARCHY := $(MOD_NAME).xml
else
  $(warning WARNING: GENESIS_HIERARCHY set to $(GENESIS_HIERARCHY))
endif
GENESIS_TMP_HIERARCHY := $(MOD_NAME)_target.xml
# For more Genesis parsing options, type 'Genesis2.pl -help'
#        [-parse]                    ---   should we parse input file to generate perl modules?
#        [-sources|srcpath dir]      ---   Where to find source files
#        [-includes|incpath dir]     ---   Where to find included files
#        [-input file1 .. filen]     ---   List of top level files
#                                    ---   The default is STDIN, but some functions
#                                    ---   (such as "for" or "while")
#                                    ---   may not work properly.
#        [-perl_modules modulename]  ---   Additional perl modules to load
GENESIS_PARSE_FLAGS := 	-parse $(GENESIS_SRC) $(GENESIS_INC)			

# For more Genesis parsing options, type 'Genesis2.pl -help'
#        [-generate]                 ---   should we generate a verilog hierarchy?
#        [-top topmodule]            ---   Name of top module to start generation from
#        [-depend filename]          ---   Should Genesis2 generate a dependency file list? (list of input files)
#        [-product filename]         ---   Should Genesis2 generate a product file list? (list of output files)
#        [-hierarchy filename]       ---   Should Genesis2 generate a hierarchy representation tree?
#        [-xml filename]             ---   Input XML representation of definitions
GENESIS_GEN_FLAGS :=	-gen -top $(TOP_MODULE)					\
			-depend depend.list					\
			-product $(GENESIS_VLOG_LIST)				\
			-hierarchy $(GENESIS_HIERARCHY)                		\
			-xml $(GENESIS_CFG_XML)
GENESIS_GEN_FLAGS2 :=	-gen -top $(TOP_MODULE)					\
			-depend depend.list					\
			-product $(GENESIS_VLOG_LIST)				\
			-hierarchy $(GENESIS_HIERARCHY)                		\
			-xml small_$(GENESIS_TMP_HIERARCHY)



############### For Verilog ################
############################################

##### FLAGS FOR SYNOPSYS COMPILATION ####
ifeq ($(SIM_ENGINE), synopsys) 
COMPILER := vcs

EXECUTABLE := ./simv

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
				-top $(TOP_MODULE)				\
				-f $(GENESIS_VLOG_LIST) 			\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "+vpdbufsize+100" limit the internal buffer to 100MB (forces flushing to disk)
# "+vpdports" Record information about ports (signal/in/out)
# "+vpdfileswitchsize+1000" limits the wave file to 1G (then switch to next file)
VERILOG_SIMULATION_FLAGS := 	$(VERILOG_SIMULATION_FLAGS) 			\
				-l $(EXECUTABLE).log					\
				+vpdbufsize+100					\
				+vpdfileswitchsize+100                          \
                                +clk_period=$(SYN_CLK_PERIOD)

endif 
##### END OF FLAGS FOR SYNOPSYS COMPILATION ####


##### FLAGS FOR MENTOR COMPILATION ####
ifeq ($(SIM_ENGINE), mentor) 
COMPILER := vlog

EXECUTABLE := vsim

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=  	$(VERILOG_ENV)	$(VERILOG_DESIGN)					

VERILOG_LIBS := 	

# "-source" Displays the associated line of source code before each error 
#	message that is generated during compilation.
# "-sv" Enables SystemVerilog features and keywords.
# "-f fileName" Specifies a file with more command line arguments.
VERILOG_COMPILE_FLAGS := 	-source -sv					\
				-f $(GENESIS_VLOG_LIST) 			\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "-c" Specifies that the simulator is to be run in command-line mode.
# "-capacity" Enables the fine-grain analysis display of memory capacity
VERILOG_SIMULATION_FLAGS := 	-c						\
				$(TOP_MODULE)					\
				-capacity					\
				-do "run -all; quit"  

endif 
##### END OF FLAGS FOR SYNOPSYS COMPILATION ####


##### FLAGS FOR IBM's FPGEN

FPGEN_SEED := 12345
FPGEN_CLUSTER_SIZE := 100
FPGEN_CLUSTER_INDEX := 0
FPGEN_TYPE := fmadd
COVERAGE_MODEL := ch-5-1-2-3-All-Exponents.fpdef
FPDEF_FILE := $(DESIGN_HOME)/testVectors/GenericTP/$(COVERAGE_MODEL)
FPRES_FILE := $(COVERAGE_MODEL)_$(FPGEN_CLUSTER_SIZE)_$(FPGEN_CLUSTER_INDEX).fpres
FPLOG_FILE := $(COVERAGE_MODEL)_$(FPGEN_CLUSTER_SIZE)_$(FPGEN_CLUSTER_INDEX).fplog
TESTVEC_FILE := $(COVERAGE_MODEL)_$(FPGEN_CLUSTER_SIZE)_$(FPGEN_CLUSTER_INDEX).fpvec
FPGEN_FLAGS := 	-o testVectors		\
		-r $(FPRES_FILE)	\
		-l $(FPLOG_FILE)	\
		-S $(FPGEN_SEED)	\
		-C $(FPGEN_CLUSTER_SIZE)	\
		-i $(FPGEN_CLUSTER_INDEX)	\
		-M $(FPGEN_TYPE)
########

################################################################################
################ Makefile Rules
################################################################################
#default rule: 
all: $(EXECUTABLE)

# phony rules for verilog generation process
.PHONY: gen gen2 genesis_clean
gen: $(GENESIS_VLOG_LIST)

# Genesis2 rules:
#####################
# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the genesis (.vp) program.
# Use "make GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST): $(GENESIS_INPUTS) $(GENESIS_CFG_XML)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_GEN_FLAGS) $(GEN) $(GENESIS_PARSE_FLAGS) -input $(GENESIS_INPUTS) -debug $(GENESIS_DBG_LEVEL) -parameter $(VERIF_PARAM_STRING)

genesis_clean:
	@echo ""
	@echo Cleanning previous runs of Genesis
	@echo ===================================
	if test -f "genesis_clean.cmd"; then 	\
		tcsh genesis_clean.cmd;	\
	fi
	\rm -rf $(GENESIS_VLOG_LIST)

gen_syn: genesis_clean  
	@echo ""
	@echo Elaborting for Synthesis Run
	@echo ====================================================
	rm *.v
	Genesis2.pl $(GENESIS_GEN_FLAGS) $(GEN) $(GENESIS_PARSE_FLAGS) -input $(GENESIS_INPUTS) -debug $(GENESIS_DBG_LEVEL) -parameter $(SYNTH_PARAM_STRING)
	locDesignMap.pl TCL=gen_params.tcl INPUT_XML=small_$(GENESIS_HIERARCHY) DESIGN_FILE=BB_$(MOD_NAME).design LOC_DESIGN_MAP_FILE=/dev/null PARAM_LIST_FILE=/dev/null PARAM_ATTRIBUTE_FILE=/dev/null


# VCS rules:
#####################
# compile rules:
# use "make COMP=+define+<compile_time_flag[=value]>" to add compile time flags
.PHONY: comp
comp: $(EXECUTABLE)

$(EXECUTABLE):	$(VERILOG_FILES) $(GENESIS_VLOG_LIST) 
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	@(if [ "$(SIM_ENGINE)" = "mentor" ]; then 	\
	    vlib work;					\
	  fi )
	$(COMPILER)  $(VERILOG_COMPILE_FLAGS) $(COMP) 2>&1 | tee comp_bb.log 

# IBM's fpgen rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: fpgen

fpgen: testVectors/$(FPRES_FILE)

testVectors/$(FPRES_FILE):$(FPDEF_FILE)
	@echo ""
	@echo Now Running IBM\'s fpgen tool, generating $(FPRES_FILE)
	@echo ==================================================
	if test ! -d "testVectors"; then 	\
		mkdir testVectors;	\
	fi
	fpgen $(FPDEF_FILE) $(FPGEN_FLAGS)


testVectors/$(TESTVEC_FILE): testVectors/$(FPRES_FILE)
	@echo ""
	@echo Now Converting testVectors/$(FPRES_FILE)
	@echo ==================================================
	$(DESIGN_HOME)/scripts/converter.pl testVectors/$(FPRES_FILE)



# Simulation rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: run run_wave run_ibm
run_wave: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE) with wave
	@echo ==================================================
	$(EXECUTABLE) +wave $(VERILOG_SIMULATION_FLAGS) $(RUN) 2>&1 | tee run_bb.log 

run: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE)
	@echo CLK $(SYN_CLK_PERIOD)
	@echo ==================================================
	$(EXECUTABLE) $(VERILOG_SIMULATION_FLAGS) $(RUN) 2>&1 | tee run_bb.log

run_ibm: $(EXECUTABLE) testVectors/$(TESTVEC_FILE)
	@echo ""
	@echo Now Running $(EXECUTABLE) using IBM\'s fpgen generated vectors
	@echo ==================================================
	$(EXECUTABLE)  $(VERILOG_SIMULATION_FLAGS) $(RUN) +File=testVectors/$(TESTVEC_FILE) 2>&1 | tee run_bb.log
 

########## For Design Compiler #############
############################################
RUN_NAME := synthesis/syn_$(VT)_$(Voltage)_$(target_delay)
io2core ?= 30	
COMMAND_STRING :=  "set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core);"
OPTIMIZED_COMMAND_STRING := "set ENABLE_MANUAL_PLACEMENT 1; set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core);"

# DC & ICC Run rules:
############################
.PHONY: run_synthesis run_dc
run_synthesis: synthesis/$(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log
run_dc: synthesis/$(RUN_NAME)/log/dc_$(RUN_NAME).log

target_delay ?= $(shell echo $(SYN_CLK_PERIOD)*1000 | bc )

VT ?= svt
Voltage ?= 1v0
io2core ?= 30
PIPE_CNT ?= xxx

RUN_SYNTHESIS_FLAGS:= \
                      VT=$(VT) \
                      Voltage=$(Voltage) \
                      target_delay=$(target_delay) \
                      io2core=$(io2core) \
                      MOD_NAME=$(MOD_NAME) 
                      PIPE_CNT=$(PIPE_CNT) 

#run_dc
synthesis/$(RUN_NAME)/log/dc_$(RUN_NAME).log: $(EXECUTABLE)
	mkdir -p log
	make -C synthesis -f Makefile clean dc $(RUN_SYNTHESIS_FLAGS)  2>&1 | tee syn_bb.log 

#run_synthesis
synthesis/$(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log: $(EXECUTABLE)
	mkdir -p log
	make -C synthesis -f Makefile clean all $(RUN_SYNTHESIS_FLAGS)  2>&1 | tee syn_bb.log

clean_synthesis:
	rm -rf synthesis/svt_*v*_*.*
	rm -rf synthesis/lvt_*v*_*.*
	rm -rf synthesis/hvt_*v*_*.*
	rm -f syn_bb.log
	make -C synthesis -f Makefile clean VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)

#Rollup Rules:
##############################

.PHONY: rollup1  rollup2 rollup3 report_results
rollup1: 
	perl scripts/BB_rollup.pl -d $(DESIGN_NAME) -t $(ROLLUP_TARGET) DESIGN_FILE=BB_$(MOD_NAME).design \
                                   VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)
rollup2: 
	perl scripts/BB_rollup.pl -d $(DESIGN_NAME) -t $(ROLLUP_TARGET) DESIGN_FILE=BB_$(MOD_NAME).design \
                                   VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)
rollup3: 
	perl scripts/BB_rollup.pl -d $(DESIGN_NAME) -t $(ROLLUP_TARGET) DESIGN_FILE=BB_$(MOD_NAME).design \
                                   VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)
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
clean: genesis_clean
	@echo ""
	@echo Cleanning old files, objects, logs and garbage
	@echo ==================================================
	\rm -rf $(EXECUTABLE) 
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
	\rm -rf top_FMA.v
	\rm -f graph_*.m
	cd testVectors;rm -f *.fplog *.fpres *.fpvec *.log
ifdef SIM_ENGINE
	\rm -rf $(EXECUTABLE).*
endif
ifeq ($(SIM_ENGINE), mentor) 
	\rm -rf work
	\rm -rf transcript
endif

cleanall: clean clean_synthesis
	\rm -rf DVE*
	\rm -rf vcdplus.vpd
	\rm -f *.v
	\rm -f *.pm
	\rm -f $(GENESIS_VLOG_LIST)
	\rm -fr verif_work/
