`timescale 1 ns / 1 ps

module fsm_nmr_acquisition
(
    input               clk,
    input      [192:0]  cfg,
    input               rst_n,
    // Control of the ACQ
    output reg          rst_writer_o,
    output reg          rst_pck_o,
    output reg          rst_f_o,
    output [31:0]       size_o,
    output [31:0]       nb_of_sample_o,
    // Control of the GEN
    output reg  [15:0]  cfg_amplitude_o,
    output reg  [31:0]  cfg_freq_o,       
    output reg          en_gen_o,        

    // Status outputs
    output reg [31:0]   sts, 
    output reg [5:0]    Leds 
);

    // Découpage propre du vecteur de config
    wire        soft_rst_n      = cfg[0];
    wire        start_cfg       = cfg[1]; 
    wire [15:0] cfg_amp_in      = cfg[31:16];
    wire [31:0] cfg_size_in     = cfg[63:32];
    wire [31:0] cfg_nb_smpl_in  = cfg[95:64];
    wire [31:0] cfg_freq_in     = cfg[127:96];
    wire [31:0] cfg_ex_time_in  = cfg[160:128];
    wire [31:0] cfg_acq_time_in = cfg[192:160];
    wire        global_reset_n;


    // State definition - consistent encoding
    localparam [2:0] IDLE   = 3'b000;
    localparam [2:0] SETUP  = 3'b001;
    localparam [2:0] GEN    = 3'b010;
    localparam [2:0] ACQ    = 3'b100;
    localparam [2:0] DONE   = 3'b111; 
    
    // Internal registers
    reg [2:0]  current_state;
    reg [2:0]  next_state;
    reg [31:0] size_reg;  
    reg [31:0] nb_of_sample_reg;
    reg [31:0] excitation_time_reg;
    reg [31:0] acquisition_time_reg;
    reg [31:0] counter;
    
    
    assign global_reset_n    = soft_rst_n & rst_n;
    assign size_o            = size_reg;       
    assign nb_of_sample_o    = nb_of_sample_reg; 
    
    // Sequential logic
    always @(posedge clk) begin 
        if (!global_reset_n) 
        begin                          
            current_state <= IDLE;
        end 
        else begin
            current_state   <= next_state;
            if (current_state == GEN || current_state == ACQ) begin
                counter <= counter + 32'b1;
            end
            else begin
                counter <= 32'd0;
            end
        end 
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        // Default values to avoid latches 
       
        case (current_state)
            IDLE: 
            begin
                if (~sts[0]&&start_cfg) 
                begin
                    next_state = SETUP;
                end
                else begin
                    next_state = IDLE;
                end              
            end
            SETUP: 
            begin
                next_state = GEN;
            end
            GEN: 
            begin
                if (counter >= excitation_time_reg) begin
                    next_state = ACQ;
                    end    
                else begin
                    next_state = GEN;
                end
            end
            ACQ: 
            begin
                
                if (counter >= (acquisition_time_reg + excitation_time_reg)) 
                begin
                    next_state  = DONE;
                end
                else 
                begin
                    next_state = ACQ;
                end
            end
            DONE:
            begin
                    next_state  = DONE;
            end
        endcase
    end

    // Combinational logic for outputs
    always @(*) begin

        excitation_time_reg  = cfg_ex_time_in; 
        acquisition_time_reg = cfg_acq_time_in;
        if (!global_reset_n) begin
            // Default values on reset
            sts              = 32'd0;
        end

        else begin
            Leds             = 7'b000;
            rst_writer       = 1'b1;
            rst_f            = 1'b1;
            rst_pck          = 1'b1;
            en_gen           = 1'b0;
            case (current_state) 
                IDLE :
                begin
                    Leds = 7'b000;
                end
                SETUP: 
                begin
                    Leds        = 7'b001;
                    rst_writer = 1'b0;
                    rst_f       = 1'b0;
                    size_reg         = cfg_size_in;
                    nb_of_sample_reg = cfg_nb_smpl_in;
                    cfg_amplitude    = cfg_amp_in;
                    cfg_freq         = cfg_freq_in;
                end
                GEN: begin
                    Leds       = 7'b011;
                    en_gen     = 1'b1;  
                end
                ACQ: begin
                    Leds        = 7'b111;
                    rst_pck     = 1'b0;
                end
                DONE: begin
                    Leds        = 7'b111;
                    sts[0]      = 1'b1; // flag done
                end
                default: begin
                end
            endcase
        end
    end

endmodule