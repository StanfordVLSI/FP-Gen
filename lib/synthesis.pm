
#
# Synthesis library for FPGEN
# contains functions useful in generating the required tcl constraint files ... 
#
# Author-> John Brunhaver    Date-> Jun 27th 2013
#

package synthesis ;

# grown up perl is stricly fatal and verbosely diagnostic
use strict ;
use warnings FATAL=>qw(all) ;
use diagnostics -verbose ; 

# import all functions for genesis 2
use Genesis2::UniqueModule 1.00 ;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = qw(generateConstraints);
@EXPORT_OK = qw(generateConstraints);
$VERSION = '1.0';

# import function to check that self is blessed (usually a sign that the target is a legal genesis object)
use Scalar::Util qw(blessed) ; 

sub bfsHier{
# 

    # Count those periods
    my @countA =  $a =~ m/\./g ;
    my @countB =  $b =~ m/\./g ;
    my $cA = scalar( @countA );
    my $cB = scalar( @countB );

    # Numerically ascending sort ( foo.a before foo.a.bar before foo.a.bar.spam.alot )
    return $cA <=> $cB ;

}

sub correctSynthName{
# Remove the simulation top
# Switch the period hiearchy annotation with the slash hier annotation

    my $synthTopPath = shift ; # foo.bar
    my $synthTopName = shift ; # bar
    my $instPath     = shift ; # foo.bar.spam
    
    $instPath =~ s/^$synthTopPath/$synthTopName/;
    $instPath =~ s/\./\//g;

    return $instPath ; # bar/spam

}


sub generateConstraints{
    # Collect the retime, ungroup, flatten commands used in the design
    my $top = shift ; # Instance object to be evaluated 
    my $self = shift ; # Caller 

    # Check that top is blessed 
    blessed $self or print STDOUT "ERROR: generateConstraints requires a blessed object for self" ;
    blessed $self or $self->error( "ERROR: generateConstraints requires a blessed object for self" ) ;

    print STDOUT "INFO: Looking for genesis parameters: Retime, Ungroup, Flatten using BFS from " . $top->get_instance_path() ;
    print STDOUT "INFO: Synthesis top is considered to be "  . $top->get_instance_path() ; 

    # Init the tcl command string
    my $tclCommands = "" ;

    # Generate a list of all instances..
    my @children =  $self->search_subinst(From=>$top, SNameRegex=>'^.+$');

    foreach my $child ( sort bfsHier @children ){
	# Foreach instance (BFS)
	
	#my $iName = correctSynthName( $top->get_instance_path() , $top->iname() , $child->get_instance_path() );
	my $iName = $child->mname() ;

	#  If ungroup
	#   call ungroup
	if( $child->exists_param( "Ungroup" )){
	    my $ungroup = $child->get_param("Ungroup");
	    if( $ungroup eq "YES" ){
		print STDOUT "INFO: Explicit ungroup for " . $child->get_instance_path() ;
		$tclCommands .= "set_ungroup [get_designs -exact ".$iName."] true ;\n" ;
 	    } elsif( $ungroup eq "NO" ){
		print STDOUT "INFO: Explicit no-ungroup for " . $child->get_instance_path() ;
		$tclCommands .= "set_ungroup [get_designs -exact ".$iName."] false ;\n" ;
	    } else {
		print STDOUT "Error: expected ungroup to be YES or NO" ;
		$self->error( "Error: expected ungroup to be YES or NO" );
	    }
	}
	    
	#  If flatten
	#   call flatten
	if( $child->exists_param( "Flatten" )){
	    my $ungroup = $child->get_param("Flatten");
	    if( $ungroup eq "YES" ){
		print STDOUT "INFO: Explicit flatten for " . $child->get_instance_path() ;
		$tclCommands .= "set_flatten -effort high -phase true -design [get_designs -exact ".$iName."] true ;\n" ;
	    } elsif( $ungroup eq "NO" ){
		print STDOUT "INFO: Explicit no-flatten for " . $child->get_instance_path() ;
		$tclCommands .= "set_flatten -design [get_designs -exact ".$iName."] false ;\n" ;
	    } else {
		print STDOUT "Error: expected flatten to be YES or NO" ;
		$self->error( "Error: expected flatten to be YES or NO" );
	    }
	}
	
	#  If retime
	#   call retime ...
	if( $child->exists_param( "Retime" )){
	    my $ungroup = $child->get_param("Retime");
	    if( $ungroup eq "YES" ){
		print STDOUT "INFO: Explicit retime for " . $child->get_instance_path() ;
		$tclCommands .= "set_optimize_registers -design [get_designs -exact ".$iName."] true ;\n" ;
		$tclCommands .= 'set_dont_retime [get_designs -exact '.$iName.'] false ;'."\n" ;
	    } elsif( $ungroup eq "NO" ){
		print STDOUT "INFO: Explicit no-retime for " . $child->get_instance_path() ;
		$tclCommands .= "set_optimize_registers -design [get_designs -exact ".$iName."] false ;\n" ;
		$tclCommands .= 'set_dont_retime [get_designs -exact '.$iName.'] true ;'."\n" ;
	    } else {
		print STDOUT "Error: expected retime to be YES or NO" ;
		$self->error( "Error: expected retime to be YES or NO" );
	    }
	}
    }

    return $tclCommands ;
}




