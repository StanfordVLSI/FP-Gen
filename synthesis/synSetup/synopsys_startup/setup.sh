export SNPSLMD_LICENSE_FILE=27000@cadlic0.stanford.edu
     
# Synthesis
# SYNOPSYS is a standard variable that Synopsys tools use
export SYNOPSYS=/cad/synopsys/dc_shell/latest/
PATH=$PATH:$SYNOPSYS/bin

#IC Compiler
export ICC_ROOT=/cad/synopsys/icc/2011.09-SP1/
PATH=$PATH:$ICC_ROOT/bin


# Primetime

export SYNOPSYS_PT_BIN=/cad/synopsys/pts/2009.12-SP2/bin
PATH=$PATH:$SYNOPSYS_PT_BIN


export SYNOPSYS_RCXT_BIN=/cad/synopsys/starrc/2009.06-SP2/amd64_starrc/bin

###############################################################

### Environment Definitions for License Queuing             ###
###############################################################
#
#The SNPSLMD_QUEUE environment variable allows dc_shell to wait for licenses that are temporarily unavailable.
export SNPSLMD_QUEUE=true

#The SNPS_MAX_WAITTIME environment variable controls the maximum wait time for the initial license that is required to bring up the tool
export SNPS_MAX_WAITTIME=1000000

#The SNPS_MAX_QUEUETIME environment variable controls the wait time for any subsequent feature license(such as Power Compiler or  HDL Compiler), after the tool has started.
export SNPS_MAX_QUEUETIME=1000000



