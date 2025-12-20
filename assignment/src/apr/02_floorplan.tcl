# 2. Floorplan
set step      "02_floorplan"

set_scenario_status [all_scenarios] -active false
set_scenario_status func1_wc -active true

set_max_transition 0.55 -scenarios func1_wc [current_design]

# TSMC65 default routing rule of M1 is WIDTH 0.09 spacing 0.09

# Ignored in congestion analysis and RC estimation (AP is default)
# If min/max routing layers are set, all exclusive layers is automatically rc_congestion ignored
set_ignored_layers -rc_congestion_ignored_layers {AP} -verbose

if { [info exist MAX_ROUTING_LAYER] && ( $MAX_ROUTING_LAYER != "" ) } {
    set_ignored_layers -max_routing_layer [get_layers $MAX_ROUTING_LAYER]
    set_app_options -name route.common.global_max_layer_mode -value hard
}
if { [info exist MIN_ROUTING_LAYER] && ( $MIN_ROUTING_LAYER != "" ) } {
    set_ignored_layers -min_routing_layer [get_layers $MIN_ROUTING_LAYER]
    set_app_options -name route.common.global_min_layer_mode -value allow_pin_connection
}

report_ignored_layers -verbose

# Max Net Length
if { [info exist MAX_NET_LENGTH] && ( $MAX_NET_LENGTH != "" ) } {
    # Apply in place_opt and clock_opt
    # constraints maximum net length for opt of data path cells
    # Driver to fanout pin distance == net length
    # Soft constraint
    set_app_options -name opt.common.max_net_length -value $MAX_NET_LENGTH
}

#*******************************************************************************

#*******************************************************************************
#**                                STD Cells                                  **
#*******************************************************************************
# (Default) Flip first row is true, start first pg stripe starts VSS
# Flip first row is false, start first pg stripe starts VDD (Power net)
set side_length_a [expr $TILE_WIDTH * $W_SUPER_TILE_MUL * $W_SUPER_TILE_NUM]; # Rectangular Width
set side_length_b [expr $TILE_HEIGHT * $H_SUPER_TILE_MUL * $H_SUPER_TILE_NUM]; # Rectangular Height



# set the shape and size of the core. It's customary to start with a "loose" geometry to get a sense 
# of how much area your design takes up. This can be done by method 2: specifying aspect ratio and targeted core_utilization
# of the design at the time of floorplanning (remember that you need space for clock buffers and hold-fix buffers etc).
# Once you know the approximate geometry, you can then set the core_width and core_height of your design with method 1.
# Qn: Where are all these geometric variables defined?

#==== Method 1 =================================================================================
initialize_floorplan    -control_type $FP_CTRL_TYPE \
                        -shape $FP_SHAPE \
                        -flip_first_row $FP_FLIP_FIRST_ROW \
                        -side_length [list $side_length_a $side_length_b] \
                        -core_offset $TILE_HEIGHT
#===============================================================================================

# ==== Method 2 =================================================================================
# initialize_floorplan    -control_type $FP_CTRL_TYPE \
#                         -shape $FP_SHAPE \
#                         -flip_first_row $FP_FLIP_FIRST_ROW \
#                         -core_utilization $CORE_UTIL_RATIO \
#                         -side_ratio [list 1 2] \
#                         -core_offset $TILE_HEIGHT
# ===============================================================================================
# Power straps are not created on the very top and bottom edges of the core, so to 
# prevent cells (especially filler) from being placed there, later to create LVS 
# errors, this is why we add the core offset which creates an empty area around our module

#You will find that many commands in this flow are set as a string variable, shown below, then evaluated using the "eval" function. This is because some commands don't allow for variables (eg. $side_length_a) 
#to be given as inputs to a command, so it is necessary to first declare a string with those variables, then evaluate.
