module systolic_array#(parameter DIM = 2)(
    input clk, 
    input reset,
    input [0: DIM * 32-1] data, // column wise
    input [0: DIM * 32-1] weight, // row wise
    output [0: DIM*DIM* 32-1] rout
);

wire [31:0] data_c [0: DIM-1];
wire [31:0] weight_r [0: DIM-1];
wire [31:0] a [0:DIM-1][0:DIM-1];
wire [31:0] b [0:DIM-1][0:DIM-1];
wire [31:0] res [0:DIM-1][0:DIM-1];

genvar i,j;
generate
    for(i = 0; i < DIM; i = i + 1) begin
        assign data_c[i] = data[i * 32 +: 32];
        assign weight_r[i] = weight[i * 32 +: 32];
    end
endgenerate

generate
    for(i = 0; i < DIM; i = i + 1) begin
        for(j=0;j<DIM;j=j+1) begin
            assign a[i][j] = data_c[i];
            assign b[i][j] = weight_r[j];
        end
    end
endgenerate

generate
    for(i = 0; i < DIM; i = i + 1) begin
        for(j = 0; j < DIM; j = j + 1) begin
            pe dut(
                .clk(clk),
                .reset(reset),
                .in_a(a[i][j]),
                .in_b(b[i][j]),
                .out_c(res[i][j])
            );
        end
    end
endgenerate

 generate
        for (i = 0; i < DIM; i = i + 1) begin 
            for (j = 0; j < DIM; j = j + 1) begin 
                assign rout[(i*2 + j)*32 +: 32] = res[i][j];
            end
        end
    endgenerate

endmodule