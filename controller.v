`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 23:34:59
// Design Name: 
// Module Name: controller
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


module controller #(parameter DIM=2)(
    input clk,
    input reset,
    input [31:0] data_input,
    input [31:0] weight_input,
    output reg [0: 31] result
);

reg [31:0] data[0:DIM-1][0:DIM-1];
reg [31:0] weight[0:DIM-1][0:DIM-1];
reg [31:0] rout[0:DIM-1][0:DIM-1];
reg [DIM*32-1:0] data_stream;
reg [DIM*32-1:0] weight_stream;
wire [DIM*32-1:0] d;
wire [DIM*32-1:0] w;
reg [0: DIM*DIM*32-1] res_w;
reg DONE;
reg [2:0] state; 
reg [1:0] row, col; 
reg [4:0] count=0,c=0;
wire [4:0] k;

always @(posedge clk) begin
    if(reset)
        state<=0;
    case(state)
        0: begin // Idle state
            state <= 1; 
            row <= 0; 
            col <= 0;
            count<=0;
            DONE<=0; 
            
        end
        1: begin // Load data and weight
            data[row][col] <= data_input;
            weight[row][col] <= weight_input;
            if(col == DIM-1) begin
                if(row == DIM-1)
                    state <= 2; 
                else
                    row <= row + 1; 
                col <= 0; 
            end
            else
                col <= col + 1; 
        end
        2: begin // Start computation
            data_stream <= d;
            weight_stream <= w;
            count=count+1;
            if(count==DIM) begin
                state<=3;
            end
            else
                state<=2;
        end
        3: begin
            result=res_w[c*32+:32];
            c=c+1;
            if(c==DIM*DIM)begin
                DONE = 1;
                state<=0;
            end         
            else begin
                state <= 3;
            end
        end
    endcase
end

assign k = count;
generate
   genvar i;
   for (i = 0; i < DIM; i = i + 1) begin 
       assign d[(i+1)*32-1:i*32] = data[i][k];
       assign w[(i+1)*32-1:i*32] = weight[k][i];
   end
endgenerate

systolic_array ins(
    .clk(clk), 
    .reset(reset),
    .data(data_stream), // column wise
    .weight(weight_stream), // row wise
    .rout(res_w)
);

endmodule