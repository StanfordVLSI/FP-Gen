hammerLight.pl \
     DESIGN_NAME=MultiplierP \
     INST_NAME=MultiplierP \
     MOD_NAME=MultiplierP \
     TOP_NAME=top_MultiplierP \
     VALID_DESIGN_NAME=yes \
     SIM_ENGINE=synopsys \
     DESIGN_FILE=/dev/null \
     LOC_DESIGN_FILE=test/numbers/FOO.design \
     LOC_DESIGN_MAP_FILE=/dev/null \
     PARAM_LIST_FILE=/dev/null \
     PARAM_ATTRIBUTE_FILE=/dev/null  


hammerLight.pl \
     DESIGN_NAME=FPMult \
     INST_NAME=FPMult \
     MOD_NAME=FPMult \
     TOP_NAME=top_FPMult \
     VALID_DESIGN_NAME=yes \
     SIM_ENGINE=synopsys \
     DESIGN_FILE=/dev/null \
     LOC_DESIGN_FILE=test/numbers/FOO.design \
     LOC_DESIGN_MAP_FILE=/dev/null \
     PARAM_LIST_FILE=/dev/null \
     PARAM_ATTRIBUTE_FILE=/dev/null  


hammerLight.pl \
     DESIGN_NAME=FMA \
     INST_NAME=FMA \
     MOD_NAME=FMA \
     TOP_NAME=top_FMA \
     VALID_DESIGN_NAME=yes \
     SIM_ENGINE=synopsys \
     DESIGN_FILE=/dev/null \
     LOC_DESIGN_FILE=test/numbers/FOO.design \
     LOC_DESIGN_MAP_FILE=/dev/null \
     PARAM_LIST_FILE=/dev/null \
     PARAM_ATTRIBUTE_FILE=/dev/null  


#Need to Rerun ParetoReport for all runs as the color maps are off...


 paretoReport.pl  -d  /hd/horowitz/users/jbrunhav/jb_co_p4_3/ChipGen/FP-Gen/../NUM_Results/FPMult-64.Data  -s  /hd/horowitz/users/jbrunhav/jb_co_p4_3/ChipGen/FP-Gen/../NUM_Results/intermediates/FPMult-64.paretoData  -m  /hd/horowitz/users/jbrunhav/jb_co_p4_3/ChipGen/FP-Gen/../NUM_Results/intermediates/FPMult-64.DesignEnum  -t  FPMult-64  -R  /hd/horowitz/users/jbrunhav/jb_co_p4_3/ChipGen/FP-Gen/../NUM_Results/FPMult-64.pdf
