set ::env(DESIGN_NAME) "aes_top"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10.0"
set ::env(FP_CORE_UTIL) 45
set ::env(PL_TARGET_DENSITY) 0.5
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]
set ::env(RUN_SPEF_EXTRACTION) 1
set ::env(RUN_POST_GDS_STA) 1
set ::env(QUIT_ON_LINTER_ERRORS) 0
set ::env(PNR_SDC_FILE) "$::env(DESIGN_DIR)/src/aes_top.sdc"
set ::env(SIGNOFF_SDC_FILE) "$::env(DESIGN_DIR)/src/aes_top.sdc"
