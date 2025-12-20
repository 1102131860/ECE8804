# 0. Read library

# This process is wildly simplified due to the pre-creation of library ".ndm" files. Unlike synthesis, where the input .db, .lib files can be specified,
# ICC2 requires a precompiled "New Data Model (.ndm)" file - this is essentially a compressed version of everything you need to use from your library,
# including FRAM views, .db, etc. To see how this library compilation is done, take a look at library_manager.tcl. In ICC2, however, all we need to do 
# is call this precompiled ndm by setting it as a reference lib.

# Lib setting
set search_path "./ $search_path \
                    $synopsys_root/libraries/syn \
                    $MW_TECHFILE_PATH \
                    $MW_TLUPLUS_PATH \
                    ${NDM_DIR}/${PROCESS}"

# Default reference libs - ndm was already created and initialized using library_manager.tcl, so all we need to do here is import it
set REFERENCE_LIBS [list ${TECH_LABEL}.ndm ${TECH_LABEL}_physical_only.ndm]


set _ndm ${NDM_DIR}/${TOP_MODULE}

set is_ndm_exist [file exist $_ndm]

if { $is_ndm_exist } {
    open_lib $_ndm
    remove_block ${TOP_MODULE}:${TOP_MODULE}.design
} else {
    create_lib $_ndm -ref_libs $REFERENCE_LIBS
}


create_block ${TOP_MODULE}
current_block ${TOP_MODULE}
