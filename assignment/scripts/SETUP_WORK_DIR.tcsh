#!/bin/tcsh

set usage="Usage: $0 {foo|bar}"

if ( $#argv != 1 ) then
  echo 'Default PDK is TSMC65_GP'
  set pdk_dir = $PDKS_CADENCE/tsmc65gp
else
  switch ($argv[1])
  case 'TSMC_65LP':
    set pdk_dir = $PDKS_CADENCE/tsmc65ic61
    breaksw
  case 'TSMC_65MSRF':
    set pdk_dir = $PDKS_CADENCE/tsmc65msrf 
    breaksw
  default:
    set pdk_dir = $PDKS_CADENCE/tsmc65gp
    breaksw
  endsw
endif

mkdir -p src sim syn doc 
mkdir -p src/Makefiles src/syn src/verilog
mkdir -p sim/behav sim/syn 

echo $pdk_dir

echo "Created basic work directory for ECE4804::tutorial_2. Don't forget to prepare a git repository for the src directory!"
