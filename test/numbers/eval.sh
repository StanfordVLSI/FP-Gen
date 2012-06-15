#!/bin/sh

echo "16 FMA svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA.cfg \
     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-16-lvt-1v0-r3 DESIGN_FILE=$PWD/test/numbers/FMA-16.design \
     FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param 2>&1 | tee -a eval_log.log

echo "32 FMA svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA.cfg \
     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-32-lvt-1v0-r3 DESIGN_FILE=$PWD/test/numbers/FMA-32.design \
     FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param 2>&1 | tee -a eval_log.log

echo "64 FMA svt"  
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA.cfg \
     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-64-lvt-1v0-r3 DESIGN_FILE=$PWD/test/numbers/FMA-64.design \
     FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param 2>&1 | tee -a eval_log.log

#echo "128 FMA svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-128-lvt-1v0-r3 DESIGN_FILE=$PWD/test/numbers/FMA-128.design  \
#     FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param 2>&1 | tee -a eval_log.log

echo "32 FMA svt Piped" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA-P.cfg \
     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-32-lvt-1v0-pipe-r024 DESIGN_FILE=$PWD/test/numbers/FMA-32-P.design \
     FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param 2>&1 | tee -a eval_log.log

#echo "32 FMA lvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-32 DESIGN_FILE=$PWD/test/numbers/FMA-32.design 

#echo "32 FMA hvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=hvt Voltage=0v8  DESIGN_TITLE=FMA-32 DESIGN_FILE=$PWD/test/numbers/FMA-32.design 

#echo "32 FPMult svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-32 DESIGN_FILE=$PWD/test/numbers/FPMult-32.design 

#echo "32 FPMult lvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=FPMult-32 DESIGN_FILE=$PWD/test/numbers/FPMult-32.design 

#echo "32 FPMult hvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=hvt Voltage=0v8  DESIGN_TITLE=FPMult-32 DESIGN_FILE=$PWD/test/numbers/FPMult-32.design 




#echo "64 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-64 DESIGN_FILE=$PWD/test/numbers/MultiplierP-64.design 

#echo "64 multiplier svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/Multiplier-64.cfg VT=svt Voltage=0v9  

#echo "53 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-53 DESIGN_FILE=$PWD/test/numbers/MultiplierP-53.design 

#echo "64 FPMult svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-64 DESIGN_FILE=$PWD/test/numbers/FPMult-64.design 

#echo "64 FMA svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FMA-64 DESIGN_FILE=$PWD/test/numbers/FMA-64.design 

#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-64-lvt-1v0 DESIGN_FILE=$PWD/test/numbers/FMA-64.design \
#     FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param





#echo "128 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-128 DESIGN_FILE=$PWD/test/numbers/MultiplierP-128.design 

#echo "128 multiplier svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/Multiplier-128.cfg VT=svt Voltage=0v9  

#echo "113 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-113 DESIGN_FILE=$PWD/test/numbers/MultiplierP-113.design 

#echo "128 FPMult svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-128 DESIGN_FILE=$PWD/test/numbers/FPMult-128.design 

#echo "128 FMA svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FMA-128 DESIGN_FILE=$PWD/test/numbers/FMA-128.design 

