#! /usr/bin/perl
######################################################################################
# Usage: Regression.pl [-help] [-cluster] [-iterate] [-email] [-jobs=n] [-threads=n]
#                     [-transactions=n] [-start=n] [-stop=n] 
# Purpose: This script is used to run regression tests in parallel on a cluster.
#
# Main options
#     -help  : prints this help file 
#     -cluster  : submit jobs to cluster. otherwise, run jobs locally 
#     -iterate  : iterate all the valid configs. otherwise, randomly generate configs 
#     -email  : send the results to recipients in the email list 
#     -jobs  : the number of configs (testing jobs) randomly generated 
#     -threads  : the number of threads run jobs locally or the max jobs submited to queue 
#     -transactions  : the number of transactions each tests contains 
#     -start  : the start job number for iterating part of configs 
#     -stop  : the stop job number for iterating part of configs
# 
# Valid configurations
#     the four major bit widths of IEEE, i.e. half, single, double and quad
#     CMA/FMA
#     No-pipe/1-stage/.../8-stage
#     Multi-pumping / no multi-pumping
#     With/without forwarding
#     Four Tree types
#     No booth / booth-2 / booth-3 
###################################################################################

use strict;
use Getopt::Long;
use threads;
use Thread::Semaphore;

use vars qw( %opts
	     $nfail
	     $npass
             $total_trans
      	   );

# some running parameters
my $nThreads = 10;                
my $nJobs = 5;
my $start_id = 0;
my $stop_id = 2000;
my $transactions = 1000;
my $iterate = 0;
my $cluster = 0;
my $prefix = "FPGEN";
my $email_file = "email.txt";
my $results_file = "results";
#my @email_list = ('jimmypu07@gmail.com');
my @email_list = ('jimmypu07@gmail.com', 'shacham@alumni.stanford.edu');
my $send_email = 0;
my $clean = 0;
my $FMA = 0;
my $CMA = 0;
my $comment = 0;
$total_trans = 0;


### lists defining config Genesis parameter space
#my @archs = ('CMA');
my @archs = ('FMA', 'CMA');
my @precisions = ('half', 'single', 'double', 'quad');
my @trees = ('Wallace', 'ZM', 'OS1', 'Array');
my @booths = (1, 2, 3);
my @pipe_depths = (0, 1, 2, 3, 4, 5, 6, 7);
my @clock_gatings = ('YES', 'NO');
my @mult_pumpings = ('YES', 'NO');
my @forwardings = ('YES', 'NO');


# hash tables for translating precision to bitwidth according to IEEE standard
my %frac_widths = (
    'half' => 10,
    'single' => 23,
    'double' => 52,
    'quad' => 112,
    );

my %exp_widths = (
    'half' => 5,
    'single' => 8,
    'double' => 11,
    'quad' => 15,
    );

### global variables for storing the values of Genesis paramters
my $arch = $archs[0];
my $precision = $precisions[0];
my $tree = $trees[0];
my $booth = $booths[1];
my $pipe_depth = $pipe_depths[4];
# my $clock_gating = $clock_gatings[0]; RTL not implemented
my $mult_pumping = $mult_pumpings[1];
my $forwarding = $forwardings[0];
my $frac_width = $frac_widths{"$precision"};
my $exp_width = $exp_widths{"$precision"};

%opts = ();
GetOptions("cluster"                 => \$opts{cluster},
	   "iterate"                 => \$opts{iterate},
	   "email"                   => \$opts{email},
	   "jobs=i"                  => \$opts{jobs},
	   "threads=i"               => \$opts{threads},
	   "transactions=i"          => \$opts{transactions},
	   "start=i"                 => \$opts{start},
	   "stop=i"                  => \$opts{stop},
           "help"                    => \$opts{help},
	   "clean"                   => \$opts{clean},
	   "FMA"                     => \$opts{FMA},
	   "CMA"                     => \$opts{CMA},
	   "comment=s"                 => \$opts{comment}
    );

