# Library setup
# ==========================================================================


# ==========================================================================
# Project design and directories
# ==========================================================================

set PROCESS "65GP"; # Unused by tech_node.tcl 
set TECH_LABEL "tcbn65gplus"

puts $PROCESS
# Logic libraries 
set TSMC_PATH "/tools/pdk/designkits/tsmc/tsmc65gp/tcbn65gplus_200a/TSMCHOME/digital"
set TARGETCELLLIB_PATH "$TSMC_PATH/Front_End/timing_power_noise/NLDM/tcbn65gplus_200a"
set MW_TECHFILE_PATH "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/techfiles"
set MW_REFERENCE_LIBS "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/cell_frame/tcbn65gplus"

# Technology files
set MW_TLUPLUS_PATH "$MW_TECHFILE_PATH/tluplus"
set MW_TECHFILE "tcbn65gplus.tf"
set MAX_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcbest_top2.tluplus"
set MIN_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcworst_top2.tluplus"
set TECH2ITF_MAP_FILE "star.map_9M"

# Reference libraries 
set SYNOPSYS_SYNTHETIC_LIB "dw_foundation.sldb"

set TARGET_LIBS [list \
   "tcbn65gplustc.db" \
   "tcbn65gplusbc.db" \
   "tcbn65gpluswc.db" \
]

set STD_CELL_LIB_NAME "tcbn65gplustc"
set SYMBOL_LIB "tcbn65gplustc.db"
# Worst case library
set LIB_WC_FILE   "tcbn65gpluswc.db"
set LIB_WC_NAME   "tcbn65gpluswc"
# Best case library
set LIB_BC_FILE   "tcbn65gplusbc.db"
set LIB_BC_NAME   "tcbn65gplusbc"
# Typical case library
set LIB_TC_FILE   "tcbn65gplustc.db"
set LIB_TC_NAME   "tcbn65gplustc"
# Operating conditions
set LIB_WC_OPCON  "NC1D0COM"
set LIB_BC_OPCON  "BC1D1COM"

set ANTENNA_RULES_FILE "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/clf/antennaRule_n65_9lm.tcl"
