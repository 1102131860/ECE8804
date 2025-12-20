##############################################################################
#                                                                            #
#                               READ DESIGN RTL                              #
#                                                                            #
##############################################################################

# Configuration setting already sourced in synthesis.tcl
#source configuration.tcl

# Define the location that you keep your verilog files to ease path definition
set BASE "$PROJECT_DIR/src/verilog"
set TOPLEVEL "$DESIGN"

# Set the verilog files that you would like to be read in
set RTL_SOURCE_FILES "\
$BASE/gcd_pkg.sv \
$BASE/gcd.sv \ 
"

set_svf ./$results/$TOPLEVEL.svf
define_design_lib WORK -path ./WORK

# The analyze command reads an HDL source file, checks for errors, and creates necessary 
# intermediate files for synthesis. See the user guide for more details on the analyze command,
# and to find out what the elaborate command does.
# Does everything look right in this section? What HDL did we use for our FSM? format options are vhdl, verilog, sverilog
# analyze -format VHDL $RTL_SOURCE_FILES
analyze -format sverilog $RTL_SOURCE_FILES
elaborate $TOPLEVEL


# Normally, we would link our design using the "link" command. However, it is commented out here.
# Is it necessary for us to uncomment it in order to run synthesis? Why or why not?
link
current_design $TOPLEVEL