# Handling unknown options
if ($ARGV[0])
  {
    print "Unknown options: ";
    foreach my $unknown_arg (@ARGV) {
      print "$unknown_arg ";
    }
    print "\n";
    print "Will be passed along to other regression scripts...\n";
    sleep(1);
  }

# help menu
if (defined $opts{help})
  {
    print_help();
    exit 0;
  }

if (defined $opts{cluster}) { $cluster = 1;}

if (defined $opts{iterate}) { $iterate = 1;}

if (defined $opts{email}) { $send_email = 1;}

if (defined $opts{jobs}) { $nJobs = $opts{jobs}; }

if (defined $opts{threads}) { $nThreads = $opts{threads};}

if (defined $opts{transactions}) { $transactions = $opts{transactions};}

if (defined $opts{start}) { $start_id = $opts{start}; }

if (defined $opts{stop}) { $stop_id = $opts{stop}; }

if (defined $opts{clean}) { $clean = 1; }

if (defined $opts{FMA}) { $FMA = 1; }

if (defined $opts{CMA}) { $CMA = 1; }

if (defined $opts{comment}) { $comment = $opts{comment}; }

if ($FMA || $CMA) {
    pop(@archs); 
    pop(@archs); # empty array
    push(@archs, 'FMA') if ($FMA);
    push(@archs, 'CMA') if ($CMA);
}

my $semaphore = Thread::Semaphore->new($nThreads);
my $seed = 123;
my $genesis_par = generate_genesis_arg();
my $run_arg = "RUN=\"+Seed=$seed +NumTrans=$transactions +Silent\"";
my $cmd = "make -f \$FPGEN/Makefile clean run $genesis_par $run_arg";
my @jobs = ();
my @rundirs = ();

### time stamp ###
my $time_start = `date`;

### make the regression folder
(my $second, my $minute, my $hour, my $day, my $month, my $year) = localtime();
$year = $year + 1900;
$month = $month + 1;
$year = $year - 2000;
if ($year <= 9)  {$year = "0$year";}
if ($month <= 9) {$month = "0$month";}
if ($day <= 9)   {$day = "0$day";}
my $date =  "$month-$day-$year";
my $reg_rundir;

$reg_rundir = mkrundir( "$prefix-$date" );
print "REGDIR=$reg_rundir\n---\n";
chdir("$reg_rundir");

### prepare run cmd and dir
if (!$iterate){
    prepare_random_cfg(\@jobs, \@rundirs, $nJobs);
} else {
    iterate_all_cfg(\@jobs, \@rundirs, $start_id, $stop_id);
}

### run jobs
if ($cluster) {
    run_jobs_on_queue (\@jobs, $nThreads, $nThreads)
} else {
    run_jobs_locally(\@jobs);
}

### check results
run_test_checks($results_file, \@rundirs, $prefix);
open TESTRESULTS, "< $results_file" or die "Can't open $results_file";
my @test_results = <TESTRESULTS>;
close TESTRESULTS;



### time stamp ###
my $time_finish = `date`;

### make text file for email
open FILE, "> $email_file" or die "Can't open $email_file\n";
print FILE "Subject: Regression results $reg_rundir: $npass PASS, $nfail FAIL.\n";  
my $emails = join(", ",@email_list);
print FILE "To: $emails\n\n";

# print some regression info
my $curDir = `pwd`;
print FILE "Regression Folder Path: $curDir";
my $numberOfJobs = scalar(@jobs);
my $avg_trans = $total_trans / $numberOfJobs;
print FILE "Number of total jobs: $numberOfJobs\n";
print FILE "Number of total transactions: $total_trans($avg_trans per job)\n";
print FILE "Number of threads used: $nThreads\n";
print FILE "Start time: $time_start";
print FILE "Finish time: $time_finish";
print FILE "Comment: $comment";

print FILE "\n\n";

# print the results
foreach my $line (@test_results)
{
    print FILE "$line";
}
close FILE;

