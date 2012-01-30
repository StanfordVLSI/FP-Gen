#######################################
#
# VCS
export VCS_ARCH_OVERRIDE=linux
export VCS_HOME=/hd/cad/synopsys/vcs-mx/2010.06
export PATH=${VCS_HOME}/bin:${PATH}
export VIRSIM_HOME=${VCS_HOME}/gui/virsim
export DVE=${VCS_HOME}/gui/dve/bin/
export VCS_LIC_EXPIRE_WARNING=5
# DC SHELL
PATH=/hd/cad/synopsys/dc_shell/F-2011.09/bin/:$PATH
#License Server
export SNPSLMD_LICENSE_FILE=26585@vlsi,26585@omni,26585@shimbala:27000@cadlic0
# ICC Shell
PATH=:/hd/cad/synopsys/icc/2011.09-SP1/bin/:$PATH
PATH=:/hd/cad/synopsys/pts/2009.12-SP2/bin/:$PATH
PATH=:/hd/cad/synopsys/star-rcxt/2008.12/amd64_star-rcxt/bin:$PATH
# Setup For Genesis
export GENESIS_LIBS="/hd/cad/genesis2/r9648/PerlLibs"
PATH=$GENESIS_LIBS/Genesis2:$PATH
# Setup for Matlab
PATH=/hd/cad/mathworks/matlab.r2009b/bin/:$PATH
