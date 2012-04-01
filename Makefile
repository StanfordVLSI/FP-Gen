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

#DESIGN_NAME ?= FPMult
#INST_NAME ?= FPMult
#MOD_NAME ?= FPMult
#TOP_NAME ?= top_FPMult
#TOP_MODULE ?= $(TOP_NAME)

#DESIGN_NAME ?= MultiplierP
#INST_NAME ?= MultiplierP
#MOD_NAME ?= MultiplierP
#TOP_NAME ?= top_MultiplierP
#TOP_MODULE ?= $(TOP_NAME)

#DESIGN_NAME ?= FMA
#INST_NAME ?= FMA
#MOD_NAME ?= FMA
#TOP_NAME ?= top_FMA
#TOP_MODULE ?= $(TOP_NAME)

#DESIGN_NAME ?= Multiplier
#INST_NAME ?= Multiplier
#MOD_NAME ?= Multiplier
#TOP_NAME ?= top_Multiplier
#TOP_MODULE ?= $(TOP_NAME)

#DESIGN_NAME ?= FPMult
#INST_NAME ?= FPMult
#MOD_NAME ?= FPMult
#TOP_NAME ?= top_FPMult
#TOP_MODULE ?= $(TOP_NAME)

#DESIGN_NAME ?= adder
#INST_NAME ?= adder
#MOD_NAME ?= adder
#TOP_NAME ?= top_adder
#TOP_MODULE ?= $(TOP_NAME)

DESIGN_NAME ?= MultiplierP
INST_NAME ?= MultiplierP
MOD_NAME ?= MultiplierP
TOP_NAME ?= top
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

GENESIS_INTERMIDS := $(GENESIS_INPUTS)
GENESIS_INTERMIDS := $(GENESIS_INTERMIDS:.vp=.pm)
GENESIS_INTERMIDS := $(GENESIS_INTERMIDS:.svp=.pm)


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

# For more Genesis parsing options, type 'Genesis2.pl -help'
#        [-parse]                    ---   should we parse input file to generate perl modules?
#        [-sources|srcpath dir]      ---   Where to find source files
#        [-includes|incpath dir]     ---   Where to find included files
#        [-input file1 .. filen]     ---   List of top level files
#                                    ---   The default is STDIN, but some functions
#                                    ---   (such as "for" or "while")
#                                    ---   may not work properly.
#        [-perl_modules modulename]  ---   Additional perl modules to load
GENESIS_PARSE_FLAGS := 	-parse $(GENESIS_SRC) $(GENESIS_INC)			\
			-debug $(GENESIS_DBG_LEVEL)

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
			-debug $(GENESIS_DBG_LEVEL)				\
			-xml $(GENESIS_CFG_XML)




############### For Verilog ################
############################################

##### FLAGS FOR SYNOPSYS COMPILATION ####
ifeq ($(SIM_ENGINE), synopsys) 
COMPILER := vcs

EXECUTABLE := ./simv

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=  	$(VERILOG_ENV)	$(VERILOG_DESIGN)					

SYNOPSYS := /hd/cad/synopsys/dc_shell/F-2011.09

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

J_CC ?= gcc 

VERILOG_COMPILE_FLAGS := 	-sverilog 					\
				+cli 						\
				+lint=PCWM					\
				+libext+.v					\
				-notice						\
				-full64						\
				+v2k						\
				-debug_pp					\
				-timescale=1ns/1ns				\
				+noportcoerce         				\
				-ld $(J_CC) -debug_pp				\
				-top $(TOP_MODULE)				\
				-f $(GENESIS_VLOG_LIST) 			\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "+vpdbufsize+100" limit the internal buffer to 100MB (forces flushing to disk)
# "+vpdports" Record information about ports (signal/in/out)
# "+vpdfileswitchsize+1000" limits the wave file to 1G (then switch to next file)
VERILOG_SIMULATION_FLAGS := 	$(VERILOG_SIMULATION_FLAGS) 			\
				-l $(EXECUTABLE).log					\
				+vpdbufsize+100					\
				+vpdfileswitchsize+100
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

################################################################################
################ Makefile Rules
################################################################################
#default rule: 
all: $(EXECUTABLE)

