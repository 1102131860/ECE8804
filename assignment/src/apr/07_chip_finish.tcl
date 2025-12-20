# 7. finish
set step      "07_chip_finish"

# Final Check for DRC/LVS
# DRC
foreach_in_collection _data [get_drc_error_data -all] {
    open_drc_error_data $_data
    report_drc_errors -error_data $_data
}

#LVS
check_lvs -max_errors 2000

# insert extra cell (STD Filler, decap)
check_legality

# DCAP
create_stdcell_fillers -lib_cells $DECAP_REF_CELLS -prefix DCAP_CELL

# Connect Power & Grounding
connect_pg_net -automatic
check_pg_connectivity

remove_stdcell_fillers_with_violation

# Filler
create_stdcell_fillers -lib_cells $FILL_REF_CELLS -prefix FILL_CELL

# Connect Power & Grounding
connect_pg_net -automatic
check_pg_connectivity

# runnig extraction and upating the timing
update_timing -full