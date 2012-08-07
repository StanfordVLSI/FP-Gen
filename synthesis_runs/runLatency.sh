#!/bin/sh

MAX_JOBS=30

mkdir -p CMA378
pushd CMA378
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"
jsub -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA"

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr


popd

mkdir -p CMA378MP
pushd CMA378MP
make -f $FPGEN/Makefile gen GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES"
jsub -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES"

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

popd

mkdir -p CMA378MP_OS1B3
pushd CMA378MP_OS1B3
make -f $FPGEN/Makefile gen GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"
jsub -I -- make -f $FPGEN/Makefile run GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1"

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=CMA top_FPGen.FPGen.CMA.MUL.EnableMultiplePumping=YES top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType=3 top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType=OS1" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr


popd

mkdir -p FMA667
pushd FMA667
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"
jsub -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA"

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr


popd

mkdir -p FMA667MP
pushd FMA667MP
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES"
jsub -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES"

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=FMA top_FPGen.FPGen.FMA.MUL.EnableMultiplePumping=YES" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 SMART_RETIMING=1 APPENDIX=cgsr

popd


mkdir -p DW_FMA666
pushd DW_FMA666
make -f $FPGEN/Makefile gen  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"
jsub -max_jobs $MAX_JOBS -I -- make -f $FPGEN/Makefile run  GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA"

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=0.5 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=0.75 VT=lvt VOLTAGE=1v0 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=1 VT=lvt VOLTAGE=1v0 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=1 VT=lvt VOLTAGE=1v0 CLK_GATING=0


jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=1.5 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=2 VT=svt VOLTAGE=0v8 CLK_GATING=0

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=3 VT=hvt VOLTAGE=0v8 APPENDIX=cg

jsub -max_jobs $MAX_JOBS  -l mppdepth=2 -l mem=8000m -- make -f $FPGEN/Makefile run_icc run_icc_opt GENESIS_PARAMS="top_FPGen.FPGen.Architecture=DW_FMA" SYN_CLK_PERIOD=3 VT=hvt VOLTAGE=0v8 CLK_GATING=0


popd
