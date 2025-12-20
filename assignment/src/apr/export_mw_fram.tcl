# |=======================================================================
# |  
# | Evren Basaran
# | evren.basaran@gatech.edu
# |                                                                      
# |=======================================================================
#
# To be able to import FRAM views, LM requires either an exported *.tar.gz from ICC, a pre-made *.ndm, or 
# LEF, GDS,II or OASIS files. TSMC65 pdk does not automatically any of these, thus the ICC
# tool must be run to export the FRAM views. 

# begin timing
set start_time [clock seconds]; set cpu_start [cputime]; set dates [exec date];
puts "** INFO: START: $dates, CURRENT_WORK_DIR: [pwd]"

source -echo -verbose ./tech_node_config.tcl

# set core num
set_host_options -max_cores 8

# Check disk space
#set threshold
set lowLimit "95%"

set perc [exec df -k . | awk {{print $5}} | sed -n "2,14 p"]

#define condition
if {$perc > $lowLimit} {
    echo "\n CAUTION: Available Disk Space is at $perc , Your disk space is approaching full and is less than the default low limits set. Please ensure sufficient diskspace to run complete APR flow on the design.\n"
} else {
    echo "\n Available Disk Space is at $perc. Disk space is design dependant, continue to monitor the available space on your disk.\n"
}

export_icc2_frame -library $MW_REFERENCE_LIBS


# Elapsed Time
set end_time [clock seconds]; set cpu_end [cputime]; set dates [exec date];
set secs [expr ${end_time} - ${start_time}]
set days	[expr $secs / 86400]
set rest_secs	[expr $secs % 86400]
set hrs  	[expr $rest_secs / 3600]
set rest_secs [expr $rest_secs % 3600]
set mins 	[expr $rest_secs / 60]
set rest_secs [expr $rest_secs % 60]

echo "\n Elapsed time - "
if {$days > 0} {
    echo "$days days $hrs hours $mins mins $rest_secs secs"
} elseif {$hrs > 0} {
    echo "$hrs hours $mins mins $rest_secs secs"
} elseif {$mins > 0} {
    echo "$mins mins $rest_secs secs"
} else {
    echo "$rest_secs secs"
}

proc rdt_to_seconds {secs} {
    set h [expr {$secs/3600}]
    incr secs [expr {$h*-3600}]
    set m [expr {$secs/60}]
    set s [expr {$secs%60}]
    format "%02.2d:%02.2d:%02.2d" $h $m $s
}

echo "\n cpu running time (hh:mm:ss) - [rdt_to_seconds [expr ($cpu_end - $cpu_start)]]"
echo "\n memory : [mem] KB"

exit