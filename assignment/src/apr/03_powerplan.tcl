# 3. Powerplan
set step      "03_powerplan"

set_scenario_status [all_scenarios] -active false
set_scenario_status func1_wc -active true


# Create PG ports (pins) & nets
foreach _power_net $POWER_NET {
    create_net -power $_power_net
    create_port $_power_net -direction inout -port_type power
    connect_net -net [get_nets $_power_net] [get_ports $_power_net]
}

foreach _ground_net $GROUND_NET {
    create_net -ground $_ground_net
    create_port $_ground_net -direction inout -port_type ground
    connect_net -net [get_nets $_ground_net] [get_ports $_ground_net]
}


# Power/Ground network synthesis
if { $PGR } {
    # Generate PG ring
    create_pg_ring_pattern pg_ring \
        -horizontal_layer $PGR_HLAYER -horizontal_width $PGR_WIDTH -horizontal_spacing $PGR_SPACE \
        -vertical_layer $PGR_VLAYER -vertical_width $PGR_WIDTH -vertical_spacing $PGR_SPACE \
        -corner_bridge true

    set pgr_nets [concat $GROUND_NET $POWER_NET]

    set offset   [list]
    for {set i 0} {$i < [llength $pgr_nets]} {incr i} {
        set offset [concat $PGR_CLEARANCE]
    }
    set_pg_strategy pg_ring -core -pattern { {name: pg_ring } {nets: $pgr_nets} {offset: {$offset} } }
    compile_pg -strategies pg_ring
}

#core
create_pg_region CORE -core
create_pg_region CORE_EXPAND -core -expand_by_edge [list [list [list side: 2] [list offset: $M1_RAIL_WIDTH]] [list [list side: 4] [list offset: $M1_RAIL_WIDTH]]]

# Set pg route options
# set_app_options -name plan.pgroute.treat_fat_blockage_as_fat_metal -value true
# set_app_options -name plan.pgroute.high_capacity_mode -value true
# set_app_options -name plan.pgroute.honor_std_cell_drc -value true
# set_app_options -name plan.pgroute.via_site_threshold -value 1.0 ; # Only allow vias within full intersection of adjacent layers.
# report_app_options plan.pgroute.*


# Generate PG Mesh
# This essentially creates .tcl file that defines the powergrid using an input .txt file. Very useful because it is easy to make mistakes defining grid manually,
# so all that is necessary is providing a text file of the correct format. Take a look at user_pg_conf.txt and see how it maps to gen_pg_mesh.tcl
generate_pg_script -input ./user_pg_conf.txt -output ./gen_pg_mesh.tcl -run
#generate_pg_script automatically sources the output tcl file
#source ../src/apr/gen_pg_mesh.tcl

# M1-M2 STD Conn stapling vias
create_pg_stapling_vias -nets "${POWER_NET} ${GROUND_NET}" \
-from_layer M1 -to_layer M2 \
-from_shapes [get_shapes -filter "layer_name == M1"] \
-to_shapes [get_shapes -filter "layer_name == M2"] \
-tag PG_M1_M2_RAIL_STAPLE_VIA

remove_pg_regions -all
remove_pg_strategies -all
remove_pg_patterns -all
remove_pg_strategy_via_rules -all
remove_pg_via_master_rules -all

# Connect pg net to std cells
connect_pg_net -automatic

puts "** INFO: check pg vias / DRC"
check_pg_missing_vias
check_pg_drc


# Set std cell purpose
# exclude cts and hold for all std cells
set_lib_cell_purpose -exclude cts [get_lib_cells */*]
set_lib_cell_purpose -exclude hold [get_lib_cells */*]
print_comment_line

# CTS Reference cells
set_lib_cell_purpose -include none [get_lib_cells $CTS_REF_CELLS]
set_lib_cell_purpose -include cts  [get_lib_cells $CTS_REF_CELLS]

print_comment_line
puts "** INFO: Setting lib_cell_purpose to include only cts on"
[enum_objects $CTS_REF_CELLS]

# Delay (Hold Fix)
set_lib_cell_purpose -include none [get_lib_cells $DEL_REF_CELLS]
set_lib_cell_purpose -include hold [get_lib_cells $DEL_REF_CELLS]

print_comment_line
puts "** INFO: Setting lib_cell_purpose to include only hold on"

[enum_objects $DEL_REF_CELLS]
print_comment_line

# Include Tie-cell to optimization purpose
set_lib_cell_purpose -include optimization [get_lib_cells $TIE_REF_CELL]

# Coarse placement of std cells (and macros)
create_placement -floorplan
legalize_placement

puts "** INFO: check pg connection"
check_pg_connectivity

# Pin placement

# We have provided pin placement constraints for you, ignored in tutorial/assignment
#source pin_placement.tcl

set_block_pin_constraints -allowed_layers {M2 M3 M4} -self -hard_constraints {layer location} \
-corner_keepout_num_tracks 5 -width 0.1 -length 0.6
report_block_pin_constraints -self

place_pins -self
