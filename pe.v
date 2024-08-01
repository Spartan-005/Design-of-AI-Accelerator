`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2024 20:23:53
// Design Name: 
// Module Name: pe
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




module pe(
input clk,reset,
input [31:0] in_a,in_b, 
output reg [31:0] out_a, out_b, out_c
);

    wire [31:0] t,f; // Intermediate signals for multiplication and addition results

    floating_multiplier fm(.a(in_a),.b(in_b),.o(t));
    floating_adder fa(.a(t), .b(out_c), .o(f));

    always @(posedge clk) begin
        if(reset) begin
            out_a <= 0;
            out_b <= 0;
            out_c <= 0;
        end
        else begin
            out_a<=in_a;
            out_b<=in_b;
            out_c<=f;
        end
    end
endmodule