if ($send_email) {
    system("uuencode rerun_${prefix}.cmd rerun_${prefix}_cmd.txt >> $email_file"); # attachment
    system("sendmail -F \"$prefix-Regression\" -t < $email_file");
    print "Mail sent...\n\n\n";
}

exit(0);


sub prepare_random_cfg {
    my $jobs = @{shift(@_)};
    my $rundirs = @{shift(@_)};
    my $nJobs  = shift(@_);
    my $job_id = 0;
    my $trans = $transactions;
    my $quad_scale_factor = 1;
    while($job_id < $nJobs){
	# randomize parameters
	$arch = $archs[int(rand(scalar(@archs)))];
	my $token = int(rand(scalar(@precisions) + $quad_scale_factor - 1));
	if ($token < 3) {
	    $precision = $precisions[$token];
	    $trans = $transactions;
	} else {
	    $precision = $precisions[3];
	    $trans = $transactions / $quad_scale_factor;
	}
	$frac_width = $frac_widths{"$precision"};
	$exp_width = $exp_widths{"$precision"};
	$tree = $trees[int(rand(scalar(@trees)))];
	$booth = $booths[int(rand(scalar(@booths)))];
	$forwarding = $forwardings[int(rand(scalar(@forwardings)))];
	$pipe_depth = $pipe_depths[int(rand(scalar(@pipe_depths)))];
	$mult_pumping =$mult_pumpings[int(rand(scalar(@mult_pumpings)))];
	


	# check the pipeline depth if enabled forwarding
	if ($forwarding eq 'YES') {
	    if( $arch eq 'CMA' && $pipe_depth < 5) {
		next;
	    } elsif ( $arch eq 'FMA' && $pipe_depth < 3) {
		next;
	    }
	}
	# no mult pumping option when it is CMA
	next if ($mult_pumping eq 'YES' && $arch eq 'CMA');
	next if ($precision eq 'quad' && ($tree eq 'Array'));

	# run a job
	$job_id++;
	$total_trans += $trans;

	my $rundir = $job_id;
	mkdir($rundir);
	push(@rundirs, $rundir);
	$genesis_par = generate_genesis_arg();
	$seed = int(rand(10000000));
	$run_arg = "RUN=\"+Seed=$seed +NumTrans=$trans +Silent\"";
	$cmd = "make -C $rundir -f \$FPGEN/Makefile run $genesis_par $run_arg";
	if ($clean) { $cmd = $cmd . " clean"; }
	
	my $job_cfg = generate_cfg_name();
	open(JOBCFG, ">${rundir}/jobcfg.txt");
	print JOBCFG $job_cfg;
	close (JOBCFG);

	open(CMD, ">${rundir}/${prefix}.cmd");
	print CMD "#! /bin/sh\n";
	print CMD $cmd . ";";
	close (CMD);
	system("chmod u+x ${rundir}/${prefix}.cmd");
	if($cluster) {
	    $cmd = submit_cmd($rundir, "$prefix-regression")." ${rundir}/${prefix}.cmd";
	}
	push(@jobs, $cmd);
    }
}

