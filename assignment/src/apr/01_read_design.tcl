# 1. Read design
set step      "01_read_design"

# Read verilog netlist
read_verilog -top ${TOP_MODULE} ${GATE_NETLIST}
# This command automatically links block, so link_block is unnecessary
# link_block
current_design $TOP_MODULE

set_isolate_ports -type buffer [all_outputs]

# Update metal directions to the Psylab common setting; you can ignore this
source update_metal_info.tcl

# Set decap cells, STD Fillers and IO Fillers; you can ignore this
source standard_cells.tcl

#Create reports + result directories
if {[file exist $REPORTS_DIR]} {
    file delete -force -- $REPORTS_DIR
}
file mkdir $REPORTS_DIR

if {[file exist $RESULTS_DIR]} {
    file delete -force -- $RESULTS_DIR
}
file mkdir $RESULTS_DIR


#*****************************************************************************
#**                     Create scenarios + corners                          **
#*****************************************************************************
# Scenarios are how the tool approaches multi-corner flows. When doing design, we always want to plan for the worst-case situation. However, depending on our type of analysis, the worst case may be
# that data arrives too slowly, or the worst case may be that data arrives too quickly. Thus, we set up scenarios for both situations and choose which one to use depending on our usecases. 

# Remove any pre-set constraints - will likely do nothing
remove_sdc
remove_mode -all
remove_corner -all
remove_scenario -all

# Create worst case corner scenario
# Corner definition of worst-case refers to the parasitic caps, thus "worst case" means most delays
# In VLSI design, we plan for "worst case" situation for each scenario. Thus, for max path delay, we use worst case corner as the worst case for setup is that a path is too slow
create_mode func1
create_corner wc
create_scenario -mode func1 -corner wc -name func1_wc
current_scenario func1_wc

# The .sdc file is the output from synthesis; it contains all of the constraints we set (clock period, input/output delay, etc.) so we don't need to worry about re-initializing all of these constraints
read_sdc ${GATE_SRC_DIR}/results/${TOP_MODULE}.sdc

#The clock details are read from the .sdc; however, we likely will want to change this from synthesis. Syn has no wire delays, so these will kill timing
remove_clocks -all
create_clock -name clk -period $APR_CLOCK_PERIOD -waveform [list 0 [expr 0.5*$APR_CLOCK_PERIOD]] [get_ports clk_i]

report_port -verbose


#What is tlu_plus files? Virtual route and post-layout DRC rules with rules - Extraction rules -Parasitic extraction. Vias.
#
# TLU+ file contains advanced process effects that can be used for parasitic extraction.
# It is genetrated from ITF files. The process effect (rho, etching) includes
# the effect of width, space, density, and temperature on the resistance, capacitance.
# TLU+ is a binary table format that stores the RC coeff
#
# Interconnect Technology Format (ITF) defines cross section profile of the process.
# It is an ordered list of conductor and dielectric layer definition statements. The layers are
# defined from topmost dielectric layer to the bottom most dielectric layer excluding substarate.

read_parasitic_tech -tlup $MIN_TLUPLUS_FILE -layermap $TECH2ITF_MAP_FILE -name wc
set_parasitic_parameters -corners wc -late_spec wc -late_temperature 125 \
                                     -early_spec wc -early_temperature 125
report_parasitic_parameters -corners wc


set_process_label SS125 -library $TECH_LABEL
set_voltage 0.9
set_temperature 125
report_pvt


set_scenario_status func1_wc -hold false -cell_em false -signal_em false -all -active false


# Create best case corner scenario 
# Corner definition of best-case refers to the parasitic caps, thus "best case" means least delays
# In VLSI design, we plan for "worst case" situation for each scenario. Thus, for min path delay, we use best case corner as the worst case for hold is that a path is too fast
create_corner bc
create_scenario -mode func1 -corner bc -name func1_bc
current_scenario func1_bc

read_sdc ${GATE_SRC_DIR}/results/${TOP_MODULE}.sdc
#The clock details are read from the .sdc; however, we likely will want to change this from synthesis. Syn has no wire delays, so these will kill timing
remove_clocks -all
create_clock -name clk -period $APR_CLOCK_PERIOD -waveform [list 0 [expr 0.5*$APR_CLOCK_PERIOD]] [get_ports clk_i]

report_port -verbose

read_parasitic_tech -tlup $MAX_TLUPLUS_FILE -layermap $TECH2ITF_MAP_FILE -name bc
set_parasitic_parameters -corners bc -late_spec bc -late_temperature 0 \
                                     -early_spec bc -early_temperature 0
report_parasitic_parameters -corners bc


set_process_label FF0 -library $TECH_LABEL
set_voltage 1.1
set_temperature 0
report_pvt

set_scenario_status func1_bc -setup false -cell_em false -signal_em false -all -active false
current_scenario func1_wc

# derate factorr
set_timing_derate -early $DERATE_EARLY
set_timing_derate -late  $DERATE_LATE

set_app_options -name time.enable_non_sequential_checks -value false
