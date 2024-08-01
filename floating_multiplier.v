`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2024 17:51:11
// Design Name: 
// Module Name: floating_multiplier
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


module floating_multiplier(
input [31:0]a,b,output reg[31:0]o
    );
    
    reg [47:0]m; //to store the mantissa of product

    always@* begin
        if(a==0 | b==0)
            o = 0;
        else begin
            o[31] = a[31] ^ b[31]; // Set the sign bit of the result
            m = {1'b1, a[22:0]} * {1'b1, b[22:0]}; // Multiply mantissas
            o[22:0] = m[47] ? m[46:24] : m[45:23]; // Extract mantissa bits
            o[30:23] = a[30:23] + b[30:23] - 127 + m[47]; // Calculate exponent

        end
    end
endmodule












