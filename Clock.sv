`timescale 1ns / 1ps

module Clock(
    input logic MegaClk, 
    input logic reset,
    output logic clk_2hz,
    output logic clk_1hz,
    output logic clk_sevenseg,
    output logic clk_blink 
);    
    logic [31:0] cnt_1hz = 32'b0;
    logic [31:0] cnt_2hz = 32'b0;
    logic [31:0] cnt_sevenseg = 32'b0;
    logic [31:0] cnt_blink = 32'b0;
    always_ff @(posedge MegaClk) begin
        if (reset) begin 
            cnt_1hz <= 32'b0;
            cnt_2hz <= 32'b0;
            cnt_sevenseg <= 32'b0;
            cnt_blink <= 32'b0;
            
            clk_1hz <= 1'b1;
            clk_2hz <= 1'b1;
            clk_sevenseg <= 1'b1;
            clk_blink <= 1'b1;
        end else begin
            cnt_1hz <= cnt_1hz + 1;
            cnt_2hz <= cnt_2hz + 1;
            cnt_sevenseg <= cnt_sevenseg + 1;
            cnt_blink <= cnt_blink + 1;
                // clock_1hz
                if (cnt_1hz == 32'd50000000) begin
                    clk_1hz <= 1'b0;
                end else if (cnt_1hz == 32'd100000000) begin
                    clk_1hz <= 1'b1;
                    cnt_1hz <= 32'b0;
                end 
                
                // clock_blink 
                if (cnt_blink == 32'd25500000) begin
                    clk_blink <= 1'b0;
                end else if (cnt_blink == 32'd51000000) begin
                    clk_blink <= 1'b1;
                    cnt_blink <= 32'b0;
                end 
                
                // clock_2hz
                if (cnt_2hz == 32'd25000000) begin
                    clk_2hz <= 1'b0;
                end else if (cnt_2hz == 32'd50000000) begin
                    clk_2hz <= 1'b1;
                    cnt_2hz <= 32'b0;
                end 
                
                // clock_sevenseg
                if (cnt_sevenseg == 32'd100000) begin
                    clk_sevenseg <= 1'b0;
                end else if (cnt_sevenseg == 32'd200000) begin
                    clk_sevenseg <= 1'b1;
                    cnt_sevenseg <= 32'b0;
                end 
            end
        end
endmodule
