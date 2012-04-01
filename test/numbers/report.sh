#!/bin/sh


#echo "16 multiplier svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/Multiplier-16.cfg VT=svt Voltage=0v9  

#echo "16 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-16 DESIGN_FILE=$PWD/test/numbers/MultiplierP-16.design 


#echo "11 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-11 DESIGN_FILE=$PWD/test/numbers/MultiplierP-11.design 


#RERUN AFTER FIX
#echo "16 FMA svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FMA-16 DESIGN_FILE=$PWD/test/numbers/FMA-16.design 


#RERUN AFTER FIX
#echo "16 FPMult svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-16 DESIGN_FILE=$PWD/test/numbers/FPMult-16.design 




echo "32 multiplier svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/Multiplier-32.cfg VT=svt Voltage=0v9  \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

#echo "32 multiplier lvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/Multiplier-32.cfg VT=lvt Voltage=1v0  

#echo "32 multiplier hvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/Multiplier-32.cfg VT=hvt Voltage=0v8  

echo "32 multiplierP svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-32 DESIGN_FILE=$PWD/test/numbers/MultiplierP-32.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

#echo "32 multiplierP lvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=MultiplierP-32 DESIGN_FILE=$PWD/test/numbers/MultiplierP-32.design 

#echo "32 multiplierP hvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=hvt Voltage=0v8  DESIGN_TITLE=MultiplierP-32 DESIGN_FILE=$PWD/test/numbers/MultiplierP-32.design 





echo "24 multiplierP svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-24 DESIGN_FILE=$PWD/test/numbers/MultiplierP-24.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

#echo "24 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=MultiplierP-24 DESIGN_FILE=$PWD/test/numbers/MultiplierP-24.design 

#echo "24 multiplierP svt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
#     VT=hvt Voltage=0v8  DESIGN_TITLE=MultiplierP-24 DESIGN_FILE=$PWD/test/numbers/MultiplierP-24.design 


echo "32 FMA svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=FMA-32 DESIGN_FILE=$PWD/test/numbers/FMA-32.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

#echo "32 FMA lvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=FMA-32 DESIGN_FILE=$PWD/test/numbers/FMA-32.design 

#echo "32 FMA hvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FMA.cfg \
#     VT=hvt Voltage=0v8  DESIGN_TITLE=FMA-32 DESIGN_FILE=$PWD/test/numbers/FMA-32.design 

echo "32 FPMult svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FPMult.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-32 DESIGN_FILE=$PWD/test/numbers/FPMult-32.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

#echo "32 FPMult lvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=lvt Voltage=1v0  DESIGN_TITLE=FPMult-32 DESIGN_FILE=$PWD/test/numbers/FPMult-32.design 

#echo "32 FPMult hvt" 
#echo "==============================================================="
#numbers.pl -f $PWD/test/numbers/FPMult.cfg \
#     VT=hvt Voltage=0v8  DESIGN_TITLE=FPMult-32 DESIGN_FILE=$PWD/test/numbers/FPMult-32.design 




echo "64 multiplierP svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-64 DESIGN_FILE=$PWD/test/numbers/MultiplierP-64.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "64 multiplier svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/Multiplier-64.cfg VT=svt Voltage=0v9  \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "53 multiplierP svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-53 DESIGN_FILE=$PWD/test/numbers/MultiplierP-53.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "64 FPMult svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FPMult.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-64 DESIGN_FILE=$PWD/test/numbers/FPMult-64.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "64 FMA svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=FMA-64 DESIGN_FILE=$PWD/test/numbers/FMA-64.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param






echo "128 multiplierP svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-128 DESIGN_FILE=$PWD/test/numbers/MultiplierP-128.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "128 multiplier svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/Multiplier-128.cfg VT=svt Voltage=0v9  DESIGN_FILE=$PWD/test/numbers/Multiplier-128.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "113 multiplierP svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/MultiplierP.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=MultiplierP-113 DESIGN_FILE=$PWD/test/numbers/MultiplierP-113.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "128 FPMult svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FPMult.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=FPMult-128 DESIGN_FILE=$PWD/test/numbers/FPMult-128.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param

echo "128 FMA svt" 
echo "==============================================================="
numbers.pl -f $PWD/test/numbers/FMA.cfg \
     VT=svt Voltage=0v9  DESIGN_TITLE=FMA-128 DESIGN_FILE=$PWD/test/numbers/FMA-128.design \
     REPORT_ONLY=1 FLOW_PARAM_FILE=$PWD/test/numbers/samehFlow.param


