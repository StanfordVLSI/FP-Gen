#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use YAML::Any ;
use Data::Dumper ;
use File::Basename;
 
my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";
basename($file) =~ /([^\.]*)\..*/;
my $design_name = $1;

my @headers =();
my $configuration = 
{
          'makefile' => 'Makefile',
          'setupfile' => 'scripts/setup_kiwi.bash',
          'delay_make_variable' => 'SYN_CLK_PERIOD',
          'make_arguments' => 'USE_SAIF=1 USE_GATE_SAIF=1 USE_ICC_GATE_SAIF=1  VERILOG_SIMULATION_FLAGS="+IgnoreErrors"',
          'eval_rules' => 'comp run run_dc ',
          'cleanup' => 1,
          'design_title' => "FPGEN_${design_name}_",
          'param_make_variable' => 'GENESIS_PARAMS',
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'rollup_variable' => 'ROLLUP_TARGET',
	  'cubby_root' => '/tmp/jbrunhaver/runMake/'   
};
my $i = -1 ;

open(my $fh, '<', $file) or die "Can't read file '$file' [$!]\n";
if (my $line = <$fh>) {
    chomp $line;
    @headers = split(/\s*,\s*/, $line);
}


while (my $line = <$fh>) {
    $i += 1 ; 
    chomp $line;
    my @fields = split(/\s*,\s*/, $line);

    for (my $j = 0; $j <= $#fields; $j++) {
      if ($fields[$j] ne '') {
        if ( $headers[$j] =~ /top_FPGen.FPGen/ ) {
          $configuration->{'design'}[$i]{$headers[$j]}= $fields[$j] ;
        }elsif ( $headers[$j] =~ /TOP_(.*)/ ) {
          $configuration->{'design'}[$i]{$1}= $fields[$j] ;
        } elsif ( $headers[$j] =~ /target_delay/ ) {
          $configuration->{'target_delay'}[$i]= $fields[$j] ;
        }
        #HACK for missing target delay
        elsif ( $headers[$j] =~ /PERF_Mapped_Clk_Freq_Ghz/ ) {
          my $target_delay = 1  / $fields[$j];
          $configuration->{'target_delay'}[$i]= $target_delay ;
        }
      }
    }
}

$i += 1 ; 
$configuration->{'runs'} = $i ;

print Dump $configuration;
print "Design_name=$design_name\n";
