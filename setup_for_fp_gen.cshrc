set MACHINE=`uname -n`

######################################################
# strip off the stanford.edu suffix (which may have strange case)
######################################################
set NAME=`expr "$MACHINE" : '\(.*\)\..*\..*'`
if (! $?MANPATH) then
    setenv MANPATH /usr/share/man
endif
######################################################


######################################################
###### Control of all cad tools sourcing: ############
######################################################
####### SYNOPSYS DC, PT, ASTRO, APOLLO
 
if ( $?SNPSLMD_LICENSE_FILE == 0 ) then
    setenv SNPSLMD_LICENSE_FILE 27000@cadlic0
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

# SYNOPSYS is a standard variable that Synopsys tools use
# to point to DC root area. So, don't change that
if (! $?SYNOPSYS) then
   setenv SYNOPSYS /cad/synopsys/dc_shell/latest/
   set path = ( $path $SYNOPSYS/$ARCH/syn/bin )
   set path = ( $path $SYNOPSYS/$ARCH/bin )
endif

source /cad/modules/init_modules.csh
######################################################


######################################################
################## VCS and Virsim ####################
######################################################
module load vcs-mx
######################################################


######################################################
### Environment Definitions and Alias for Genesis2 ###
######################################################
# Add the path for the Genesis elaboration library
#setenv GENESIS_LIBS "/home/shacham/projects/smart_memories/design/ChipGen/bin/PerlLibs"
#set path=($GENESIS_LIBS/Genesis2 $path)
module load genesis2
######################################################

######################################################
# Env definition for synthesis and place and route
######################################################
source $HOME/synopsys_startup/library_TSMC_45.csh
module load dc_shell
module load icc
module load pts