# Genesis2 rules:
#####################
# Genesis2 Parse:
# This is the rule to activate Genesis2 parser to generate perl module (.pm)
# from the input verilog preprocessed (.vp) files.
# Use "make PARSE=<genesis2_parse_flags>" to add elaboration time flags
%.pm: %.vp
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_PARSE_FLAGS) -input $? $(PARSE)

%.pm: %.svp
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_PARSE_FLAGS) -input $? $(PARSE)

# Genesis2 Generate:
# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the perl (.pm) program.
# Use "make GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST): $(GENESIS_INTERMIDS) $(GENESIS_CFG_XML)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_GEN_FLAGS) $(GEN)


# phony rules for partial compilation process
.PHONY: parse gen

parse: $(GENESIS_INTERMIDS)

gen: $(GENESIS_VLOG_LIST)


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


# Simulation rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: run run_wave
run_wave: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE) with wave
	@echo ==================================================
	$(EXECUTABLE) +wave $(VERILOG_SIMULATION_FLAGS) $(RUN) 2>&1 | tee run_bb.log 

run: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE)
	@echo ==================================================
	$(EXECUTABLE) $(VERILOG_SIMULATION_FLAGS) $(RUN) 2>&1 | tee run_bb.log 

########## For Design Compiler #############
############################################
RUN_NAME := synthesis/syn_$(VT)_$(Voltage)_$(target_delay)
io2core ?= 30	
COMMAND_STRING :=  "set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core);"
OPTIMIZED_COMMAND_STRING := "set ENABLE_MANUAL_PLACEMENT 1; set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core);"

# DC Run rules:
######################
.PHONY: run_dc
run_dc: $(RUN_NAME)/log/dc_$(RUN_NAME).log

$(RUN_NAME)/log/dc_$(RUN_NAME).log: $(EXECUTABLE)
	mkdir -p $(RUN_NAME); cd $(RUN_NAME); mkdir -p log; \
	dc_shell-xg-t -64bit -f ../multiplier_dc.tcl -x $(COMMAND_STRING) | tee -i log/dc_$(RUN_NAME).log

# ICC Run rules:
############################
.PHONY: run_synthesis
run_synthesis: log/syn_$(RUN_NAME).log

SYN_CLK_PERIOD ?= 1.5
target_delay ?= $(shell echo $(SYN_CLK_PERIOD)*1000 | bc )

RETIME ?= 0 

RUN_SYNTHESIS_FLAGS:= \
                      VT=$(VT) \
                      Voltage=$(Voltage) \
                      target_delay=$(target_delay) \
                      io2core=$(io2core) \
                      MOD_NAME=$(MOD_NAME) \
                      RETIME=$(RETIME)

log/syn_$(RUN_NAME).log: $(EXECUTABLE)
	mkdir -p log
	make -C synthesis -f Makefile clean all $(RUN_SYNTHESIS_FLAGS)  2>&1 | tee  syn_bb.log

clean_synthesis:
	rm -rf synthesis/svt_*v*_*.*
	rm -rf synthesis/lvt_*v*_*.*
	rm -rf synthesis/hvt_*v*_*.*
	rm -f syn_bb.log
	make -C synthesis -f Makefile clean VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)

#Rollup Rules:
##############################

.PHONY: rollup1  rollup2 rollup3
rollup1: 
	perl scripts/BB_rollup.pl -d $(DESIGN_NAME) -t $(ROLLUP_TARGET) VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)
rollup2: 
	perl scripts/BB_rollup.pl -d $(DESIGN_NAME) -t $(ROLLUP_TARGET) VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)
rollup3: 
	perl scripts/BB_rollup.pl -d $(DESIGN_NAME) -t $(ROLLUP_TARGET) VT=$(VT) Voltage=$(Voltage) target_delay=$(target_delay) io2core=$(io2core)


#Eval Rules
##############################
.PHONY: eval 
eval: comp rollup1 run rollup2 run_synthesis rollup3


# Cleanup rules:
#####################
.PHONY: clean cleanall 
clean:
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
	\rm -rf $(GENESIS_INTERMIDS)
	\rm -rf $(GENESIS_INTERMIDS:.pm=_unq*.v)
	\rm -rf $(GENESIS_INTERMIDS:.pm=_tmp*.v)
	\rm -rf depend.list $(GENESIS_VLOG_LIST) $(GENESIS_HIERARCHY) small_$(GENESIS_HIERARCHY)
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