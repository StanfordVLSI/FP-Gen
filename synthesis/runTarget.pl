#!/usr/bin/perl

$id = 0 ;
$tag = sprintf( "%03x" , int( rand( 4095 ) ) ) ;
while( $#ARGV > 0 ){
    $id++ ;
    $batchName = "batch_" . $tag . "_n" . $id . ".sh" ;
    $s1 = shift @ARGV ;
    $s2 = shift @ARGV ;
    $s3 = shift @ARGV ;
    $s4 = shift @ARGV ;

    print "Running $id --> " . $s1 ."_". $s2 . "_" . $s3 . "\n" ;

    my $flow = "" ;

    $flow .= "#!/bin/bash  \n";
    $flow .= "   \n";
    $flow .= "date\n";
    $flow .= "   \n";
    $flow .= " echo \"$id $tag\" \n";
    $flow .= "   \n";
    $flow .= "source ./synSetup/synopsys_startup/setup.sh \n";
    $flow .= "echo $SYNOPSYS_RCXT_BIN \n";
    $flow .= "source ./synSetup/synopsys_startup/library_TSMC_45.sh\n";
    $flow .= "export VCS_ARCH_OVERRIDE=linux   \n";
    $flow .= "export VCS_HOME=/hd/cad/synopsys/vcs-mx/2010.06   \n";
    $flow .= "export PATH=\${VCS_HOME}/bin:\${PATH}   \n";
    $flow .= "export VIRSIM_HOME=\${VCS_HOME}/gui/virsim   \n";
    $flow .= "export DVE=\${VCS_HOME}/gui/dve/bin/   \n";
    $flow .= "export VCS_LIC_EXPIRE_WARNING=5   \n";
    $flow .= "PATH=/hd/cad/synopsys/dc_shell/F-2011.09/bin/:\$PATH   \n";
    $flow .= "export SNPSLMD_LICENSE_FILE=26585\@vlsi,26585\@omni,26585\@shimbala:27000\@cadlic0   \n";
    $flow .= "PATH=:/hd/cad/synopsys/icc/2011.09-SP1/bin/:\$PATH   \n";
    $flow .= "PATH=:/hd/cad/synopsys/pts/2009.12-SP2/bin/:\$PATH   \n";
    $flow .= "PATH=:/hd/cad/synopsys/star-rcxt/2008.12/amd64_star-rcxt/bin:\$PATH   \n";
    $flow .= "export GENESIS_LIBS=\"/hd/cad/genesis2/r9648/PerlLibs\"   \n";
    $flow .= "PATH=\$GENESIS_LIBS/Genesis2:\$PATH   \n";
    $flow .= "cd \$PBS_O_WORKDIR; pwd; make all VT=$s1 Voltage=$s2 target_delay=$s3 io2core=$s4";
    open( BATCHFILE , ">$batchName") ;
    printf BATCHFILE $flow ;
    close( BATCHFILE ) ;
    `chmod 777 $batchName`;
    `jsub -q horowitz -- ./$batchName`;

}


#while [ "$#" -gt "0" ]
#do
#  echo "Running $1_$2_$3"
#
#  echo "cd \$PBS_O_WORKDIR; pwd; make all VT=$1 Voltage=$2 target_delay=$3 io2core=$4" | qsub -q horowitz -p -1
#  shift
#  shift
#  shift
#  shift
#done
