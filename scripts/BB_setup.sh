

#source synthesis/synSetup/synopsys_startup/setup.sh 
#source synthesis/synSetup/synopsys_startup/library_TSMC_45.sh

source /hd/cad/modules/tcl/init/bash

module load base
module load genesis2
module load vcs-mx
module load dc_shell
module load synopsys_edk
module load icc
module load pts
module load starrc
module load numbers 

export SNPSLMD_QUEUE=true
export SNPS_MAX_WAITTIME=7200
export SNPS_MAX_QUEUETIME=7200


#export SNPSLMD_LICENSE_FILE=26585\@vlsi.stanford.edu,26585\@omni.stanford.edu,27000\@cadlic0.stanford.edu   



export my_fpgen=/cad/IBM/FPGen
export FPGEN_PATH=/cad/IBM/FPGen/bin
export FPGEN_FILES_DIR=/cad/IBM/FPGen/tools/files
export FPGEN_LICENSE_FILE=27002@cadlic0.stanford.edu
PATH=:${my_fpgen}/bin:$PATH

