# |=======================================================================
# |  
# | Evren Basaran
# | evren.basaran@gatech.edu
# |                                                                      
# |=======================================================================
# ICC2 is normally a two-step process.
#   1. Library Manager (this flow):
#       - Provide libraries from PDK, including: *.db files, which are binary encoded versions
#         of library files that contain cell timing, delay, parasitics;
#         FRAM views, which are abstracted versions of the layout so the tool knows
#         where the pins and metal blockages are; and most importantly, the Technology file (*.tf)
#         which provides the technology description like an available layers/vias 
#         list including visible info (color, pattern), design rules of
#         width, spacing, and pitch, unit length, voltage, current, power, precision and
#         unit resistance and capacitance of layers, maximum current density of vias, etc.
#         The library manager then takes these input files and rules, and compiles them 
#         into a New Data Model (*.ndm) file which is what the ICC2 tool expects as an input
#   2. ICC2:
#       - Once your libraries are compiled into a *.ndm, the ICC2 tool can be run. See apr.tcl for 
#         information about the ICC2 flow
#   Notes:
#       - TSMC65GP does not provide the required files to generate the library .ndm. In order to 
#         generate a .ndm for TSMC65GP, first run export_mw_fram.tcl in ICC, then run this script in
#         library manager

# begin timing
set start_time [clock seconds]; set cpu_start [cputime]; set dates [exec date];
puts "** INFO: START: $dates, CURRENT_WORK_DIR: [pwd]"

source ../src/apr/func/common_func.tcl

source -echo -verbose ./tech_node_config.tcl

set NDM_DIR                 "./ndm"

# set core num
set_host_options -max_cores 8

check_disk_space

set search_path  [list \
      "$TARGETCELLLIB_PATH" \
      "$MW_TECHFILE_PATH" \
      "$MW_REFERENCE_LIBS" \
      "$synopsys_root/libraries/syn" \
      "./db" \
      "./" \
   ]

# Reset ndm dir
set _ndm ${NDM_DIR}/${PROCESS}
if {[file exist $_ndm]} {
    file delete -force -- $_ndm
}
file mkdir $_ndm

# Technology file (*.tf) provide the technology description like
# Available layers/vias list including visible info (color, pattern), design rules of
# width, spacing, and pitch, unit length, voltage, current, power, precision and
# unit resistance and capacitance of layers, maximum current density of vias, etc

# ****** create frame only NDM ******
create_workspace ${TECH_LABEL}_frame_only -technology icc2_frame/data/TF/$MW_TECHFILE -flow frame
source icc2_frame/data/TCL/${TECH_LABEL}_update_technology.tcl
import_icc_fram icc2_frame/data/LEF/${TECH_LABEL}.tar.gz

#check_workspace
commit_workspace -output $_ndm/${TECH_LABEL}_frame_only.ndm

# ****** create normal NDM ******
create_workspace ${TECH_LABEL} -flow normal
read_ndm -view frame $_ndm/${TECH_LABEL}_frame_only.ndm

read_db -process_label SS125 $LIB_WC_FILE
read_db -process_label TT25 $LIB_TC_FILE
read_db -process_label FF0 $LIB_BC_FILE

#read_dbd_parasitic_tech -tlup $MW_TLUPLUS_PATH/$MAX_TLUPLUS_FILE 
#read_parasitic_tech -tlup $MW_TLUPLUS_PATH/$MIN_TLUPLUS_FILE 

check_workspace
commit_workspace -output $_ndm/${TECH_LABEL}.ndm
remove_workspace

# ****** create Physical only NDM ******
create_workspace ${TECH_LABEL}_physical_only -flow physical_only
read_ndm -view frame $_ndm/${TECH_LABEL}_frame_only.ndm

read_db ${TECH_LABEL}tc.db; # read TT lib and extract physical only cells

check_workspace
commit_workspace -output $_ndm/${TECH_LABEL}_physical_only.ndm
remove_workspace

# Elapsed Time
set end_time [clock seconds]; set cpu_end [cputime]; set dates [exec date];
puts "** INFO: elapsed time - [get_elapsed_time_string ${start_time}]"
puts "** INFO: cpu running time (hh:mm:ss) - [rdt_to_seconds [expr ($cpu_end - $cpu_start)]]"
puts "** INFO: memory : [mem] KB"

exit
