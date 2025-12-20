# 8. Report

# Utilization
report_utilization -verbose > reports/utilization.rpt

# Power
report_power -verbose > reports/power.rpt

# Constraints
report_constraint -scenarios [all_scenarios] -all_violators -verbose > reports/constraints.rpt
report_design -all -nosplit > reports/design.rpt

# legality
check_legality -verbose > reports/legality.rpt

# High fanout nets
# report_net_fanout -threshold 64 -high_fanout -physical -nosplit -tree > reports/hfn.rpt
# cannot have -threshold 64 and -high_fanout at the same time
report_net_fanout -threshold 64 -physical -nosplit -tree > reports/hfn.rpt

# Clock
report_clock -attributes -skew -nosplit [all_clocks] > reports/clock.rpt
report_clock_gating -gated -ungated -multi_stage > reports/clock_gating.rpt

# Timing
report_timing -attributes -nosplit -capacitance -transition_time -input_pins -nets \
-max_paths 100 -nworst 1 -path_type full -derate -scenarios [all_scenarios] -delay_type max > reports/timing_setup.rpt

report_timing -attributes -nosplit -capacitance -transition_time -input_pins -nets \
-max_paths 100 -nworst 1 -path_type full -derate -scenarios [all_scenarios] -delay_type min > reports/timing_hold.rpt

# Level of butter/tree
report_buffer_trees -from [get_nets clk_i] > reports/clock_buffer_tree.rpt
report_buffer_trees -from [get_nets rst_i] > reports/reset_buffer_tree.rpt
