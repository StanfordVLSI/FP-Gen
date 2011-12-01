set MACHINE=`uname -n`


if (! $?MANPATH) then
    setenv MANPATH /usr/share/man
endif

####### SYNOPSYS DC, PT, ASTRO, APOLLO
 
if ( $?SNPSLMD_LICENSE_FILE == 0 ) then
    setenv SNPSLMD_LICENSE_FILE 27000@cadlic0.stanford.edu
endif
     
set unamer = `uname -r`
set unamem = `uname -m`
      
if ( $unamer == "5.5.1" || $?USE32BIT ) then
   setenv ARCH sparcOS5
else if ( $unamer == "5.7" || $unamer == "5.8" ) then
   setenv ARCH sparc64
else if ( $unamem == "i686" ) then
   setenv ARCH linux
   setenv ARCH2 IA.32
else if ( $unamem == "x86_64" ) then
   setenv ARCH amd64
   setenv ARCH2 AMD.64
endif

#SOLD
                               

# Synthesis
# SYNOPSYS is a standard variable that Synopsys tools use
# to point to DC root area. So, don't change that
setenv SYNOPSYS /cad/synopsys/dc_shell/latest/
set path = ( $path $SYNOPSYS/bin )

#IC Compiler
setenv ICC_ROOT /cad/synopsys/icc/2011.09-SP1/
set path = ( $path $ICC_ROOT/bin )



#PANDR TOOLS
if (! $?ARCH2) then
  # Error/die without this clause, if no ARCH2.
  echo "[setup.cshrc] No P&R tools available for this architecture."
else

  setenv SYNOPSYSPANDR /cad/synopsys/Z-2007.03-SP4
  #/cad/synopsys/Z-2007.03/jxt/bin/AMD.64/
  #jxt
  set path = ( $path /cad/synopsys/jxt/2007.03-SP9/bin)
  #astro
  set path = ( $path /cad/synopsys/astro/2007.03-SP9/bin/$ARCH2 )
  #astroiu
  set path = ( $path $SYNOPSYSPANDR/astroiu/bin/$ARCH2 )
  #astrorail
  set path = ( $path $SYNOPSYSPANDR/astrorail/bin/$ARCH2 )
  #mw
  set path = ( $path $SYNOPSYSPANDR/mw/bin/$ARCH2 )

  #path for hdl2A
  set path = ($path /cad/synopsys/Y-2006.06-SP2/astro/bin/$ARCH2)

endif

# Primetime

setenv SYNOPSYS_PT_BIN /cad/synopsys/pts/2009.12-SP2/bin
set path = ( $path $SYNOPSYS_PT_BIN )

#primerail 
setenv SYNOPSYS_PR /cad/synopsys/Z-2007.03-SP2/primerail
set path = ( $path $SYNOPSYS_PR/$ARCH/syn/bin )
set path = ( $path $SYNOPSYS_PR/$ARCH/bin )

#star-rcxt
setenv SYNOPSYS_RCXT /cad/synopsys/star-rcxt/2008.12
setenv SYNOPSYS_RCXT_BIN $SYNOPSYS_RCXT/${ARCH}_star-rcxt/bin
set path = ( $path $SYNOPSYS_RCXT_BIN )

#formality setup 
setenv SYNOPSYS_FM /cad/synopsys/Z-2007.06-SP2/fm
set path = ($path $SYNOPSYS_FM/$ARCH/fm/bin)
set path = ($path $SYNOPSYS_FM/$ARCH/bin)


# Novas/Debussy/Verdi
if ( $?LM_LICENSE_FILE ) then
  setenv LM_LICENSE_FILE "5219@vlsi:${LM_LICENSE_FILE}"
else
  setenv LM_LICENSE_FILE "5219@vlsi"
endif

setenv VERDI_HOME /cad/novas/verdi/200604v1
set path = ($path $VERDI_HOME/bin)
# The NOVAS_LIBS and NOVAS_LIBPATHS are setup in library.csh

