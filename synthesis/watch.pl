#!/usr/bin/perl

while(1){

    print `qstat | grep jbrunhav` ;
    $countR = `qstat | grep jbrunhav | grep -c R` ;
    $countQ = `qstat | grep jbrunhav | grep -c Q` ;
    $total = $countR + $countQ ;
    print "\n\n R:$countR Q:$countQ T:$total\n\n"; 
    sleep( 30 ) ;

}