sub iterate_all_cfg {
    my $jobs = @{shift(@_)};
    my $rundirs = @{shift(@_)};
    my $start_id = shift(@_);
    my $stop_id = shift(@_);
    my $job_id = 0;
    # iterate arch parameters
    foreach my $var_arch (@archs) {
	$arch = $var_arch;
	# iterate precisions
	foreach my $var_precision (@precisions) {
	    $precision = $var_precision;	    
	    $frac_width = $frac_widths{"$precision"};
	    $exp_width = $exp_widths{"$precision"};
	    # iterate tree types
	    foreach my $var_tree (@trees) {
		$tree = $var_tree;
		# iterate booth type
		foreach my $var_booth (@booths) {
		    $booth = $var_booth;
		    # iterate forwarding options
		    foreach my $var_forwarding (@forwardings) {
			$forwarding = $var_forwarding;
			# iterate pipeline depth options
			foreach my $var_pipe_depth (@pipe_depths) {
			    $pipe_depth = $var_pipe_depth;
			    # check the pipeline depth if enabled forwarding
			    if ($forwarding eq 'YES') {
				if( $arch eq 'CMA' && $pipe_depth < 5) {
				    next;
				} elsif ( $arch eq 'FMA' && $pipe_depth < 3) {
				    next;
				}
			    }
			    # iterate mult pumping option
			    foreach my $var_mult_pumping (@mult_pumpings) {
				$mult_pumping = $var_mult_pumping;
				# no mult pumping option when it is CMA
				next if ($mult_pumping eq 'YES' && $arch eq 'CMA');
				next if ($precision eq 'quad' && $tree eq 'Array');
				# run a job
				$job_id++;
				$total_trans += $transactions;
				    
				next if ($job_id < $start_id);
			       	last if ($job_id > $stop_id);
				
				my $rundir = $job_id;
				mkdir($rundir);
				push(@rundirs, $rundir);
				$genesis_par = generate_genesis_arg();
				$seed = int(rand(10000000));
				$run_arg = "RUN=\"+Seed=$seed +NumTrans=$transactions +Silent\"";
				$cmd = "make -C $rundir -f \$FPGEN/Makefile run $genesis_par $run_arg";
				if ($clean) { $cmd = $cmd . " clean"; }
	
				my $job_cfg = generate_cfg_name();
				open(JOBCFG, ">${rundir}/jobcfg.txt");
				print JOBCFG $job_cfg;
				close (JOBCFG);

				open(CMD, ">${rundir}/${prefix}.cmd");
				print CMD "#! /bin/sh\n";
				print CMD $cmd . ";";
				close (CMD);
				system("chmod u+x ${rundir}/${prefix}.cmd");
				if($cluster) {
				     $cmd = submit_cmd($rundir, "$prefix-regression")." ${rundir}/${prefix}.cmd";
				}
				push(@jobs, $cmd);

			    }
			}
		    }
		}
	    }
	}
    }
}

sub run_jobs_locally {
    my @jobs = @{shift(@_)};
    my $job_id = 0;
    my @last_threads = ();
    foreach my $cmd (@jobs){
	$job_id++;
	$semaphore->down();
	my $thread = threads->create(\&run_test, $job_id, $cmd );
	# only store last $nThreads threads to be joined
	if($job_id > scalar(@jobs) - $nThreads){
	    push ( @last_threads, $thread);
	} else { # else detach
	    $thread->detach();
	}
    }
    # join last few threads
    foreach my $thread (@last_threads){
	$thread->join();
    }
}

sub run_test {
    my $job_id = shift @_;	
    my $cmd = shift @_;		
    print "Job  $job_id begins.\n";
    print $cmd . "\n";
    open (JOBOUT, "$cmd |");
    my @jobout = <JOBOUT>;
    close (JOBOUT);
    $semaphore->up();
    print "Job $job_id finished.\n";
}



