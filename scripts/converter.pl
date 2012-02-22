#!/usr/bin/perl

use strict;
use Getopt::Long;

my @files = ();

my %RndEncoding = {
    'nearest' => 0,
    'zero'    => 1,
    'posinf'  => 2,
    'neginf'  => 3,
};

GetOptions(
    'file=s' => \@files,
    );

while($#files >= 0){
    my $filename = shift @files;
    if(!$filename =~ /.fpres$/){     # if it is not .fpres file
	print "Only .fpres file supported. $filename is ignored.\n";
	next;                   # ignore it
    }
    my $outfile = $filename;
    $outfile =~ s/.fpres$/.txt/;
    open(INPUT,"$filename")||die("Could not open file.\n");
    my $flow = ();                  # variable to save output lines
    my @lines = <INPUT>;
    while($#lines >=0){
	my $line = shift @lines;
#	print $line;
	if(!($line =~ /RoundingMode/)){  # find the fist line of a set of data	    
	    next;
	}
	# now $line is the first line of a set of data, beginning with "Environment data"
	my $roundMode = $line;
	$roundMode =~ s/RoundingMode = |\s+//g;
	my $rndCode = 0;  # calculate the rounding mode
	if($roundMode =~ /nearest/){
	    $rndCode = 0;
	}elsif($roundMode =~ /zero/){
	    $rndCode = 1;
	}elsif($roundMode =~ /posinf/){
	    $rndCode = 2;
	}else {
	    $rndCode = 3;
	}
	while($line = shift @lines ){
	    if($line =~ /Environment data:/){
		last;
	    }
#	    print $line;
	    if($line =~ /FMA/){
#		print $line;
		my $numbers;
		my $status;
		($numbers, $status) = split(/, Status bits set:/, $line); # first, break the line into two parts
		$numbers =~ s/\bFMA\w*\s+|\*  FRT:|\b0x//g;       # remove some strings
		my $a=0; my $b=0; my $c=0; my $result=0;              # get operands and result
		($a, $b, $c, $result) = split(/\s+/, $numbers);
		my $FX=0; my $FO=0; my $FU=0; my $FV=0; my $FZ=0;        # set flags
		$FX=1 if($status =~ /X/);
		$FO=1 if($status =~ /O/);
		$FU=1 if($status =~ /U/);
		$FV=1 if($status =~ /V/);
		$FZ=1 if($status =~ /Z/);
		$flow .= "$rndCode"."_"."$a"."_"."$b"."_"."$c"."_"."$result"."_"."$FX"."_"."$FO"."_"."$FU"."_"."$FV"."_"."$FZ\n";
	    }
	}
    }
    close(INPUT);
    open(OUTPUT, ">$outfile");
    printf OUTPUT $flow;
    close(OUTPUT);
    print "File $outfile has been written.\n";
}
