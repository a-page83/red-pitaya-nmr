`timescale 1 ns / 1 ps

// This block is combine the two 14-bit inputs and send them to the DAC in a single axis stream data 32 bits wide. 

module square_wave_generator #
(
  parameter integer AXIS_DATA_WIDTH_OUT = 14
)
(
    // System signals
    input  wire     aclk,
    input  wire     genclk,
    input  wire     enable,

    // Master side
    input  wire                              m_axis_tready,
    output wire [AXIS_DATA_WIDTH_OUT-1:0]    m_axis_tdata,
    output wire                              m_axis_tvalid
);
    reg [AXIS_DATA_WIDTH_OUT-1:0] data_reg;
    
    always @(posedge aclk)
    begin
        case (genclk)
            1'b0: data_reg <= 14'b0001_0000_0000_00;
            1'b1: data_reg <= 14'b1111_0000_0000_00;
            default: data_reg <=  14'b0000_0000_0000_00;
        endcase
    end


    assign m_axis_tdata = data_reg;
    assign m_axis_tvalid = enable;

endmodule