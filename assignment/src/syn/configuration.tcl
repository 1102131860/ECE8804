#Baseline Synthesis script
#Visvesh S Sathe
#sathe@uw.edu

# set search path, target lib, link path.
# Specify the libraries, tluplus files, import ddc file.

#Note. Go through these lines below and search online for what they mean.
#L I N E     B Y     L I N E.
#Yes its boring, but you'll only have to do this once if you do it right.

# ==========================================================================
# DC RUNTIME OPTIONS
# ==========================================================================

# Multicore
set_host_options -max_cores 8 

set TOOL_NAME "DC"

# ==========================================================================
# LIBRARY CONFIG
# ==========================================================================

# ===== Design libraries =====
set DESIGN_MW_LIB_NAME "${TOOL_NAME}_lib"

# ===== Logic Libraries =====

# @@@@@@@@@@@@@@@@@@@@@@@ HERE AN THE ERROR! FIX THIS! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#This sets the path to a TSMC 3nm process, which is an error!
# Comment or Remove the line below
# set TSMC_PATH "/tools/pdk/designkits/tsmc/tsmc03ic61/03MSRFLP/SClib/tcbn03lp_220a"

# Uncomment the line below to set the path to point to 65nm, which is the correct process node!
set TSMC_PATH "/tools/pdk/designkits/tsmc/tsmc65gp/tcbn65gplus_200a/TSMCHOME/digital"

#There are a number of other errors in this script, all of similar format to this one (i.e. you wont have to add missing commands,
#but rather fix existing ones for a better understanding of how the script runs). See if you can find the other major error in this file.

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

set TARGETCELLLIB_PATH "$TSMC_PATH/Front_End/timing_power_noise/NLDM/tcbn65gplus_200a"

#The TYPICAL_LIB_FILE is not actually used. We've just defined it here for reference for you to 
#take a quick glance at. It contains timing and power information for each cell as a function of 
#different parameters (loading, slew-rate etc.)
set TYPICAL_LIB_FILE "$TSMC_PATH/Front_End/timing_power_noise/NLDM/tcbn65gplustc.lib"

#Comment on search path, which helps understand link_libraries and additional_search_paths below :)
#Search Path:This variable specifies directories that the tool searches for files specified without directory names. The search 
#includes looking for technology and symbol libraries, design files, and so on. The value of this variable is a list of 
#directory names and is usually set to a central library directory.

# Link Libraries: This variable specifies the list of design files and libraries used during linking. The link command looks 
# at the files and tries to resolve references in the order of the specified files. A "*" entry in the value of this variable 
# indicates that the link command is to search all the designs loaded in dc_shell while trying to resolve references.
# If file names do not include directory names, files are searched for in the directories in search_path. The default is 
# {"*" your_library.db}. Change your_library.db to reflect your library name.

# Additional search paths include TARGETCELLLIB_PATH for good measure. The include the 
#LM section of the back_end information which contains power and timing information for 
#the physical cell. Later if you build hierarchical modules, you will have produced .db 
#files for them, like you will for this design. Those files will go into a db subdirectory 
#in this level and you can reference them as I have below.
set ADDITIONAL_SEARCH_PATHS [list \
   "$TARGETCELLLIB_PATH" \
   "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/cell_frame/tcbn65gplus/LM/*" \
   "$synopsys_root/libraries/syn" \
   "./db" \
   "./" \
]

#Target libs are the libraries you use to map generic_lib cells and logical functions into cells. Standard cells are an example of this.
set TARGET_LIBS [list \
   "tcbn65gplustc.db" \
   "tcbn65gplusbc.db" \
   "tcbn65gpluswc.db" \
]

# ADDITIONAL_TARGET_LIBS are compiled .db files (obtained by compiling .lib files)
# for circuits that you'll use. These could be custom circuits like a ring oscillator (ro_ip) 
# or a memory module like RAM_*. This entry has been commented since you don't need it yet. 
# You'll use this later before tapeout :)
 # set ADDITIONAL_TARGET_LIBS [list \
 #   # "RAM_10B_256_AR1_LP_ss_1p08v_1p08v_125c.db" \
 #   # "ro_ip_with_converter_gp.db"
 # ]
set ADDITIONAL_TARGET_LIBS []

#The SYNOPSYS_SYNTHETIC_LIB contains the foundation library that has designware
#A listing of already optimized hardware components that are frequently used by 
#designers and that you may want to include in your design.
set STD_CELL_LIB_NAME "tcbn65gplustc"
set SYMBOL_LIB "tcbn65gplustc.db"
set SYNOPSYS_SYNTHETIC_LIB "dw_foundation.sldb"

# ===== Reference libraries =====
set MW_REFERENCE_LIBS "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/cell_frame/tcbn65gplus/"

# MW_ADDITIONAL_REFERENCE_LIBS will contain the FRAM VIEWS of designs you will instantiate as modules.
# commented to an empty list since you don't need this yet.
# set MW_ADDITIONAL_REFERENCE_LIBS [list \
#  "RAM_10B_256_AR1_LP" \
#  "ro_ip_with_converter_gp"
# ]
set MW_ADDITIONAL_REFERENCE_LIBS []

