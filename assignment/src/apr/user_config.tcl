# Parameters

#*****************************************************************************
#**                     Filenames + Directory Paths                         **
#*****************************************************************************
set REPORTS_DIR             "./reports"
set RESULTS_DIR             "./results"
set NDM_DIR                 "./ndm"

set RTL_SRC_DIR             "../src/verilog"
set GATE_SRC_DIR            "../syn"

set TOP_MODULE              "gcd"

set GATE_NETLIST            "${GATE_SRC_DIR}/results/${TOP_MODULE}.syn.v"

#*****************************************************************************
#**                     Clock                                               **
#*****************************************************************************
set APR_CLOCK_PERIOD        2.5   ; # 400MHz

#*****************************************************************************
#**                     Floorplan + Routing layers                          **
#*****************************************************************************
set MAX_ROUTING_LAYER  "M7"
set MIN_ROUTING_LAYER  "M1"

set CLK_MAX_ROUTING_LAYER "M7"
set CLK_MIN_ROUTING_LAYER "M1"

set FP_CTRL_TYPE           "core" ; # core | die
set FP_SHAPE               "R"    ; # R | L | T | U TODO: only R shape supports
set FP_FLIP_FIRST_ROW      true   ; # true | false (default, flip_first_row is true)
set FP_SIZE_ABSOLUTE       true   ; # true (using absolute size) | false (use super tile)

set M1_RAIL_WIDTH 0.33

set TILE_WIDTH             1.8 ; # (um)
set TILE_HEIGHT            1.8 ; # (um) Cell height

set W_SUPER_TILE_MUL       8
set H_SUPER_TILE_MUL       8

set W_SUPER_TILE_NUM       2    ; # 8
set H_SUPER_TILE_NUM       3    ; # 15

set CORE_UTIL_RATIO        0.6

set ITER                   40 ; #Number of routing iterations to perform; default is 40. The more you add, the better results you will see, but the longer it will take

#*****************************************************************************
#**                     Power                                               **
#*****************************************************************************
# PGR refers to power-ground ring. There are two ways to determine how power is delivered to your module:
#  1. A ring can be instantiated around the module, and all external power will connect to this ring which then delivers power to the module
#  2. Power can be connected from above, with vias. This is a more efficient approach but may require more work during integrations
# We will be using approach 2, so leave this setting false

set PGR                     false ; # true | false

## POWER_RING_CHANNEL_WIDTH: combined width of the rings, clearances, and spacing
## POWER_RING_CLEARANCE: spacing between adjacent power rings, and between the core and innermost ring edge
## POWER_RING_SPACE: space between the IO pads and outermost ring edge
## POWER_RING_WIDTH: width of a core power ring
## RING_HLAYER: horizontal ring metal
## RING_VLAYER: vertical ring metal

set PGR_CLEARANCE          "2.0"; # spacing between adjacent power rings, and between the core and innermost ring edge
set PGR_SPACE              "1.2"; # space between I/O pads and outermost ring edge
set PGR_WIDTH              "3.0"; # metal width of a core power ring

set PGR_HLAYER             "M8"
set PGR_VLAYER             "M7"

set POWER_NET              [list "VDD"] ;# This is real power net name.
set GROUND_NET             [list "VSS"] ;# This is real ground net name.

#*****************************************************************************
#**                     Message Info                                        **
#*****************************************************************************
set_message_info -id ATTR-12 -limit 1;
set_message_info -id ATTR-13 -limit 1;
set_message_info -id ABS-214 -limit 1; # Pin has no timing pahts. No budget created
set_message_info -id NDMUI-010 -limit 1; # The '%s' command cannot be used on library cell '%s' which has no logical model
set_message_info -id NDMUI-461 -limit 1; # The application option <%s> is for R&D debug and can't be used outside Synopsys
set_message_info -id CSTR-021 -limit 1;

#*****************************************************************************
#**                     Derates                                             **
#*****************************************************************************
# Set setup/hold derating factors
# Tells the tool how much additional "margin" to allocate for process variation, etc.
# Derate constitutes an important tool in adding pessimism in your design to guard against foundry/spice-model mismatch or process variation.
set DERATE_EARLY           "0.8"
set DERATE_LATE            "1.1"

