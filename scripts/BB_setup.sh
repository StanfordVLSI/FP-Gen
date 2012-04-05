

source synthesis/synSetup/synopsys_startup/setup.sh 
source synthesis/synSetup/synopsys_startup/library_TSMC_45.sh

export VCS_ARCH_OVERRIDE=linux
export VCS_HOME=/hd/cad/synopsys/vcs-mx/2010.06   
export PATH=${VCS_HOME}/bin:${PATH}   
export VIRSIM_HOME=${VCS_HOME}/gui/virsim   
export DVE=${VCS_HOME}/gui/dve/bin/   
export VCS_LIC_EXPIRE_WARNING=5   

PATH=/hd/cad/synopsys/dc_shell/latest/bin/:$PATH   
export SYNOPSYS=/hd/cad/synopsys/dc_shell/latest/

export SNPSLMD_QUEUE=true
export SNPS_MAX_WAITTIME=7200
export SNPS_MAX_QUEUETIME=7200


export SNPSLMD_LICENSE_FILE=26585\@vlsi,26585\@omni,26585\@shimbala:27000\@cadlic0   

PATH=:/hd/cad/synopsys/icc/2011.09-SP1/bin/:$PATH   
PATH=:/hd/cad/synopsys/pts/2009.12-SP2/bin/:$PATH   
PATH=:/hd/cad/synopsys/star-rcxt/2008.12/amd64_star-rcxt/bin:$PATH   

export GENESIS_LIBS="/hd/cad/genesis2/latest/PerlLibs"
PATH=$GENESIS_LIBS/Genesis2:$PATH         


if [ -f /usr/bin/gcc-4.4 ]; then
export J_CC=gcc-4.4
else
export J_CC=gcc
fi
