# 4. place_opt
set step      "04_place_opt"

set_scenario_status [all_scenarios] -active false
set_scenario_status func1_wc -active true

set_max_transition 0.55 -scenarios func1_wc [current_design]

# Remove ideal network
remove_ideal_network -all
set_ideal_network [get_ports clk_i]

# place_opt options
# place opt cell name prefix
set_app_options -name opt.common.user_instance_name_prefix -value "PO_"
set_app_options -name time.disable_recovery_removal_checks -value true
set_app_options -name time.remove_clock_reconvergence_pessimism -value true
set_app_options -name time.crpr_remove_clock_to_data_crp -value true

# This single command will place all od your cells and optimize their locations - this is critical
place_opt

# Connect pg net to added cells
connect_pg_net -automatic

puts "** INFO: check pg connection"
check_pg_connectivity

# runnig extraction and upating the timing
update_timing
