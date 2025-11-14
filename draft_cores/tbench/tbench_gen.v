`timescale 1 ns / 1 ps

module gen_tb;

  reg clk;
  wire Led;

  wire [13:0]Out_1;
  reg [15:0]cfg_amplitude;
  reg [31:0]cfg_data_0;
  reg en_gen;

  wire [13:0]m_axis_0_tdata;

  // Instanciation du module à tester
  gen_dut gen_dut_i
       (.Out_1(Out_1),
        .cfg_amplitude(cfg_amplitude),
        .cfg_data_0(cfg_data_0),
        .clk_125MHz(clk),
        .en_gen(en_gen),
        .Out_axis_zeroer(m_axis_0_tdata));

  
  // Génération de l'horloge (période 10 ns)
  initial begin
    clk = 0;
    forever #4 clk = ~clk;
  end

  // Séquence de test
  initial begin
    $display("=== DÉBUT TEST Led_Blinker ===");
    
    // Valeur de départ : reset actif (rst=0)
    cfg_data_0 = 32'd171798691;
    cfg_amplitude = 16'd1024;
    en_gen = 1'b0;

    #100;
    en_gen = 1'b1;

    #100
    en_gen = 1'b0;
    cfg_data_0 = 32'd85899345;
    cfg_amplitude = 16'd500;

    #100
    en_gen = 1'b1;
    
    #200

    $display("=== FIN DU TEST ===");
    $stop;
  end

endmodule