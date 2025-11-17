`timescale 1 ns / 1 ps
module fsm_read_mem (
    input               clk,
    input      [192:0]  cfg,
    output reg [31:0]   sts, 
    output reg [6:0]    Leds, 
    // Control of the ACQ
    output reg          rst_writer,
    output reg          rst_pck,
    output reg          rst_f,
    output [31:0]       size,
    output [31:0]       nb_of_sample,
    // Control of the GEN
    output reg  [15:0]  cfg_amplitude,
    output reg  [31:0]  cfg_freq,       
    output reg          en_gen         
);

    // State definition - consistent encoding
    localparam [2:0] IDLE   = 3'b000;
    localparam [2:0] SETUP  = 3'b001;
    localparam [2:0] GEN    = 3'b010;
    localparam [2:0] ACQ    = 3'b100;
    localparam [2:0] DONE   = 3'b111; 
    
    // Internal registers
    reg [2:0]  current_state;
    reg [2:0]  next_state;
    reg [31:0] sts_next;
    reg [31:0] size_reg;  
    reg [31:0] nb_of_sample_reg;
    reg [31:0] excitation_time;
    reg [31:0] acquisition_time;
    reg [31:0] counter;
    
    
    wire rst_n      = cfg[0];
    wire state_cfg  = cfg[1];
    
    assign size         = size_reg;       
    assign nb_of_sample = nb_of_sample_reg; 
    
    // Sequential logic
    always @(posedge clk) begin 
        if (!rst_n) 
        begin                          
            counter       <= 32'd0;
            sts           <= 32'd0;
            current_state <= IDLE;
        end 
        else if (current_state == GEN || current_state == ACQ) 
        begin
            counter         <= counter + 32'b1;
            current_state   <= next_state;
            sts             <= sts_next;
        end
        else
        begin
            counter         <= 32'd0;
            current_state   <= next_state;
            sts             <= sts_next;
        end
    end
    
    // Combinational logic for next state and outputs
    always @(*) begin
        // Default values to avoid latches
        rst_writer       = 1'b1;
        rst_f            = 1'b1;
        rst_pck          = 1'b1;
        en_gen           = 1'b0;
        Leds             = 7'b000;
        sts_next         = sts;

        excitation_time  = cfg[160:128];
        acquisition_time = cfg[192:160];
        
        case (current_state)
            IDLE: 
            begin
                Leds = 7'b000;
                
                if (~sts[0]&&state_cfg) 
                begin
                    next_state = SETUP;
                end
                else begin
                    next_state = IDLE;
                end              
           end
            
            SETUP: 
            begin
                Leds       = 7'b001;
                rst_writer = 1'b0;
                rst_f       = 1'b0;
                size_reg         = cfg[63:32];
                nb_of_sample_reg = cfg[95:64];
                cfg_amplitude    = cfg[31:16];
                cfg_freq         = cfg[127:96];

                next_state = GEN;
            end
            
            GEN: 
            begin
                Leds     = 7'b011;
                en_gen   = 1'b1;  

                if (counter >= excitation_time) begin
                    next_state = ACQ;
                    end    
                else begin
                    next_state = GEN;
                end
            end
            
            ACQ: 
            begin
                Leds     = 7'b111;
                rst_pck  = 1'b0;
                
                if (counter >= (acquisition_time + excitation_time)) 
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
                    Leds        = 7'b111;
                    sts_next[0] = 1'b1; // Indicate done
                    next_state  = IDLE;
            end
        endcase
    end
    
endmodule