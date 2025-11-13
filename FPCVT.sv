`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 12:10:42 PM
// Design Name: 
// Module Name: fpoint
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FPCVT(
    input logic [11:0] D,
    output logic S,
    output logic [2:0] E,
    output logic [3:0] F
);
    logic S_bit;
    logic [2:0] E_bits;
    logic [3:0] F_bits;
    logic [11:0] D_bits = D;
    
    assign S = S_bit;
    assign E = E_bits;
    assign F = F_bits;
    
    logic [3:0] cnt = 0;
    logic flag = 0;
    int leading_zeros = 11;
    
        // Convert to non-negative
    always_comb begin
        S_bit = 0; E_bits = '0; F_bits = '0;
        cnt = '0; flag = 0;
        leading_zeros = 11;
        D_bits = D;
        if (D_bits[11] == 1) begin
            S_bit = 1;
            D_bits = ~D_bits;
            D_bits = D_bits + 1;
        end else begin
            S_bit = 0;
        end
        for (int i = 0; i < 12; i++) begin
            if (D_bits[leading_zeros] == 0) begin
                cnt = cnt + 1;
                leading_zeros = leading_zeros - 1;
            end else begin
                break;
            end
        end
        if (D_bits == 2048) begin
            E_bits = 7;
            F_bits = 15;
        end else begin
            if (cnt == 1) E_bits = 7;
            else if (cnt == 2) E_bits = 6;
            else if (cnt == 3) E_bits = 5;
            else if (cnt == 4) E_bits = 4;
            else if (cnt == 5) E_bits = 3;
            else if (cnt == 6) E_bits = 2;
            else if (cnt == 7) E_bits = 1;
            else E_bits = 0;
            if (E_bits == 0) begin
                F_bits[3:0] = D_bits[3:0];  
            end else begin
                for (int i = 3; i >= 0; i=i-1) begin
                    F_bits[i] = D_bits[leading_zeros];
                    leading_zeros = leading_zeros-1;
                end
                if (D_bits[leading_zeros] == 1 && F_bits < 15) begin
                    F_bits = F_bits + 1;
                end else if (D_bits[leading_zeros] == 1 && F_bits == 15 && E_bits < 7) begin
                    F_bits = F_bits >> 1;
                    F_bits = F_bits + 1;
                    E_bits = E_bits + 1;
                end 
            end
        end
    end
endmodule
