`timescale 1 ns / 1 ps
//This module makes a heart beat when the app nmr is launched 
//(bitfile sent on the fpga)

module led_beat_blinker (
    input       clk,
    input       rst_n,
    output      Led
);

  reg [28:0] counter;

  // Compteur avec reset asynchrone et enable
  always @(posedge clk or negedge rst_n) 
  begin
    if (!rst_n)
      counter <= 9'd0;
    else
      counter <= counter + 1'b1;
  end
    
    assign Led = (counter == 28'd31250000 || counter == 28'd62500000 || counter == 28'd93750000) ? 1'b1 : 1'b0;
endmodule

