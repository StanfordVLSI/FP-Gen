#!/usr/bin/perl

use strict ;
use warnings ;
use Switch ;
use XML::Simple ;


sub walkDesignForParams{

    #Arg1 is a subinstance item
    my $g = shift ;
    my %d = %$g ;

    #Arg2 is a hierarchical name
    ## format is inst.inst.inst....
    my $hierName = shift ;

    #Get Module Name
    my $moduleName = $d{'BaseModuleName'} or die "Malformed Gen Config XML" ; 
    my $instName = $d{'InstanceName'} or die "Malformed Gen Config XML" ;
    
    #Make param prefix
    ## praram name is inst.inst.inst.inst.module.paramname
    my $paramPrefix = $hierName . "." . $instName . "." . $moduleName ; 

    #Make hier name
    ## inst.inst.inst
    $hierName = $hierName . "." . $instName ; 

    if( $d{'ImmutableParameters'} && $d{'ImmutableParameters'}->{'ParameterItem'} ){
	foreach my $params ( @{ $d{'ImmutableParameters'}->{'ParameterItem'} } ){
	    my $pName = $params->{'Name'} ;
	    my @tags = $params->{'Doc'} =~ m/(!\w+!)/g ;
	    push @tags , @_ ;
	    print $paramPrefix . "." . $pName ;
	    print " " . $pName ;
	    print " " . $params->{'Val'} . " " ;
	    print @tags  ;
	    print "!immutable! \n" ;
	}
    } else {
	print "$hierName => No Immutable Params\n" ;
    }

    if( $d{'Parameters'} && $d{'Parameters'}->{'ParameterItem'} ){
    	foreach my $params ( @{ $d{'Parameters'}->{'ParameterItem'} } ){
	    my $pName = $params->{'Name'} ;
	    my @tags = $params->{'Doc'} =~ m/(!\w+!)/g ;
	    print $paramPrefix . "." . $pName ;
	    print " " . $pName ;
	    print " " . $params->{'Val'}  . " ";
	    print @tags  ;
	    print "!mutable! \n" ;
	}    
    } else {
	print "$hierName => No Params\n" ;
    }


    #Recurse on child instances
    foreach my $subI ( @{ $d{'SubInstances'}->{'SubInstanceItem'} } ) {
	walkDesignForParams( $subI , $hierName  );
    }

}

#Test ARGS
if( $#ARGV  < 0 ){
    print "USAGE: ./list_gen_params.pl <infile>\n" ; 
    die ("\n\n");
}

#Get File Name from Arg
my $configFile = shift @ARGV ;

#Read In XML
print "Finding all parameters in $configFile \n" ;
my $document = XMLin( $configFile , 
                      ForceArray => ['SubInstanceItem', 'ParameterItem']   );

#Breadth First Walk of Design Parameters

$document->{'BaseModuleName'} or die "Malformed Gen Config XML" ;
walkDesignForParams( $document , "TOP" ) ;








