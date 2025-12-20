# 9. Outputs
change_names -rules verilog -hierarchy

write_def -version 5.7 -include_tech_via_definitions -include_physical_status {all} results/${TOP_MODULE}.def

write_verilog -exclude {corner_cells filler_cells supply_statement \
              leaf_module_declarations unconnected_ports} \
              results/${TOP_MODULE}.apr.v

foreach_in_collection _scn [all_scenarios] {
    set scn_name [get_object_name $_scn]
    set corner [lindex [split $scn_name _] 1]
    write_sdf -corner $corner -significant_digits 4 results/${TOP_MODULE}.${corner}.sdf
    write_sdc -scenario $_scn -nosplit -output results/${TOP_MODULE}.${scn_name}.sdc
    write_parasitics -format spef -corner $corner -no_name_mapping -output results/${TOP_MODULE}.${corner}.spef
}

