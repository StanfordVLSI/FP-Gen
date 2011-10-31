echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay -1\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay 3500\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay 3000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay 2500\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay 2000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay 1500\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT hvt; set Voltage 0v8; set target_delay 0\""  | qsub -q horowitz -p -1

echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay -1\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay 1800\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay 1600\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay 1400\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay 1200\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay 1000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT svt; set Voltage 0v9; set target_delay 0\""  | qsub -q horowitz -p -1

echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay -1\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 1200\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 1100\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 1000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 900\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 800\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 700\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set ENABLE_MANUAL_PLACEMENT 1;set VT lvt; set Voltage 1v0; set target_delay 0\""  | qsub -q horowitz -p -1


echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay -1\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay 3500\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay 3000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay 2500\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay 2000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay 1500\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT hvt; set Voltage 0v8; set target_delay 0\""  | qsub -q horowitz -p -1

echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay -1\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay 1800\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay 1600\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay 1400\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay 1200\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay 1000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT svt; set Voltage 0v9; set target_delay 0\""  | qsub -q horowitz -p -1

echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay -1\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 1200\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 1100\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 1000\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 900\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 800\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 700\""  | qsub -q horowitz -p -1
echo "cd \$PBS_O_WORKDIR; pwd;  icc_shell -f multiplier_icc.tcl -x \"set VT lvt; set Voltage 1v0; set target_delay 0\""  | qsub -q horowitz -p -1


