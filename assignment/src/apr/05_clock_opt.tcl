# 5. clock_opt
set step      "05_clock_opt"

set_scenario_status [all_scenarios] -active false
set_scenario_status func1_wc -active true
set_scenario_status func1_bc -active true

# Constraints
set_max_transition 0.55 -scenarios func1_wc [current_design]
set_max_transition 0.45 -scenarios func1_bc [current_design]

# Remove ideal network
remove_ideal_network -all

# Check clock tree
check_clock_trees -clocks [all_clocks]

# Set clock tree option
set_clock_tree_options \
    -clocks [all_clocks] \
    -corners [all_corners] \
    -target_skew 0.0
report_clock_tree_options

set_max_transition 0.2 -scenarios func1_wc -clock_path [all_clocks]
set_max_transition 0.15 -scenarios func1_bc -clock_path [all_clocks]

# TSMC65 default routing rule of M1 is WIDTH 0.09 spacing 0.09

# clock routing rule does not take a generated clock as input

set valid_clocks [get_clocks -quiet -filter "is_generated == false && is_virtual == false"]
if { [sizeof_collection $valid_clocks] > 0 } {
    set_ignored_layers -rc_congestion_ignored_layers {AP} -verbose
    if { [info exist CLK_MAX_ROUTING_LAYER] && ( $CLK_MAX_ROUTING_LAYER != "" ) } {
        set_ignored_layers -max_routing_layer [get_layers $CLK_MAX_ROUTING_LAYER]
        set_app_options -name route.common.global_max_layer_mode -value hard
    }
    if { [info exist CLK_MIN_ROUTING_LAYER] && ( $CLK_MIN_ROUTING_LAYER != "" ) } {
        set_ignored_layers -min_routing_layer [get_layers $CLK_MIN_ROUTING_LAYER]
        set_app_options -name route.common.global_min_layer_mode -value allow_pin_connection
    }

    report_ignored_layers -verbose

    set_clock_routing_rules -default_rule -clocks $valid_clocks -net_type all \
    -max_routing_layer $CLK_MAX_ROUTING_LAYER -min_routing_layer $CLK_MIN_ROUTING_LAYER

    report_clock_routing_rules
}

# Clock Max Net Length
if { [info exist CTS_MAX_NET_LENGTH] && ( $CTS_MAX_NET_LENGTH != "" ) } {
    # constraints maximum net length for cts (synthesize_clock_tress)
    # measured from the net driver pin to its farthest load pin.
    # Soft constraint

    if { [expr $CTS_MAX_NET_LENGTH] > 200 } {
        # Refer shield rule
        set_app_options -name cts.common.max_net_length -value 200
    } else {
        set_app_options -name cts.common.max_net_length -value $CTS_MAX_NET_LENGTH
    }
}


# Check CLK cells only
derive_clock_cell_references


# clock_opt options
set_app_options -name opt.common.user_instance_name_prefix -value "CTS_"

# CTS (clock tree synthesis) - again, like place_opt, this is your critical command
clock_opt

report_clock_timing -type summary -nosplit \
-significant_digits 4 -scenarios [all_scenarios] \
> reports/clock_timing.summary.rpt
report_clock_timing -type latency -verbose -nosplit \
-significant_digits 4 -scenarios [all_scenarios] -nworst 10 \
> reports/clock_timing.latency.rpt
report_clock_timing -type skew -verbose -nosplit \
-significant_digits 4 -scenarios [all_scenarios] -nworst 10 \
> reports/clock_timing.skew.rpt

# Connect pg net to added cells
connect_pg_net -automatic


puts "** INFO: check pg connection"
check_pg_connectivity

# runnig extraction and upating the timing
update_timing