# Leda
setenv LEDA_PATH /cad/synopsys/Y-2006.06/leda/leda_$ARCH
setenv LM_LICENSE_FILE "${LM_LICENSE_FILE}:26585@vlsi:26585@shimbala:26585@omni"
setenv PATH "${PATH}:$LEDA_PATH/bin"

###### VERA

set arch = `arch`

# Old version of Vera
#
#if ( $arch == "sun4" ) then
#   setenv VERA_HOME /cad/synopsys/Vera/vera-6.1.3/vera-6.1.3-solaris7
#else if ( $arch == "i686" ) then
#   setenv VERA_HOME /cad/synopsys/Vera/vera-6.1.3/vera-6.1.3-linux2.2.14
#endif

# new version
setenv VERA_HOME /cad/synopsys/Vera/vera-6.3.10-linux2.4.7


# Vera overwrite flag is used for checkpoints recovery
setenv VERA_OVERWRITE 1

if ( $?LD_LIBRARY_PATH == 0 ) then
   setenv LD_LIBRARY_PATH "${VERA_HOME}/lib"
else
   setenv LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:${VERA_HOME}/lib"
endif

setenv PATH "${PATH}:${VERA_HOME}/bin"

####### VCS
setenv VCS_HOME /cad/synopsys/vcs-mx/2008.12-3
setenv PATH "${PATH}:${VCS_HOME}/bin"
# VCS related variable - If not set vcs gives some warning message.
# It works fine inspite of the warning, but it's annoying.
setenv VCS_LIC_EXPIRE_WARNING 5
setenv VCS_CC gcc

#VIRSIM
setenv VIRSIMHOME ${VCS_HOME}/gui/virsim
setenv PATH "${PATH}:${VIRSIMHOME}/bin"


###### TENSILICA - LINUX ONLY!
setenv XTENSA_SYSTEM /sm/design/registry8
if ( $?LM_LICENSE_FILE ) then
  setenv LM_LICENSE_FILE "7183@vlsi:${LM_LICENSE_FILE}"
else
  setenv LM_LICENSE_FILE "7183@vlsi"
endif

if ( $?MANPATH ) then
  setenv MANPATH "${MANPATH}:/cad/tensilica/T2010.10-linux/XtTools/man/:"
else
  setenv MANPATH "/cad/tensilica/T2010.10-linux/XtTools/man/:"
endif

# /cad/tensilica/T2010.7-linux/XtTools/lib/iss
set path = ( $path /cad/tensilica/T2010.10-linux/XtTools/bin )


###### SM specific
setenv TENSILICA_TOOLS_HOME /cad/tensilica/T2010.10-linux/XtTools
setenv PROCESSOR_HOME /sm/design/config8/SIM4_vliw1_df
setenv XTENSA_CORE SIM4_vliw1_df

alias xdis    'xt-objdump --xtensa-core=SIM4_vliw1_df -D -S --demangle '



### Environment Definitions and Alias for RuleBase and FoCs ###
###############################################################
# Lisences:
setenv LM_LICENSE_FILE "7184@vlsi:$LM_LICENSE_FILE"

# FoCs:
setenv FOCS_DIR /cad/IBM/FoCs/FoCs_Feb2006
alias focs ${FOCS_DIR}/focs

#RuleBase
setenv RULEBASE_DIR /cad/IBM/RuleBase/RB_v1_30
alias rulebase ${RULEBASE_DIR}/rbpe
###############################################################

### Environment Definitions for License Queuing             ###
###############################################################
#
#The SNPSLMD_QUEUE environment variable allows dc_shell to wait for licenses that are temporarily unavailable.
setenv SNPSLMD_QUEUE true

#The SNPS_MAX_WAITTIME environment variable controls the maximum wait time for the initial license that is required to bring up the tool
setenv SNPS_MAX_WAITTIME 1000000

#The SNPS_MAX_QUEUETIME environment variable controls the wait time for any subsequent feature license(such as Power Compiler or  HDL Compiler), after the tool has started.
setenv SNPS_MAX_QUEUETIME  1000000

