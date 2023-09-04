#===============================================================
#File Name : run_pt.tcl
#PrimeTime shell : pt_shell
#GUI : primetime
#RUN TCL : source
#Reset Design : remove_design -all
#Reset Library : remove_lib -all
#===============================================================
#Modify FiLe Name
#===============================================================
set netlist "Duty2Voltage_div_testlec_dft"
set netlist_top "div"
set sdf "Duty2Voltage_div_testlec_dft"
set sdc "div_pt"
set setup "synopsys_pt.setup"

#===============================================================
#Set up Library
#===============================================================
source $setup

#===============================================================
#Read NetList 
#===============================================================
read_verilog ./dft/${netlist}.v
current_design $netlist_top
link

#===============================================================
#setting Clock,Reset Contraints
#===============================================================
read_sdc -echo  ${sdc}.sdc
set_drive 0 [list clk rst_n]
set_drive 0 [get_port rst_n*]
set_false_path -from [get_ports rst_n*]

#===============================================================
#Read SDF File
#===============================================================
Read_sdf ./dft/${sdf}.sdf
report_annotated -from [get_ports rst_n*]

#===============================================================
#Report Clock information post false-path setting
#===============================================================
echo "reporting clock information post set"
report_clock                 > ./pt/${netlist}_pt_clock.rpt
report_port  -input_delay   >> ./pt/${netlist}_pt_clock.rpt
report_port  -output_delay  >> ./pt/${netlist}_pt_clock.rpt
check_timing                >> ./pt/${netlist}_pt_clock.rpt

#===============================================================
#Report ALL violation & timing path Post false-path settings
#===============================================================
echo "reporting timing check information post sim"
#report_constraint -all_violators > $TIME_RPT 
report_timing                                       > ./pt/${netlist}_pt_timing.rpt
report_timing -net -transition_time -capacitance   >> ./pt/${netlist}_pt_timing.rpt
report_timing -nworst 10 -path_type summary        >> ./pt/${netlist}_pt_timing.rpt