#load some modules to get some work done, this is probably what you need 
. /cad/modules/tcl/init/bash
module load base
module load genesis2
module load dc_shell
module load matlab
module load ncx
module load vcs-mx
module load icc
module load ic 
module load pts
module load starrc
module load FPGen
module load numbers

### Queue If Licenses Are Unavailable
export SNPSLMD_QUEUE=true
export SNPS_MAX_WAITTIME=7200
export SNPS_MAX_QUEUETIME=7200

### Prototype NUMBERS
export PATH=/hd/cad/numbers/0020/src:$PATH
export PYTHONPATH=/hd/cad/numbers/0020/src:$PYTHONPATH


# For synthesis
. $FPGEN/synthesis/synSetup/synopsys_startup/library_TSMC_45.sh

# For Ofer's debug env
#setenv GENESIS_LIBS "$CHIPGEN/bin/PerlLibs"
#set path=($GENESIS_LIBS/Genesis2 $path)
