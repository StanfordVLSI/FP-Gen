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
#if ( $MACHINE == "neva-2" ) then
#   setenv LD_LIBRARY_PATH /nobackup/kkelley/cad/lib
#endif
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
	