sub run_test_checks
{
    my $results = shift(@_);
    my $rundirs = shift(@_);
    my $prefix  = shift(@_);

    my $num_passed_tests = 0;
    my $num_failed_tests = 0;
    my $num_warning_tests = 0;
    my @failed_tests = ();
    my @warning_tests = ();
    my @num_gen_warnings = ();
    # Check results and generate report
    foreach my $rundir ( @$rundirs )
    {
	my $num_gen_warnings = 0;
	system("touch rerun_${prefix}.cmd");
	
	if ( -e "$rundir/gen_bb.log"){
	    $num_gen_warnings = `grep -c '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]' $rundir/gen_bb.log`;
	} 
	if ($num_gen_warnings > 0){
	    push( @warning_tests, $rundir );
	    $num_warning_tests++;
	    push( @num_gen_warnings, $num_gen_warnings);
	    system( "echo '\n' >> ${prefix}_warnings" ); 
	    system( "grep make ${rundir}/${prefix}.cmd >> ${prefix}_warnings" );
	    if ( $num_gen_warnings > 0){
		system( "grep '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]' $rundir/gen_bb.log >> ${prefix}_warnings" );
	    }
	}
	
	if( -e "$rundir/TEST_PASS" )
	{
	    # test passed - delete	
	    print "$rundir/TEST_PASS EXISTS!\n";
	    $num_passed_tests++;
	}
	elsif( -e "$rundir/TEST_FAIL" )
	{
	    print "$rundir/TEST_FAIL EXISTS!\n";
	    push( @failed_tests, $rundir );
	    $num_failed_tests++;
	    system( "egrep make ${rundir}/${prefix}.cmd >> rerun_${prefix}.cmd" );
	}
	else
	{
	    print "$rundir/TEST_PASS and $rundir/TEST_FAIL NOT EXIST!\n";
	    push( @failed_tests, $rundir );
	    $num_failed_tests++;
	    system( "egrep make ${rundir}/${prefix}.cmd >> rerun_${prefix}.cmd" );
	}
    }
    open FILE, "> $results" or die "Can't open $results: $!\n";
    print FILE "PASS: $num_passed_tests\n";
    print FILE "FAIL: $num_failed_tests\n";
    print FILE "Tests with warnings: $num_warning_tests\n";
    print "PASS: $num_passed_tests\n";
    print "FAIL: $num_failed_tests\n";
    print "Tests with warnings: $num_warning_tests\n";
    foreach my $failed_test ( @failed_tests ) {
	print FILE "$failed_test: FAIL\n";
    }
    for (my $i = 0; $i < scalar (@warning_tests); $i++){
	print FILE "$warning_tests[$i]: gen_warnings: $num_gen_warnings[$i]\n"
    }

    print FILE "\n\n";
    close FILE;
    $nfail = $num_failed_tests;
    $npass = $num_passed_tests;
}

# sub for generating Genesis runtime arg  
sub generate_genesis_arg {
    # paths for FPGen, FMA, CMA, and MultipleP
    my $FPGen = "top_FPGen.FPGen";
    my $design = $FPGen . "." . $arch;
    my @multps = ();
    if ($arch eq 'FMA') {
	    push (@multps , $design . ".MulShift.MUL0");
    } else {
	push (@multps , $design . ".MUL.Mult.MultP");
    }

    # Genesis runtime arg for setting each parameter
    my $arch_arg = $FPGen . ".Architecture=" . $arch;
    my $frac_arg = $design . ".FractionWidth=" . $frac_width;
    my $exp_arg = $design . ".ExponentWidth=" . $exp_width;
    my $pipe_arg = $design . ".PipelineDepth=" . $pipe_depth;
    my $mult_pumping_arg = "";
    if ($arch eq 'FMA') {
	$mult_pumping_arg = $design . ".EnableMultiplePumping=" . $mult_pumping;
    }
    my $forwarding_arg = $design . ".EnableForwarding=" . $forwarding;
    my $tree_arg;
    my $booth_arg;
    foreach my $multp (@multps){
	$tree_arg .= $multp . ".TreeType=" . $tree . ' ';
	$booth_arg .= $multp . ".BoothType=" . $booth . ' ';
    }
    # The complete arg
    my $arg = "GENESIS_PARAMS=\"" .
	$arch_arg .  " " .
	$frac_arg .  " " .
	$exp_arg .  " " .
	$pipe_arg . " " .
	$mult_pumping_arg . " " .
	$forwarding_arg . " " .
	$tree_arg .  " " .
	$booth_arg . " " .
	"\"";

    return $arg;
}


