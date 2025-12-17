# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
} {
  S_AXIS /adc_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /fsm_nmr_0/rst_writer_o
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 32
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE true
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M00_AXIS
  aclk /pll_0/clk_out1
  aresetn /fsm_nmr_0/rst_writer_o
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 32
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE true
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M01_AXIS
  aclk /pll_0/clk_out1
  aresetn /fsm_nmr_0/rst_writer_o
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /fsm_nmr_0/rst_writer_o
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer pktzr_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
  CONTINUOUS FALSE
  ALWAYS_READY TRUE
} {
  S_AXIS comb_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /fsm_nmr_0/rst_pck_o
  cfg_data /fsm_nmr_0/nb_of_sample_o
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1 {
  CONST_WIDTH 18
  CONST_VAL 262143
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 18
  AXI_ID_WIDTH 3
  AXIS_TDATA_WIDTH 32
  FIFO_WRITE_DEPTH 1024
} {
  S_AXIS pktzr_0/M_AXIS
  aclk /pll_0/clk_out1
  min_addr /fsm_nmr_0/size_o
  cfg_data /fsm_nmr_0/nb_of_sample_o
  aresetn /fsm_nmr_0/rst_writer_o
}
