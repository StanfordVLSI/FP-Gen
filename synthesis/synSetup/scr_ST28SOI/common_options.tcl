
set ENABLE_INIT_TOP_SYMPLIFY 0
set ENABLE_CLOCK_GATE 1
set ENABLE_HIGH_VOLTAGE 1
set ENABLE_MVT 1
set ENABLE_CGRP 1
set ENABLE_LEAK_OPT 0
set ENABLE_CORX 1

set CLK_PER 5
set JTCK_PER 100
set CLK_MARGIN_BLOCK 1
set CLK_MARGIN 0.5
set DEF_INPUT_DELAY 0.5
set DEF_OUTPUT_DELAY 0.5
set DEF_LOAD 0.02
set MAX_LEAKAGE 0

set CLK_TRAN 0.2
set JTCK_TRAN 0.5

set CG_MIN_BITWIDTH 16
set CG_MAX_FANOUT  1024

set MAX_AREA 0
set write_elab_ddc 1
set write_preth_ddc 1
set write_gv 1

set FM_AUTO_INFER false
set FSM_EXPORT_FSM false

set read_budgets 0

set UNGROUP_START_LEVEL 2


#This options is to bootstrap the budges by reading in previously generated budgets
set BOOTSTRAP_BUDGETS 1


set CacheController_CHAIN_COUNT 6
set Tile_CHAIN_COUNT 5
set DO_SCAN_STITCH 1

suppress_message [list PSYN-650 PSYN-651 PARA-047 PSYN-025 PSYN-024]
