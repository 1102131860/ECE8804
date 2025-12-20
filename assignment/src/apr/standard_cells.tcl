#******************************************************************************
#**           Set decap cells, STD Fillers and IO Fillers                    **
#******************************************************************************
# All ECO (engineering change order) cell prefixes "G" (means Gate array)
# ECO is an incremental change to a complete or nearly complete designs - signoff phase

# Decap cells

# OD18DCAP (?) (guess using diffusion cap)
# Order is matter - Tool places cells in priority according to the list order
set DECAP_REF_CELLS [list ]


set ADD_DECAP_REF_CELLS [sort_collection -descending \
                        [get_lib_cells ${TECH_LABEL}/DCAP*] area]
set DECAP_REF_CELLS     [add_to_collection $DECAP_REF_CELLS $ADD_DECAP_REF_CELLS]


# Filler cells
# Filler cells contain dummy RX(diffusion) and PC(poly) patterns which make RX and PC
# No logical function, only for DRC - filling gaps (area containing no cells) left in the layout
# FILL1 - used when abutting level shifter cell with level shifter cell itself
set FILL_REF_CELLS [list ]

set ADD_FILL_REF_CELLS [sort_collection -descending \
                       [get_lib_cells -regexp ${TECH_LABEL}_physical_only/FILL\[0-9\]{1,2}] area]
set FILL_REF_CELLS     [add_to_collection $FILL_REF_CELLS $ADD_FILL_REF_CELLS]


#*****************************************************************************
#**                    Set well edge cell and tap cell                      **
#*****************************************************************************
# No tap cells in tsmc65

#*****************************************************************************
#**                         Set TIE cell                                    **
#*****************************************************************************

set TIEH_REF_CELL [list ]
set TIEL_REF_CELL [list ]
set TIE_REF_CELL  [list ]

#Cant find 
set ADD_TIEH_REF_CELLS [get_lib_cells ${TECH_LABEL}/TIEH]
set ADD_TIEL_REF_CELLS [get_lib_cells ${TECH_LABEL}/TIEL]
set ADD_TIE_REF_CELLS  [add_to_collection $ADD_TIEH_REF_CELLS $ADD_TIEL_REF_CELLS]

set TIEH_REF_CELL      [add_to_collection $TIEH_REF_CELL $ADD_TIEH_REF_CELLS]
set TIEL_REF_CELL      [add_to_collection $TIEH_REF_CELL $ADD_TIEH_REF_CELLS]
set TIE_REF_CELL       [add_to_collection $TIE_REF_CELL $ADD_TIE_REF_CELLS]


#*****************************************************************************
#**                   Set Buffer tree cells for HFNS                        **
#*****************************************************************************

set HFNS_REF_CELLS [list ]


set ADD_HFNS_BUFS [remove_from_collection \
                  [get_lib_cells ${TECH_LABEL}/BUFFD*] \
                  [get_lib_cells -regexp ${TECH_LABEL}/BUFFD2\[0-9\]]]
set ADD_HFNS_INVS [remove_from_collection \
                  [get_lib_cells ${TECH_LABEL}/INVD*] \
                  [get_lib_cells -regexp ${TECH_LABEL}/INVD2\[0-9\]]]

set ADD_HFNS_REF_CELLS [add_to_collection $ADD_HFNS_BUFS $ADD_HFNS_INVS]
set HFNS_REF_CELLS     [add_to_collection $HFNS_REF_CELLS $ADD_HFNS_REF_CELLS]


#*****************************************************************************
#**                   Set CTS cells for Clock Tree Synthesis                **
#*****************************************************************************

set CTS_REF_CELLS [list ]

set ADD_CLK_BUFS  [remove_from_collection \
                  [get_lib_cells ${TECH_LABEL}/CKBD*] \
                  [get_lib_cells -regexp ${TECH_LABEL}/CKBD2\[0-9\]]]
set ADD_CLK_INVS  [remove_from_collection \
                  [get_lib_cells ${TECH_LABEL}/CKND*] \
                  [get_lib_cells -regexp ${TECH_LABEL}/CKND2\[0-9\]]]

set ADD_CLK_POS_GATE  [remove_from_collection \
                      [get_lib_cells ${TECH_LABEL}/CKLNQD*] \
                      [get_lib_cells -regexp ${TECH_LABEL}/CKLNQD2\[0-9\]]]
set ADD_CLK_NEG_GATE  [remove_from_collection \
                      [get_lib_cells ${TECH_LABEL}/CKLHQD*] \
                      [get_lib_cells -regexp ${TECH_LABEL}/CKLHQD2\[0-9\]]]
set ADD_CLK_GATE      [add_to_collection $ADD_CLK_POS_GATE $ADD_CLK_NEG_GATE]

set ADD_CTS_REF_CELLS [add_to_collection $ADD_CLK_BUFS $ADD_CLK_INVS]
set ADD_CTS_REF_CELLS [add_to_collection $ADD_CTS_REF_CELLS $ADD_CLK_GATE]
set CTS_REF_CELLS     [add_to_collection $CTS_REF_CELLS $ADD_CTS_REF_CELLS]

#*****************************************************************************
#**                     Set DELAY cells for Hold Fix                        **
#*****************************************************************************

set DEL_REF_CELLS [list ]

set ADD_DEL_REF_CELLS [get_lib_cells ${TECH_LABEL}/DEL*]
set DEL_REF_CELLS [add_to_collection $DEL_REF_CELLS $ADD_DEL_REF_CELLS]

#End of std cell include