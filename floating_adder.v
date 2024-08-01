`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2024 01:18:21
// Design Name: 
// Module Name: floating_adder
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


module floating_adder(
input [31:0]a, b, output reg [31:0] o
    );
    reg [31:0] A, B; // store greater and smaller number respectively
    reg g, c; // Control signals for comparison and carry
    reg h_A, h_B; // Hidden bit for operands A and B
    reg [23:0] m, s; // Shifted smaller no mantissa and sum/difference mantissa
    reg [7:0] e; // Exponent difference

    
    always@* begin
        g = a[30:23] != b[30:23] ? a[30:23] >= b[30:23] : a[22:0] >= b[22:0];
        A = g ? a : b;
        B = g ? b : a;
        h_A = (A==0) ? 1'b0 : 1'b1;
        h_B = (B==0) ? 1'b0 : 1'b1;
        e = A[30:23] - B[30:23];
        m = {h_B,B[22:0]} >> e;
        {c,s} = (A[31]^B[31]) ? ({h_A,A[22:0]} - m) : ({h_A,A[22:0]} + m) ;
        o[31] = A[31];
        o[30:23] = A[30:23];
        if(c) begin
            o[30:23] = o[30:23] + 1; 
            o[22:0] = s[23:1];
        end
        else begin
            if(s==0)
                o=0;
            else begin
                while(!s[23]) begin
                    s = s<<1;
                    o[30:23] = o[30:23] - 1;
                end  
                o[22:0] = s[22:0];
            end
        end
    end
endmodule