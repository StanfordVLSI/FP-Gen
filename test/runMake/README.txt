

make cleanall gen \
                     DESIGN_NAME=Multiplier \
                     INST_NAME=Multiplier \
                     MOD_NAME=Multiplier \
                     TOP_NAME=top_Multiplier 

locDesignMap.pl \
                     INPUT_XML=small_Multiplier.xml \
                     DESIGN_FILE=/dev/null \
                     LOC_DESIGN_MAP_FILE=/dev/null \
                     PARAM_LIST_FILE=test/runMake/Multiplier.paramList \
                     PARAM_ATTRIBUTE_FILE=/dev/null

runMake.pl                 -t test/runMake/Multiplier.target \
                           -a test/runMake/Multiplier.rawData   \
                           -p test/runMake/Multiplier.paramList \
                           DESIGN_FILE=test/numbers/Multiplier-32.design \
                           SYN_CLK_PERIOD=2.0 \
                           DESIGN_NAME=Multiplier \
                           INST_NAME=Multiplier \
                           MOD_NAME=Multiplier \
                           TOP_NAME=top_Multiplier \
                           SYN_SAIF_MODE=0 \
                           SIM_ENGINE=synopsys \
                           VT=svt \
                           Voltage=0v9  \
                           io2core=30



make cleanall

hammerLight.pl \
     DESIGN_NAME=Multiplier \
     INST_NAME=Multiplier \
     MOD_NAME=Multiplier \
     TOP_NAME=top_Multiplier \
     SIM_ENGINE=synopsys \
     DESIGN_FILE=/dev/null \
     LOC_DESIGN_FILE=test/energyDelay/Multiplier.design \
     LOC_DESIGN_MAP_FILE=test/energyDelay/Multiplier.designLocMap \
     PARAM_LIST_FILE=test/energyDelay/Multiplier.paramList \
     PARAM_ATTRIBUTE_FILE=test/energyDelay/Multiplier.paramAttribute  


energyDelay.pl \
               -a $PWD/test/energyDelay/Multiplier.rawData   \
               -p $PWD/test/energyDelay/Multiplier.paramList \
               -L 43 \
               -n 5 \
               -r /tmp/jbrunhav/numbers/genTables \
               -H $PWD \
               -c scripts/BB_setup.sh \
               DESIGN_FILE=/dev/null \
               DESIGN_NAME=Multiplier \
               INST_NAME=Multiplier \
               MOD_NAME=Multiplier \
               TOP_NAME=top_Multiplier \
               SIM_ENGINE=synopsys \
               VT=svt \
               Voltage=0v9  \
               io2core=30


need a config file for numbers...
need a a seed design file for numbers...

make cleanall

hammerLight.pl \
     DESIGN_NAME=Multiplier \
     INST_NAME=Multiplier \
     MOD_NAME=Multiplier \
     TOP_NAME=top_Multiplier \
     SIM_ENGINE=synopsys \
     DESIGN_FILE=/dev/null \
     LOC_DESIGN_FILE=test/energyDelay/Multiplier.design \
     LOC_DESIGN_MAP_FILE=test/energyDelay/Multiplier.designLocMap \
     PARAM_LIST_FILE=test/energyDelay/Multiplier.paramList \
     PARAM_ATTRIBUTE_FILE=test/energyDelay/Multiplier.paramAttribute  


#####################################

numbers.pl -f $PWD/test/numbers/Multiplier-16.cfg
numbers.pl -f $PWD/test/numbers/Multiplier-32.cfg


#####################################
Debugging Post-Proc

paretoFilter.pl   -a ./../NUM_Results/intermediates/Multiplier-32.rawData  -p ./../NUM_Results/intermediates/Multiplier-32.paramList  -P ./../NUM_Results/intermediates/Multiplier-32.paramAttribute  -D ./../NUM_Results/intermediates/Multiplier-32.DataDump  -d ./../NUM_Results/Multiplier-32.Data  -s ./../NUM_Results/intermediates/Multiplier-32.paretoData  -m ./../NUM_Results/intermediates/Multiplier-32.DesignEnum 

paretoReport.pl  -d  ./../NUM_Results/Multiplier-32.Data  -s  ./../NUM_Results/intermediates/Multiplier-32.paretoData  -m  ./../NUM_Results/intermediates/Multiplier-32.DesignEnum  -t  Multiplier-32  -R  ./../NUM_Results/Multiplier-32.pdf 
                       
energy_delay_plot_v2.py  -f ./../NUM_Results/intermediates/Multiplier-32.paretoData  -F Multiplier-32-Pareto.pdf --fileOut2 Multiplier-32-Pareto-Delay.pdf -t Multiplier-32-Pareto 

energy_delay_plot_v2.py  -f ./../NUM_Results/Multiplier-16.Data  -F Multiplier-16-All.pdf --fileOut2 Multiplier-16-All-Delay.pdf --fileOut3 Multiplier-16-All-LinDelay.pdf --fileOut4 Multiplier-16-All-RunTime.pdf -t Multiplier-16-All 
