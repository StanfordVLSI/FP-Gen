#load some modules to get some work done, this is probably what you need 
source /cad/modules/tcl/init/csh
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
module load fm

### Queue If Licenses Are Unavailable
setenv SNPSLMD_QUEUE true
setenv SNPS_MAX_WAITTIME 7200
setenv SNPS_MAX_QUEUETIME 7200

### Prototype NUMBERS
setenv PATH /hd/cad/numbers/0030/src:$PATH
if ($?PYTHONPATH) then
    setenv PYTHONPATH /hd/cad/numbers/0030/src:${PYTHONPATH}
else 
    setenv PYTHONPATH /hd/cad/numbers/0030/src
endif

# For synthesis
source $FPGEN/synthesis/synSetup/synopsys_startup/library_TSMC_45.csh

# For jsub
alias $FPGEN/scripts/jsub jsub

# For Ofer's debug env
#setenv GENESIS_HOME "$CHIPGEN/bin/Genesis2Tools"
#set path=($GENESIS_HOME/bin $path)
#setenv PERL5LIB "$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
