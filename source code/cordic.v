`timescale 1ns / 1ps


module cordic (rst,clk,start,angle,sint,cost,done);
input rst,clk;
input start;
input [15:0]angle; // Q2.14 format => (2 bits integer , 14 bits floating)
output reg [15:0]sint,cost;
output reg done;

reg state;
localparam IDLE = 1'b0;
localparam ITERATE = 1'b1;

reg [3:0]iter;
reg signed [15:0]x,y,z;

// inverse_tan table (Q2.14 values for itan(2^-i)) in radians
reg signed [15:0]itan_table [0:15];
initial begin
    itan_table[0]  = 16'h3243; // 0.7854
    itan_table[1]  = 16'h1DAC; // 0.4636
    itan_table[2]  = 16'h0FA0; // 0.2450
    itan_table[3]  = 16'h07F4; // 0.1244
    itan_table[4]  = 16'h0400; // 0.0624
    itan_table[5]  = 16'h0200; // 0.0312
    itan_table[6]  = 16'h0100; // 0.0156
    itan_table[7]  = 16'h0080; // 0.0078
    itan_table[8]  = 16'h0040; // 0.0039
    itan_table[9]  = 16'h0020; // 0.00195
    itan_table[10] = 16'h0010; // 0.000976
    itan_table[11] = 16'h0008; // 0.000488
    itan_table[12] = 16'h0004; // 0.000244
    itan_table[13] = 16'h0002; // 0.000122
    itan_table[14] = 16'h0001; // 0.000061
    itan_table[15] = 16'h0000; // ~0.0000305
end

always @(posedge rst or posedge clk) begin
    if (rst) begin
        state <= IDLE;
        sint <= 0;
        cost <= 0;
        done <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                done <= 0;
                if (start) begin
                    x <= 16'h26DF; // k=0.60725 in Q2.14
                    y <= 0;
                    z <= angle; // input angle in Q2.14
                    iter <= 0;
                    state <= ITERATE;
                end
            end
            ITERATE: begin
                if (iter == 4'd15) begin
                    if (z >= 0) begin
                        x <= x - (y >>> iter);
                        y <= y + (x >>> iter);
                    end 
                    else begin
                        x <= x + (y >>> iter);
                        y <= y - (x >>> iter);
                    end
                    sint <= y;
                    cost <= x;
                    done <= 1;
                    state <= IDLE;
                end
                else begin
                    if (z >= 0) begin
                        x <= x - (y >>> iter);
                        y <= y + (x >>> iter);
                        z <= z - itan_table[iter];
                    end 
                    else begin
                        x <= x + (y >>> iter);
                        y <= y - (x >>> iter);
                        z <= z + itan_table[iter];
                    end
                    iter <= iter + 1;
                end
            end
        endcase
    end
end

endmodule
