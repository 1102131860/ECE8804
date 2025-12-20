# |=======================================================================
# |  
# | Created by         :PSyLab                                           
# | Filename           :apr.tcl                                  
# | Author             :evren(Ga Tech.)                              
# | Created On         :2024-08-14                  
# | Last Modified      :                                                 
# | Update Count       :2024-09-23                 
# | Description        :                                                                                                     
# |                                                                      
# |=======================================================================
# This script is the "master-script" which sources all the other .tcl files.
# The construction flow is in-line with the material covered in the lecture:
# Data/Library, synthesis netlist read-in:: floorplanning :: placement :: clock_tree
# routing :: chip_finishing :: data_preparation
# This spar script is what you will use to *** tape out your final design ****
# Some instructions:
# 1. Please go through it carefully, step by step. Hopefully for some of you, your experiences
#    with tutorial 1 and tutorial 2 will have convinced you of the value in doing this
# 2. Treat 03_powerplan.tcl as a black box. There's a lot of detail and other files hiding underneath that do
#    not offer sufficient value to you guys. Your time (IMO) is better spent focusing on other more 
#    important aspects of the design process.
# 3. This flow is not a "2-level" flow. This scripts will call other .tcl files, which will call
#    other .py, .tcl files. The only exception is the pinPlacement.txt file which is how you specify 
#    pin locations in your design.
# 4. Unlike synthesis, APR does not manually call files from the library- instead, they are precompiled 
#    into an Synopsis .ndm (new data model) which is essentially a compressed version of all necessary files.
#    If you do not have access to the .ndm (to which a link is created in the Makefile), you need to run
#    library_manager.tcl

# begin timing
set start_time [clock seconds]; set cpu_start [cputime]; set dates [exec date];
puts "** INFO: START: $dates, CURRENT_WORK_DIR: [pwd]"

# Import user-defined functions that are used commonly
source ./common_func.tcl

# This file defines the file paths to the libraries we use in APR 
# Most of these (but not all) are unused in apr.tcl - they are used to generate the .ndm,
# which is essentially a compressed version of your library in a common synopsys format,
# using a different tool (library manager). We provide the .ndm to you as it only needs to be generated once.
# The details of the .ndm generation can be found in library_manager.tcl
source ./tech_node_config.tcl  -echo -verbose

# user configurations
source ./user_config.tcl -echo -verbose 

# set core num
set_host_options -max_cores 8
check_disk_space

# 0. Read library
source ./00_read_lib.tcl -echo -verbose


# 1. Read design
source ./01_read_design.tcl -echo -verbose


# 2. Floorplan
source ./02_floorplan.tcl -echo -verbose
save_block -as ${TOP_MODULE}_floorplan


# 3. Powerplan
source ./03_powerplan.tcl -echo -verbose
save_block -as ${TOP_MODULE}_powerplan


# 4. place_opt
source ./04_place_opt.tcl -echo -verbose
save_block -as ${TOP_MODULE}_place_opt


# 5. clock_opt
source ./05_clock_opt.tcl -echo -verbose
save_block -as ${TOP_MODULE}_clock_opt


# 6. route
source ./06_route.tcl -echo -verbose
save_block -as ${TOP_MODULE}_route


# 7. finish
source ./07_chip_finish.tcl -echo -verbose
save_block -as ${TOP_MODULE}_finish


# 8. Report
source ./08_report.tcl -echo -verbose


# 9. Outputs
source ./09_outputs.tcl -echo -verbose
save_block -as ${TOP_MODULE}
save_lib -as ${TOP_MODULE} ${TOP_MODULE}


# Shows the full block view of the chip along with all DRC errors
# Comment these lines if running flow on VScode or SSH (w/ no X Forwarding) - does not support gui.
start_gui
gui_error_browser -show
gui_open_error_data [get_drc_error_data -all]

# Runtime and message summary
print_message_info

# Elapsed Time
set end_time [clock seconds]; set cpu_end [cputime]; set dates [exec date];
puts "** INFO: elapsed time - [get_elapsed_time_string ${start_time}]"
puts "** INFO: cpu running time (hh:mm:ss) - [rdt_to_seconds [expr ($cpu_end - $cpu_start)]]"
puts "** INFO: memory : [mem] KB"

# Uncomment this once you have gone over each line of the flow
#exit