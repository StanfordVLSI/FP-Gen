#!/usr/bin/perl

use strict;
use warnings ;
use Getopt::Std;

use YAML::Any ;
use Data::Dumper ;


#print `cat test_01.yml`;
#
#my $cfg = `cat test_01.yml` ;
#my $hash = Load $cfg;
#
#print Dumper( $hash );


my $configuration = 
{
          'makefile' => 'Makefile',
          'rollup_destination' => 'data_2012_08_05/rollup',
          'make_params' => [
                             {
                               'VOLTAGE' => '1v0',
                               'VT' => 'lvt'
                             },
                             {
                               'VOLTAGE' => '1v0',
                               'VT' => 'lvt'
                             },
                             {
                               'VOLTAGE' => '1v0',
                               'VT' => 'lvt'
                             },
                             {
                               'VOLTAGE' => '1v0',
                               'VT' => 'lvt'
                             }
                           ],
          'design' => [
                        {
                          'top_FPGen.FPGen.Architecture' => 'FMA',
                          'top_FPGen.FPGen.FMA.ExponentWidth' => 5,
                          'top_FPGen.FPGen.FMA.FractionWidth' => 10
                        },
                        {
                          'top_FPGen.FPGen.Architecture' => 'CMA',
                          'top_FPGen.FPGen.CMA.ExponentWidth' => 5,
                          'top_FPGen.FPGen.CMA.FractionWidth' => 10
                        },
                        {
                          'top_FPGen.FPGen.Architecture' => 'FMA',
                          'top_FPGen.FPGen.FMA.ExponentWidth' => 5,
                          'top_FPGen.FPGen.FMA.FractionWidth' => 10
                        },
                        {
                          'top_FPGen.FPGen.Architecture' => 'CMA',
                          'top_FPGen.FPGen.CMA.ExponentWidth' => 5,
                          'top_FPGen.FPGen.CMA.FractionWidth' => 10
                        },
                        {
                          'top_FPGen.FPGen.Architecture' => 'FMA',
                          'top_FPGen.FPGen.FMA.ExponentWidth' => 5,
                          'top_FPGen.FPGen.FMA.FractionWidth' => 10
                        },
                        {
                          'top_FPGen.FPGen.Architecture' => 'CMA',
                          'top_FPGen.FPGen.CMA.ExponentWidth' => 5,
                          'top_FPGen.FPGen.CMA.FractionWidth' => 10
                        }
                      ],
          'setupfile' => 'scripts/setup_kiwi.bash',
          'delay_make_variable' => 'SYN_CLK_PERIOD',
          'make_arguments' => 'USE_SAIF=1',
          'eval_rules' => 'comp run rollup1 run_dc rollup2 run_icc rollup3 run_icc_opt rollup4',
          'cleanup' => 1,
          'design_title' => 'FMA',
          'param_make_variable' => 'GENESIS_PARAMS',
          'target_delay' => [
                              '0.5',
                              '0.5',
                              '0.7',
                              '0.7',
                              '0.9',
                              '0.9'
                            ],
          'env' => {
                     'FPGEN' => '/horowitz/users/jbrunhav/jb_co_p4_3/ChipGen/FP-Gen'
                   },
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'runs' => 6,
          'rollup_variable' => 'ROLLUP_TARGET'
};


print Dump $configuration;
