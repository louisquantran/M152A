`timescale 1ns / 1ps

module seg_driver(
    input reset,
    input MegaClk,
    
    input logic clk_sevenseg,
    input logic adj,
    input logic clk_blink,
    input logic sel,
    
    input logic [7:0] displayBits[0:3],
    output logic [3:0] trigger,
    output logic [7:0] segBits
);
    logic [1:0] ctr = 2'b0;
    logic clk_sevenseg_en;
    
    always_ff @(posedge MegaClk) begin
        if (reset) begin
            clk_sevenseg_en <= 1'b0;
            ctr <= 2'b0;
            trigger <= 4'b1111;
            segBits <= 8'b11111111; 
        end else begin
            if (clk_sevenseg && !clk_sevenseg_en) begin
                clk_sevenseg_en <= 1'b1;
                case (ctr)
                    // Enable AN0
                    2'b00: begin
                        trigger <= 4'b1110;
                        segBits <= displayBits[0];
                    end
                    
                    //Enable AN1
                    2'b01: begin
                        trigger <= 4'b1101;
                        segBits <= displayBits[1];
                    end
                    
                    //Enable AN2
                    2'b10: begin
                        trigger <= 4'b1011;
                        segBits <= displayBits[2];
                    end
                    
                    // Enable AN3
                    2'b11: begin
                        trigger <= 4'b0111;
                        segBits <= displayBits[3];
                    end
                    
                    // Default case
                    default: begin
                        trigger <= 4'b1111;
                        segBits <= 8'hFF;
                    end
                endcase
                // reset ctr if ctr == 3
                if (ctr == 2'b11) begin
                    ctr <= 2'b0;
                end else begin
                    ctr <= ctr + 1;
                end
            end else if (!clk_sevenseg && clk_sevenseg_en) begin 
                clk_sevenseg_en <= 1'b0; 
            end
        end
    end
endmodule
