`timescale 1 ns / 1 ps

// This block is combine the two 14-bit inputs and send them to the DAC in a single axis stream data 32 bits wide. 

module axis_concatener #
(
  parameter integer AXIS_TDATA_WIDTH_IN = 14
)
(
    // System signals
    input  wire                             aclk,

    // Slave side
    output wire                             s_axis_tready_0,
    input  wire [AXIS_TDATA_WIDTH_IN-1:0]                    s_axis_tdata_0,
    input  wire                             s_axis_tvalid_0,

    output wire                             s_axis_tready_1,
    input  wire [AXIS_TDATA_WIDTH_IN-1:0]                    s_axis_tdata_1,
    input  wire                             s_axis_tvalid_1,

    // Master side
    input  wire                             m_axis_tready,
    output wire [32-1:0]  m_axis_tdata,
    output wire                             m_axis_tvalid
);

    localparam PADDING_WIDTH = 16 - AXIS_TDATA_WIDTH_IN;
    
    reg [AXIS_TDATA_WIDTH_IN-1:0]  int_dat_0_reg;
    reg [AXIS_TDATA_WIDTH_IN-1:0]  int_dat_1_reg;
    
    reg         int_tvalid_0_reg;
    reg         int_tvalid_1_reg;
    
    always @(posedge aclk)
    begin

      int_dat_0_reg <= s_axis_tdata_0 ;
      int_dat_1_reg <= s_axis_tdata_1;

      int_tvalid_0_reg <= s_axis_tvalid_0;
      int_tvalid_1_reg <= s_axis_tvalid_1;

    end

    assign s_axis_tready_0 = m_axis_tready;
    assign s_axis_tready_1 = m_axis_tready;

    assign m_axis_tdata = {
      {PADDING_WIDTH{int_dat_1_reg[AXIS_TDATA_WIDTH_IN-1]}}, int_dat_1_reg,
      {PADDING_WIDTH{int_dat_0_reg[AXIS_TDATA_WIDTH_IN-1]}}, int_dat_0_reg
    };
    
    assign m_axis_tvalid = int_tvalid_0_reg && int_tvalid_1_reg;

endmodule