# sub for generating a name for the cfg  
sub generate_cfg_name {
    # Genesis runtime arg for setting each parameter
    my $arch_name = "Architecture=" . $arch;
    my $precision_name = "Precision=" . $precision;
    my $tree_name = "TreeType=" . $tree;
    my $booth_name = "BoothType=" . $booth;
    my $pipe_name = "PipelineDepth=" . $pipe_depth;
    my $mult_pumping_name = "MultiplePumping=" . $mult_pumping;
    my $forwarding_name = "Forwarding=" . $forwarding;

    # The complete arg
    my $name = "FPGen\n\n" .
	$arch_name .  "\n" .
	$precision_name . "\n" .
	$tree_name .  "\n" .
	$booth_name . "\n" .
	$pipe_name . "\n" .
	$mult_pumping_name . "\n" .
	$forwarding_name . "\n";

    return $name;
}    



sub run_jobs_on_queue {
  my @jobs            = @{shift(@_)};
  my $batch_limit      = shift(@_);
  my $user_batch_limit = shift(@_);

  my @run_jobs = @jobs;

  my $total_jobs = scalar(@run_jobs);
  my $cur_jobs = 0;
  my $job_index = 0;
  my $done_job_index = 0;
  my $jobid;

  my %submitted_jobs = ();

  while ($job_index < $total_jobs ||
	 $cur_jobs > 0 ||
	 $done_job_index < $total_jobs) {



      if( ($job_index < $total_jobs) && ($cur_jobs < $batch_limit)  ) {
	  $jobid = submit_job_to_queue($run_jobs[$job_index]);
	  if ($jobid == -1) {
	      $submitted_jobs{$jobid} = [$job_index, 'error'];
	  }
	  else {
	      $submitted_jobs{$jobid} = [$job_index, 'queued'];
	      $cur_jobs++;
	      
	  }
	  $job_index++;
      }


      if( ($cur_jobs > 0) && ($cur_jobs == $batch_limit || $job_index >= $total_jobs) ) {
	  #wait for some job to complete
	  sleep(30);

	  (my $done_jobs_ref, $cur_jobs) = wait_for_jobs(\%submitted_jobs, $cur_jobs);
	  my @done_jobs = @{$done_jobs_ref};
	  foreach $jobid ( @done_jobs ) {
	      my $fin_test_index = $submitted_jobs{$jobid}->[0];
	      $submitted_jobs{$jobid}->[1] = 'done';
	      $done_job_index++
	  }
      }
  }
}

sub get_user_job_number {
  my $username = `whoami`;
  chomp $username;
  my $cmd = "qstat | grep -c $username";
  sleep(5);
  return `$cmd`;
}


sub submit_job_to_queue {
  my $cmd = shift(@_);
  my $jobid = -1;
  my $i = 0;

  while( $i<10 && $jobid==-1 )
  {
      $i++;

      open(QSUBOUT, "$cmd  2>&1 |");
      my @qsubout = <QSUBOUT>;
      close(QSUBOUT); # or die "Error closing pipe from $cmd: $!\n";

      foreach my $line ( @qsubout)
      {
	chomp( $line );
	  if( $line =~ m/^(\d+)\.cyclades/x ) {
	    $jobid = $1;
	    last;
	  } else {
	    $jobid = -1;
	  }
	

      }

      if( $jobid == -1 ) {
	print "submit_job_to_queue: failed $i time(s)!\n$cmd\nQSUB output:\n@qsubout\n";
      }
      else {
	print "submit_job_to_queue: $cmd\nQSUB job ID $jobid\n---\n";
      }
  }

  return $jobid;
}


