#!/bin/sh

MAX_JOBS=47

mkdir -p CMA378
pushd CMA378
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9 SMART_RETIMING=1


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8 SMART_RETIMING=1

popd

mkdir -p CMA367
pushd CMA367
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9 SMART_RETIMING=1


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8 SMART_RETIMING=1

popd


mkdir -p CMA489
pushd CMA489
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8

popd

mkdir -p CMA367MP
pushd CMA367MP
make -f $FPGEN/Makefile gen GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.4 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=7 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8


popd

mkdir -p CMA378MP
pushd CMA378MP
make -f $FPGEN/Makefile gen GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.4 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8

popd

mkdir -p CMA489MP
pushd CMA489MP
make -f $FPGEN/Makefile gen GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.4 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.PipelineDepth=9 top_FPGen.FPGen.CMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8


popd


mkdir -p CMA378MP_OS1B3
pushd CMA378MP_OS1B3
make -f $FPGEN/Makefile gen GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"
$FPGEN/scripts/jsub -rerun 3 -I -- make -f $FPGEN/Makefile run GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8


popd

mkdir -p FMA667
pushd FMA667
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=0.4 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8


popd

mkdir -p FMA667MP
pushd FMA667MP
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.4 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.6 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1 VT=svt VOLTAGE=0v9


$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.EnableMultiplePumping=YES"  SYN_CLK_PERIOD=2.5 VT=hvt VOLTAGE=0v8


popd


mkdir -p DW_FMA666
pushd DW_FMA666
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"
$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"  SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"  SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"  SYN_CLK_PERIOD=1 VT=lvt VOLTAGE=1v0

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"  SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"  SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8

$FPGEN/scripts/jsub -rerun 3 -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"  SYN_CLK_PERIOD=3 VT=hvt VOLTAGE=0v8

popd
