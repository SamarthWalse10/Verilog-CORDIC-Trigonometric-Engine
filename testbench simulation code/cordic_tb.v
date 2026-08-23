`timescale 1ns / 1ps


module cordic_tb();
reg rst,clk;
reg start;
reg [15:0]angle; // Q2.14 format => (2 bits integer , 14 bits floating)
wire [15:0]sint;
reg [15:0]cost_inv;
wire done;

reg signed [31:0]i;

wire signed [15:0]cost;
cordic uut (rst,clk,start,angle,sint,cost,done);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

reg [15:0]temp_angles [0:180]; // store angles from [-90°,90°] with resolution of 1°
initial $readmemh("angle_table.mem", temp_angles);

initial begin
    rst=1; start=1; angle=16'h0000; i=-720;
    #20
    rst=0;
end

always @(posedge done) begin
    map_angle(i, angle);
    i <= i + 1;
end

always @(*) begin
    if (i>0) cost_inv <= (i%360>90 && i%360<=270) ? -cost : cost; 
    else cost_inv <= (i%360<=-90 && i%360>-270) ? -cost : cost; 
end

task automatic map_angle (input signed [31:0]input_deg, output [15:0]ref_deg);
    reg signed [31:0]input_deg_temp;
    reg signed [31:0]input_deg_bound;
    begin
        input_deg_temp = input_deg % 360;
        if (input_deg_temp <= -270) input_deg_bound = input_deg_temp + 360;
        else if (input_deg_temp <= -180) input_deg_bound = -1*(input_deg_temp + 180);
        else if (input_deg_temp <= -90) input_deg_bound = -1*(input_deg_temp + 180);
        else if (input_deg_temp <= 0) input_deg_bound = input_deg_temp;   
        else if (input_deg_temp <= 90) input_deg_bound = input_deg_temp;
        else if (input_deg_temp <= 180) input_deg_bound = 180 - input_deg_temp;
        else if (input_deg_temp <= 270) input_deg_bound = -1*(input_deg_temp - 180);
        else input_deg_bound = -1*(360 - input_deg_temp);
        ref_deg = temp_angles[(input_deg_bound + 90)];
    end
endtask

endmodule
