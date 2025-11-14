
## Create axis_constant
cell pavel-demin:user:axis_constant axis_constant_0 {

} {
    aclk pll_0/clk_out1
    M_AXIS dds_0/S_AXIS_CONFIG
}

# Create dds_compiler with phase configuration
cell xilinx.com:ip:dds_compiler dds_0 {
  DDS_CLOCK_RATE 125
  SPURIOUS_FREE_DYNAMIC_RANGE 20
  NOISE_SHAPING Taylor_Series_Corrected
  PHASE_INCREMENT Programmable
  AMPLITUDE_MODE Full_range
  FREQUENCY_RESOLUTION 0.4
  HAS_PHASE_OUT false
  OUTPUT_WIDTH 16
} {
  aclk pll_0/clk_out1
  m_axis_tdata mult_gen_0/A
}

# Create multiplication to modify the amplitude
# The B parameter goes from 0 to 1024 = 0V to 1V
cell xilinx.com:ip:mult_gen mult_gen_0 {
} {
    CLK pll_0/clk_out1
    P axis_zeroer_0/s_axis_tdata
}

# Create the zeroer : if s_axis_tvalid != 1 send 0 on the output.
cell pavel-demin:user:axis_zeroer axis_zeroer_0 {

} {
    aclk pll_0/clk_out1
    M_AXIS axis_concatener_0/S_AXIS_0
}

# Create the zeroer : if s_axis_tvalid != 1 send 0 on the output.
cell pavel-demin:user:axis_zeroer axis_zeroer_1 {

} {
    aclk pll_0/clk_out1
    M_AXIS axis_concatener_0/S_AXIS_1
}

#Create axis_concatener : send both on signal of 16 bits on a 32bits in the same time
cell page:user:axis_concatener axis_concatener_0 {

} {
    aclk pll_0/clk_out1
    M_AXIS /dac_0/S_AXIS
}