sub wait_for_jobs {
  my %submitted_jobs = %{shift(@_)};
  my $cur_jobs = shift(@_);
  my $cur_jobs_init = $cur_jobs;
  my @done_jobs = ();
  my $i;

  my @all_submitted_jobs = keys(%submitted_jobs);
  timestamp();
  print "wait_for_jobs: waiting for $cur_jobs job(s) ... \n";

  while( $cur_jobs > 0 && $cur_jobs == $cur_jobs_init ) {
    if( 1 )
    {
      $i = 0;
      my @qstat = ();

    QSTAT_LOOP: while( $i<10 )
      {
	  $i++;
#	      print "\nRunning qstat $i\n";
	  unless( open(QJOBS, "qstat 2>&1 |") )
	  {
	    sleep( 30 );
	    next QSTAT_LOOP;
	  }
	  else
	  {
	    @qstat = <QJOBS>;
	    close (QJOBS); # or die "Error closing pipe from qstat: $!\n";

#		  print "\nqstat output:\n@qstat\n";

	    last QSTAT_LOOP if( (@qstat < 1) || ($qstat[0] =~ m/Job/i) );

	    # Keep looping if:
	    #  - qstat failed (returned nothing) (?) or
	    #  - qstat looks invalid (first line should contain "Job"(?)

	  }
      }

      die "waitForJobs: qstat is unsuccessful 10 times: $!\n" if( $i >= 10 );

      foreach my $job (@all_submitted_jobs) {
	if ( $submitted_jobs{$job}->[1] eq 'queued' ) {
	  my $done = 1;
	  foreach my $line (@qstat)
	  {
	    $line =~ s/^\s+//;
	    if(  ($line =~ m/(\d+)\./ ) )
	    {
	      my $jobid = $1;
	      if ($jobid eq $job) {
		$done = 0;
	      }
	    }
	  }

	  if ($done == 1) {
	    push(@done_jobs, $job);
	    $cur_jobs--;
	  }
	}
      }
    }
    else {
      print "Warning: Not set up to run on current host\n";
      exit(1);
    }

    if (@done_jobs < 1) {
      sleep( 30 );
    }

  }

  print "Job(s) @done_jobs finished\n";
  return (\@done_jobs, $cur_jobs);
}


#Determines the appropriate job-submission command
sub submit_cmd
{
  my $rundir  = shift(@_);
  my $jobname = shift(@_);

  my $logfile = "${rundir}/submission";
  my $cmd = "";

  $cmd = "jsub  -o $rundir -e $rundir -- ";

  return $cmd;
}

sub mkrundir
{
  my $rundir  = shift(@_);
  my $orig_rundir = $rundir;

  for( my $index = 2; $index > 0; $index++ )
  {
    last if( ! -d $rundir );
    $rundir = "${orig_rundir}_$index";
  }

  # Create rundir in advance to avoid possible collision between parallel runs
  if( ! -d $rundir ) {
    system("mkdir -p $rundir")==0 or die "\nERROR: Cannot create rundir $rundir: !$\n\n";
  }

  return $rundir;
}

sub timestamp{
  my @Month_name = ( "January", "February", "March", "April", "May", "June",
		     "July", "August", "September", "October", "November", "December" );
  my ( $sec, $min, $hour, $day, $month, $year ) = ( localtime ) [ 0, 1, 2, 3, 4, 5 ];
  printf  "Timestamp: %02d:%02d:%02d %02d %s %04d\n", 
    $hour, $min, $sec, $day, $Month_name[$month], $year+1900 ;
}


sub print_help {
  print <<END_OF_MESSAGE;
###############################################################################
Help for Regression.pl
###############################################################################
Usage: Regression.pl [-help] [-cluster] [-iterate] [-email] [-jobs=n] 
                     [-threads=n] [-transactions=n] [-start=n] [-stop=n] 

Purpose: This script is used to run regression tests in parallel on a cluster.


Main options:
    -help  : prints this help file 
    -cluster  : submit jobs to cluster. otherwise, run jobs locally 
    -iterate  : iterate all the valid configs. otherwise, randomly generate configs 
    -email  : send the results to recipients in the email list 
    -jobs  : the number of configs (testing jobs) randomly generated 
    -threads  : the number of threads run jobs locally or the max jobs submited to queue 
    -transactions  : the number of transactions each tests contains 
    -start  : the start job number for iterating part of configs 
    -stop  : the stop job number for iterating part of configs 
###############################################################################
	
END_OF_MESSAGE

}