#Library to be used for worst case (wc) analysis. We don't use wc files, and rather stick to 
#tc (typical case). Best case remains the fast-case analysis at bc1d1. No good reason to use 
#typical for worst case other than that our academic application is concerned about modeling 
#typical operating conditions. We pick that condition to be reported for our worst-case operating 
#condition analysis later.

# Worst case library
set LIB_WC_FILE   "tcbn65gplustc.db"
set LIB_WC_NAME   "tcbn65gplustc"

# Best case library
set LIB_BC_FILE   "tcbn65gplusbc.db"
set LIB_BC_NAME   "tcbn65gplusbc"

#To understand this, have a look at $TYPICAL_LIB_FILE defined above.
#This variable is used to tell the tool which section of the lib to look at. 
#A lib could have information for multiple different conditions. Not just nominal-case at 1.0V..
# Operating conditions
set LIB_WC_OPCON  "NCCOM"
set LIB_BC_OPCON  "BCCOM"

# nand2 gate name for area size calculation
set NAND2_NAME    "ND2D1"

# ===== Technology files =====
# TLUPLUS files contain advanced parasitic information that's really used in APR and 
# potentially in more advanced synthesis flows. All of these files are about getting wiring and parasitic
# information to be used by the synthesis tool to estimate wiring.
set MW_TECHFILE_PATH "$TSMC_PATH/Back_End/milkyway/tcbn65gplus_200a/techfiles"
set MW_TLUPLUS_PATH "$MW_TECHFILE_PATH/tluplus"
set MW_TECHFILE "tsmcn65_9lmT2.tf"
# set MAX_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcbest_top2.tluplus"
# set MIN_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcworst_top2.tluplus"
set TECH2ITF_MAP_FILE "star.map_9M"
# The max_tluplus should use rcworst, and min_tluplus should use rcbest
# But the given tcl uses the opposite case, I'm not 100% sure whether this is a bug of not 
set MAX_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcworst_top2.tluplus"
set MIN_TLUPLUS_FILE "cln65g+_1p09m+alrdl_rcbest_top2.tluplus"

# ==========================================================================
# FUNCTIONAL CONFIG
# ==========================================================================
#Please change the design name below!
#Leave PROJECT_DIR alone. To understand why
#see where and how it's used in this directory
#(Hint: grep for it)
#Note: There is an error here. What is the name for our design? is it named "random"?
set DESIGN "gcd"
set PROJECT_DIR ".."

# Options that are used to direct the compiler. Look these up in the documentation.
# Reduce runtime
set DC_PREFER_RUNTIME 0

# Preserve design hierarchy. Very useful.
set DC_KEEP_HIER 0

# Register retiming. Look in synthesis for the compile_ultra attribute that allows for this.
set DC_REG_RETIME 0
set DC_REG_RETIME_XFORM "multiclass"

# Logic flattening. Avoid flatting the design in our case.
set DC_FLATTEN 0
set DC_FLATTEN_EFFORT "medium"

# Logic structuring
set DC_STRUCTURE 1
set DC_STRUCTURE_TIMING "true"
set DC_STRUCTURE_LOGIC  "true"

# Boundary_optimization wanted? Set 0 if you don't want the design to optimize around boundaries, and
# as a result create module boundaries that don't match your original verilog module boundaries.
set DC_BOUNDARY_OPTIMIZATION 0

# Sequential output inversion allowed?
set DC_SEQ_OUTPUT_INVERSION 0

# Exact map forces DC to map sequential cells to basic asynchronous or synchronous reset flops.
# The compiler will not try to fold in any combinational logic into more functionally advanced flops.
# For a difference of synch vs. asynch reset, wait for week 8 in the course. The hdlin variable
# setting makes sure that only sync/asynch flops are used
set DC_EXACT_MAP 0
set hdlin_ff_always_sync_set_reset true
# Do an additional incremental compile for better results
set DC_COMPILE_ADDITIONAL 1 
set DC_CLK_GATING 1 

# ==========================================================================
# RESULT GENERATION AND REPORTING
# ==========================================================================
set results "results"
set reports "reports"



# ==========================================================================
# DESIGN SPECIFICATIONS AND CONSTRAINTS
# ==========================================================================
# All of these constraints are time values, and thus the units are in ns. See if you can figure out where the units are specified.
# Dont bother with hold skew. It'll get fixed during apr. Good  to know why I have 2 skews here though...
# Gater setup is something you'll learing once we cover clock gating.  Think of it for now as a requirement
# that the input to a clock gater cell must show up a certain amount of time before the triggering clock transition. 
# TRANSITION_LIMITS are meant to limit the rise/fall time of any signal in the design.
# INPUT and OUTPUT delays are VERY IMPORTANT. Take the time to understand and internalize them well.
# INPUT_DELAY is the time AFTER the clock edge that the data arrives
# OUTPUT_DELAY is the time BEFORE the latching clock edge that data needs to arrive at the output. 
# Do all of these values make sense? You may need to come back to this section
# after viewing constraints.tcl

set SETUP_SKEW 0.5
set HOLD_SKEW 0.25
set GATER_SETUP 0.05
set GATER_HOLD 0.01
set CLK_TRANSITION_LIMIT 0.08
set SIGNAL_TRANSITION_LIMIT 0.08 
set INPUT_DELAY 0.15
set OUTPUT_DELAY 0.12
