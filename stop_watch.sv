`timescale 1ns / 1ps

module stop_watch(
    // Clocks
    input logic MegaClk,
    input logic reset,
    
    // Stopwatch main signals
    input logic sel,
    input logic adj,
    input logic pause,
        
    // Seven Segment Display Driver
    output logic [3:0] trigger,
    output logic [7:0] segBits
);
    logic [7:0] displayBits[0:3];
    // Declare clocks
    logic clk_1hz;
    logic clk_blink;
    logic clk_2hz;
    logic clk_sevenseg;
        
    Clock clock_dut (
        .MegaClk(MegaClk),
        .reset(reset),
        .clk_1hz(clk_1hz),
        .clk_2hz(clk_2hz),
        .clk_blink(clk_blink),
        .clk_sevenseg(clk_sevenseg)
    );
    
    // display
    logic [3:0] digits [0:3];
    
    // clocks guard bits
    logic clk_1hz_en = 1'b0;
    logic clk_2hz_en = 1'b0;
    logic clk_blink_en = 1'b0;
    logic pause_en = 1'b0;

    always_ff @(posedge MegaClk) begin
        if (reset) begin
            digits[0] <= 4'b0;
            digits[1] <= 4'b0;
            digits[2] <= 4'b0;
            digits[3] <= 4'b0;
            clk_1hz_en <= 1'b0;
            clk_2hz_en <= 1'b0;
            clk_blink_en <= 1'b0;
            pause_en <= 1'b0;
        end else begin        
            // slow clock for debouncer to set pause enable in order to avoid noise sensitivity 
            if (clk_2hz && !clk_2hz_en) begin
                clk_2hz_en <= 1'b1;
                if (pause && !pause_en) begin
                    pause_en <= 1'b1;
                end else if (pause && pause_en) begin
                    pause_en <= 1'b0;
                end
            end else if (!clk_2hz && clk_2hz_en) begin
                clk_2hz_en <= 1'b0;
            end
            
            // Adjustment mode
            if (adj == 1) begin
                if (clk_blink && !clk_blink_en) begin
                    clk_blink_en <= 1'b1;
                end else if (!clk_blink && clk_blink_en) begin
                    clk_blink_en <= 1'b0;
                end
                if (clk_2hz && !clk_2hz_en) begin
                    clk_2hz_en <= 1'b1;
                    case (sel)
                        // seconds adjustment
                        1'b0: begin
                            digits[0] <= digits[0] + 1;
                            // if ones digit reaches 10, increments tens digit and reset ones digit
                            if (digits[0] == 4'd9) begin
                                digits[0] <= 4'b0;
                                digits[1] <= digits[1] + 1;
                                // if tens digit reaches 6, reset
                                if (digits[1] == 4'd5) begin
                                    digits[1] <= 4'b0;
                                    digits[0] <= 4'b0;
                                end
                            end
                        end
                        // minutes adjustment
                        1'b1: begin
                            digits[2] <= digits[2] + 1;
                            // if hundreds digit reaches 10, increments thousands digit and reset hundreds digit
                            if (digits[2] == 4'd9) begin
                                digits[2] <= 4'b0;
                                digits[3] <= digits[3] + 1;
                                // if thousands digit reaches 10, reset
                                if (digits[3] == 4'd9) begin
                                    digits[3] <= 4'b0;
                                    digits[2] <= 4'b0;
                                end
                            end
                        end
                    endcase
                end else if (!clk_2hz && clk_2hz_en) begin
                    clk_2hz_en <= 1'b0;
                end 
            end else begin
                // Normal operation
                if (!pause_en) begin
                    if (clk_1hz && !clk_1hz_en) begin
                        clk_1hz_en <= 1'b1;
                            digits[0] <= digits[0] + 1;
                            // when ones digit reaches 10, increments tens digit and reset
                            if (digits[0] == 4'd9) begin
                                digits[0] <= 4'b0;
                                digits[1] <= digits[1] + 1;
                                // if tens digit reaches 10, increments hundreds digit and reset tens digit
                                if (digits[1] == 4'd5) begin
                                    digits[1] <= 4'b0;
                                    digits[2] <= digits[2] + 1;
                                    // if hundreds digit reaches 10, increments thousands digit and reset hundreds digit
                                    if (digits[2] == 4'd9) begin
                                        digits[2] <= 4'b0;
                                        digits[3] <= digits[3] + 1;
                                        // if thousands digit reaches 10, reset everything since overflows
                                        if (digits[3] == 4'd9) begin
                                            digits[3] <= 4'b0;
                                            digits[2] <= 4'b0;
                                            digits[1] <= 4'b0;
                                            digits[0] <= 4'b0;
                                        end
                                    end
                                end
                            end
                        end
                    else if (!clk_1hz && clk_1hz_en) begin
                        clk_1hz_en <= 1'b0;
                    end
                end
            end
        end
    end
    
    logic [7:0] displayBits_final [3:0];
    always_comb begin
        displayBits_final = displayBits;
        if (adj && !clk_blink_en && !sel) begin
            displayBits_final[2] = 8'b11111111;
            displayBits_final[3] = 8'b11111111;
        end else if (adj && !clk_blink_en && sel) begin
            displayBits_final[0] = 8'b11111111;
            displayBits_final[1] = 8'b11111111;
        end
    end
    
    SevenSegDigit ones_dut (
        .digit(digits[0]),
        .displayBits(displayBits[0])
    );
    
    SevenSegDigit tens_dut (
        .digit(digits[1]),
        .displayBits(displayBits[1])
    );
    
    SevenSegDigit hundreds_dut (
        .digit(digits[2]),
        .displayBits(displayBits[2])
    );
    
    SevenSegDigit thousands_dut (
        .digit(digits[3]),
        .displayBits(displayBits[3])
    ); 
    
    seg_driver seg_dut (
        .MegaClk(MegaClk),
        .sel(sel),
        .clk_blink(clk_blink),
        .adj(adj),
        .reset(reset),
        .clk_sevenseg(clk_sevenseg),
        .displayBits(displayBits_final),
        .trigger(trigger),
        .segBits(segBits)
    );
endmodule
