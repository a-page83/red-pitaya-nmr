`timescale 1 ns / 1 ps

module tb_fsm_read_memv2();

    // Testbench signals
    reg clk;
    reg [192:0] cfg;
    
    
    wire [31:0] sts;
    wire [6:0] Leds;
    wire rst_writer;
    wire rst_pck;
    wire rst_f;
    wire [31:0] size;
    wire [31:0] nb_of_sample;
    wire [15:0] cfg_amplitude;
    wire [31:0] cfg_freq;
    wire en_gen;
    
    // Clock generation (100 MHz = 10ns period)
    initial begin
        clk = 0;
        forever #4 clk = ~clk;
    end
    
    // Instantiate the DUT (Device Under Test)
    fsm_read_mem dut (
        .clk(clk),
        .cfg(cfg),
        .sts(sts),
        .Leds(Leds),
        .rst_writer(rst_writer),
        .rst_pck(rst_pck),
        .rst_f(rst_f),
        .size(size),
        .nb_of_sample(nb_of_sample),
        .cfg_amplitude(cfg_amplitude),
        .cfg_freq(cfg_freq),
        .en_gen(en_gen)
    );

  // Séquence de test
initial begin
    $display("=== DÉBUT TEST FSM ===");
    
    cfg             = 96'h0;                
    cfg[31:16]      = 16'd1024;             //cfg_amplitude      
    cfg[63:32]      = 32'd1025;             //size_reg
    cfg[95:64]      = 32'd1026;             //nb_of_sample_reg
    cfg[127:96]     = 32'd1027;             //cfg_freq     
    cfg[159:128]    = 32'hc;                //cfg excitation time
    cfg[192:160]    = 32'hc;                //cfg acquisition time


    #100
    
    cfg[0]  = 1'b1; //reset disabled
    #100
    
    cfg[1]  = 1'b1; //enable fsm
    #10000
    
    
    $display("=== FIN DU TEST ===");
  end
endmodule