# Common functions defined that are used often

proc check_disk_space {} {
    set lowLimit "95%"

    set perc [exec df -k . | awk {{print $5}} | sed -n "2,14 p"]

    #define condition
    if {$perc > $lowLimit} {
        echo "\n CAUTION: Available Disk Space is at $perc , Your disk space is approaching full and is less than the default low limits set. Please ensure sufficient diskspace to run complete APR flow on the design.\n"
    } else {
        echo "\n Available Disk Space is at $perc. Disk space is design dependant, continue to monitor the available space on your disk.\n"
    }  
}

proc rdt_to_seconds {secs} {
    set h [expr {$secs/3600}]
    incr secs [expr {$h*-3600}]
    set m [expr {$secs/60}]
    set s [expr {$secs%60}]
    format "%02.2d:%02.2d:%02.2d" $h $m $s
}

proc get_elapsed_time_string {start_time {end_time 0.0}} {
    if {$end_time == 0.0} {
        set end_time [clock seconds]
    }

    if { $end_time < $start_time} {
        error_msg "start time is later than end time"
        return
    }

    set secs [expr ${end_time} - ${start_time}]
    set days	[expr $secs / 86400]
    set rest_secs	[expr $secs % 86400]
    set hrs  	[expr $rest_secs / 3600]
    set rest_secs [expr $rest_secs % 3600]
    set mins 	[expr $rest_secs / 60]
    set rest_secs [expr $rest_secs % 60]

    if {$days > 0} {
        return "$days days $hrs hours $mins mins $rest_secs secs"
    } elseif {$hrs > 0} {
        return "$hrs hours $mins mins $rest_secs secs"
    } elseif {$mins > 0} {
        return "$mins mins $rest_secs secs"
    } else {
        return "$rest_secs secs"
    }
}


proc enum_objects {args} {
    set filename 	"stdout"

    parse_proc_arguments -args $args results

    foreach argname [array names results] {
        switch -glob -- $argname {
            -output {
	            set filename $results($argname)
            }
        }
    }
    set collection	$results(collection)

    if { [sizeof_collection $collection] == 0 } {
        return;
    }

    if { ${filename} == "stdout" } {
        set fp stdout
    } else {
        set fp [open $filename "w"]
    }

    foreach_in_collection obj $collection {
        set objname [get_attribute -quiet $obj full_name]
        if {$objname == ""} {
            set objname [get_attribute -quiet $obj name]
        }
        if {$filename == "stdout"} {
            echo $objname
        } else {
            puts $fp $objname
        }
    }

    if { ${filename} != "stdout" } {
        close $fp
    }
}
define_proc_attributes enum_objects \
    -info "enumerate collection objects" \
    -define_args {
      {collection "collection to enumerate" "collection" string required}
      {"-output" "output file" "<filename>" string optional}
	}

proc print_comment_line {} {
    puts "################################################################################"
}