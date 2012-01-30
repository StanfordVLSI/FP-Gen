#!/usr/bin/perl
        
use strict;
use Getopt::Long;
                
my $home_dir = $ENV{'PWD'};
my $xml_dir = $home_dir . "/SysCfgs";
my $synth_dir = $home_dir . "/synthesis";
my $work_dir = $home_dir . "/work";
my $result_dir = $home_dir . "/results";
my $matlab_dir = $home_dir . "/matlab_plot_script";
        
my @csvs = ();
my @designwares = ();
my $nodisplay = ();
my $Vdd = 1.0;
my $Vth = "lvt";
        
GetOptions(
        'nodisplay!'	=>      \$nodisplay,
	'Vdd=f'		=>	\$Vdd,
	'Vth=s'		=>	\$Vth,
        'csv=s'         =>      \@csvs,
	'designwares=s'	=>	\@designwares,
); 

my $tag = sprintf( "%03x" , int( rand( 4095 ) ) ) ;
my $scriptName = "graph_" . $tag ;

my $flow = "";

$flow .= "function $scriptName()\n";
$flow .= "addpath('$result_dir','$matlab_dir');\n";

my $filename;
foreach $filename(@designwares){
        $flow .= "[ mapped_delay_$filename, routed_delay_$filename, optimized_delay_$filename,...\n";
        $flow .= "  mapped_power_$filename, routed_power_$filename, optimized_power_$filename]...\n";
        $flow .= "    = readcsv('$filename', '$Vth', $Vdd);\n";
}
foreach $filename(@csvs){
	$flow .= "[ mapped_delay_$filename, routed_delay_$filename, optimized_delay_$filename,...\n";
	$flow .= "  mapped_power_$filename, routed_power_$filename, optimized_power_$filename]...\n";
	$flow .= "    = readcsv('$filename', '$Vth', $Vdd);\n";
}

$flow .="figure(1);\n";
$flow .="set (gcf,'Position',[232,246,560,420]);\n";

my @plotColor = ('b','g','r','c','m','y','k');
my @plotMarker = ('o','x','^','s','d','+','o','*');
$flow .="plot(...\n";
my $i=0;
foreach $filename(@csvs){
	my $plotShape = $plotColor[$i % scalar(@plotColor)] . $plotMarker[$i % scalar(@plotMarker)];
	$i++;
        $flow .= "mapped_delay_$filename, mapped_power_$filename, '-.$plotShape',...\n";
	$flow .= "routed_delay_$filename, routed_power_$filename, '--$plotShape',...\n";
        $flow .= "optimized_delay_$filename, optimized_power_$filename, '-$plotShape',...\n";
}
foreach $filename(@designwares){
	my $plotShape = $plotColor[$i % scalar(@plotColor)] . $plotMarker[$i % scalar(@plotMarker)];
	$i++;
	$flow .= "mapped_delay_$filename, mapped_power_$filename, '-.$plotShape',...\n";
	$flow .= "routed_delay_$filename, routed_power_$filename, '-$plotShape',...\n";
}
$flow .= "'LineWidth',1.5,'MarkerSize',6);\n";

$flow .= "set(gca,'fontsize',8);\n";
$flow .= "title(['Floating Point Multiplier'],'fontsize',12);\n";

$flow .= "xlabel('Delay (ns)','fontsize',12),grid\n";
$flow .= "ylabel('Dynamic Energy (pJ)','fontsize',12)\n";
$flow .= "legend(...\n";
foreach $filename(@csvs){
        $flow .= "\t'$filename - synthesized (no wires)',...\n";
        $flow .= "\t'$filename - uninformed P&R',...\n";
        $flow .= "\t'$filename - layout informed P&R',...\n";
}
foreach $filename(@designwares){
        $flow .= "\t'$filename - synthesized (no wires)',...\n";
        $flow .= "\t'$filename - uninformed P&R',...\n";
}
$flow .= "\t'fontsize',10);\n";
$flow .= "options.Format = 'pdf'; hgexport(gcf, '$result_dir/$scriptName.pdf', options);\n";
$flow .= "end\n";

open( MATLABSCRIPT , ">$scriptName.m") ;
printf MATLABSCRIPT $flow ;
close( MATLABSCRIPT ) ;
print "Matlab script for plotting graph is saved to $scriptName.m\n";

if($nodisplay){
print "Running the matlab script...";
`matlab -nodisplay -r "$scriptName;exit"`;
print "done\n";
print "The graph is saved to $result_dir/$scriptName.pdf\n";
}else{
print "Starting matlab...\n";
`matlab -r "$scriptName"`;
}
