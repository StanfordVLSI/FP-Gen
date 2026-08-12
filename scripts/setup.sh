# First you'll need Genesis2 in your path
# If we can't find one, we'll build it in /tmp

if [ `command -v Genesis2.pl` ]; then
    echo "Found existing Genesis2 command in your path:"
    echo "  `command -v Genesis2.pl`"
else
    scriptname="${BASH_SOURCE[0]}"
    echo "${scriptname}: Oops cannot find Genesis2.pl; I will try to fix this for you"

    if [ -d /tmp/Genesis2 ]; then
        echo "Found existing /tmp/Genesis2, let's try and use that"
    else
        echo "Genesis2 not found in /tmp/Genesis2, I will git-clone a new one for you"
        git clone https://github.com/StanfordVLSI/Genesis2.git /tmp/Genesis2
    fi
    echo ""
    
    export GENESIS_HOME=/tmp/Genesis2
    export PATH="$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin":"$PATH"
    export PERL5LIB=$GENESIS_HOME/PerlLibs:/$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions:$PERL5LIB

    command -v Genesis2.pl > /dev/null || echo "ERROR Genesis2.pl not installed"
    command -v Genesis2.pl > /dev/null || return
    echo 'Genesis2.pl ready and installed in /tmp'
fi

# Early out
[ "$1" == "--genesis-only" ] && return
  
function NEED_VCS { true; }
echo ""
echo "Need vcs and dc_shell to run simulations"
if [ `command -v vcs` ]; then
    echo "Found vcs: $(command -v vcs)"
    function NEED_VCS { false; }
fi
if [ `command -v dc_shell` ]; then
    echo "Found dc_shell: $(command -v dc_shell)"
    function NEED_VCS { false; }
fi
if test -z "$SYNOPSYS"; then 
    echo "Cannot find SYNOPSYS env var; that usually means dc_shell was not installed correctly"
    function NEED_VCS { true; }
fi
if NEED_VCS; then
    echo "WARNING vcs and/or dc_shell not found in your path."
    echo "You can generate an FPU but you cannot simulate or test using the default make cmd"
    # At Stanford we do this to load vcs and/or dc_shell:
    #   . /cad/modules/tcl/init/bash
    #   module load base
    #   module load vcs
    #   module load dc_shell
fi

# See if comparison/designware libraries exist
if [ "$SYNOPSYS" ]; then
echo ""
# export SYNOPSYS=/cad/synopsys/dc_shell/J-2014.09-SP3
# export SYNOPSYS=/hd/cad/synopsys/dc_shell/G-2012.06-SP5-1
for libdir in dw/sim_ver packages/gtech/src_ver; do
if ! test -e $SYNOPSYS/$libdir; then cat <<EOF
-----------------------------------------------------------------------------
WARNING Cannot find dc libraries '$SYNOPSYS/$libdir/'

    Recommend you find '$libdir' and set the SYNOPSYS var accordingly,
    either by installing dc_shell correctly
    and/or editing Makefile and/or simply using 'make SYNOPSYS=<correct-dir>' e.g.

        make clean run \\
            GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg \\
            SYNOPSYS=/cad/synopsys/dc_shell/J-2014.09-SP3

    such that '/cad/synopsys/dc_shell/J-2014.09-SP3/$libdir' exists

EOF
fi
done
