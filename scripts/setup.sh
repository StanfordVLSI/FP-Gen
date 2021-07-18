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
    
    GENESIS_HOME=/tmp/Genesis2/Genesis2Tools
    export PATH="$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin":"$PATH"

    # Set vars based on what you found
    PATH=$GENESIS_HOME/bin:$GENESIS_HOME/gui/bin:$PATH
    # if [ -z ${var+x} ]; then echo "var is unset"; else echo "var is set to '$var'"; fi
    if [ -z ${PERL5LIB+x} ]; then
      PERL5LIB=$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions
    else
      PERL5LIB=$PERL5LIB:$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions
    fi
    export PERL5LIB

    echo 'Installed Genesis2.pl in /tmp'
    command -v Genesis2.pl
fi
  
echo ""
echo "Need vcs to run simulations"
if [ `command -v vcs` ]; then
    echo "Found it:"
    echo "  `command -v vcs`"
else
    echo "WARNING vcs not found in your path."
    echo "You can generate an FPU but you cannot simulate or test using the default make cmd"
    # At Stanford we do this to load vcs:
    #   . /cad/modules/tcl/init/bash
    #   module load base
    #   module load vcs
fi


# See if the comparison libraries exist
echo ""
FOUND=TRUE
SYNOPSYS=/cad/synopsys/dc_shell/J-2014.09-SP3
SYNOPSYS=/hd/cad/synopsys/dc_shell/G-2012.06-SP5-1
for libdir in dw/sim_ver packages/gtech/src_ver; do
if ! test -e $SYNOPSYS/$libdir; then cat <<EOF
-----------------------------------------------------------------------------
WARNING Cannot find dc libraries '$SYNOPSYS/$libdir/'
    Recommend you find '$libdir' and set the SYNOPSYS var accordingly,
    either by editing Makefile or simply using 'make SYNOPSYS=<correct-dir>' e.g.

        make clean run \\
            GENESIS_CFG_SCRIPT=SysCfgs/dp-fma.cfg \\
            SYNOPSYS=/cad/synopsys/dc_shell/J-2014.09-SP3

    such that '/cad/synopsys/dc_shell/J-2014.09-SP3/$libdir' exists

EOF
fi
done

# test -e $SYNOPSYS/packages/gtech/src_ver/)
