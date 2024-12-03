//触摸坐标转按键键值算法

module touch_solve (
    input clk,
    input rst_n,
    input [31:0] touch_data,
    output reg [7:0] my_threshold_y_up_touch    ,
    output reg [7:0] my_threshold_y_down_touch  ,
    output reg [7:0] my_threshold_cb_up_touch   ,
    output reg [7:0] my_threshold_cb_down_touch ,
    output reg [7:0] my_threshold_cr_up_touch   ,
    output reg [7:0] my_threshold_cr_down_touch ,
    output reg motor_reset_touch
);
wire [15:0] touch_x;
wire [15:0] touch_y;
assign touch_x = touch_data[31:16];
assign touch_y = touch_data[15:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        my_threshold_y_up_touch    <=8'hff;
        my_threshold_y_down_touch  <=8'h00;
        my_threshold_cb_up_touch   <=8'hff;
        my_threshold_cb_down_touch <=8'h80;
        my_threshold_cr_up_touch   <=8'hff;
        my_threshold_cr_down_touch <=8'h80;
        motor_reset_touch          <=0;
    end
    //y max
    else if (((touch_x>(16'h293-16'd10))&&(touch_x<(16'h293+16'd10))) && ((touch_y>16'h27)&&(touch_y<16'hd8))) begin
        my_threshold_y_up_touch<=((16'hd8-touch_y)*255)/(16'hd8-16'h27);
    end
    //y min
    else if (((touch_x>(16'h293-16'd10))&&(touch_x<(16'h293+16'd10))) && ((touch_y>16'h109)&&(touch_y<16'h1c8))) begin
        my_threshold_y_down_touch<=((16'h1c8-touch_y)*255)/(16'h1c8-16'h109);
    end
    //cb max
    else if (((touch_x>(16'h2c7-16'd10))&&(touch_x<(16'h2c7+16'd10))) && ((touch_y>16'h27)&&(touch_y<16'hd8))) begin
        my_threshold_cb_up_touch<=((16'hd8-touch_y)*255)/(16'hd8-16'h27);
    end
    //cb min
    else if (((touch_x>(16'h2c7-16'd10))&&(touch_x<(16'h2c7+16'd10))) && ((touch_y>16'h109)&&(touch_y<16'h1c8))) begin
        my_threshold_cb_down_touch<=((16'h1c8-touch_y)*255)/(16'h1c8-16'h109);
    end
    //cr max
    else if (((touch_x>(16'h311-16'd10))&&(touch_x<(16'h311+16'd10))) && ((touch_y>16'h27)&&(touch_y<16'hd8))) begin
        my_threshold_cr_up_touch<=((16'hd8-touch_y)*255)/(16'hd8-16'h27);
    end
    //cr min
    else if (((touch_x>(16'h311-16'd10))&&(touch_x<(16'h311+16'd10))) && ((touch_y>16'h109)&&(touch_y<16'h1c8))) begin
        my_threshold_cr_down_touch<=((16'h1c8-touch_y)*255)/(16'h1c8-16'h109);
    end
    //motor touch
    else if (((touch_x>(16'h53-16'd30))&&(touch_x<(16'h53+16'd30))) && ((touch_y>(16'h1c3-16'd30))&&(touch_y<(16'h1c3+16'd30)))) begin
        motor_reset_touch<=1'b1;
    end

    else begin
        my_threshold_y_up_touch    <= my_threshold_y_up_touch   ;
        my_threshold_y_down_touch  <= my_threshold_y_down_touch ;
        my_threshold_cb_up_touch   <= my_threshold_cb_up_touch  ;
        my_threshold_cb_down_touch <= my_threshold_cb_down_touch;
        my_threshold_cr_up_touch   <= my_threshold_cr_up_touch  ;
        my_threshold_cr_down_touch <= my_threshold_cr_down_touch;
        motor_reset_touch <= 0;
    end
end


ila_3 my_ila_3 (
	.clk(clk), // input wire clk


	.probe0(touch_data), // input wire [31:0]  probe0  
	.probe1(touch_x), // input wire [15:0]  probe1 
	.probe2(touch_y), // input wire [15:0]  probe2 
	.probe3(my_threshold_y_up_touch   ), // input wire [7:0]  probe3 
	.probe4(my_threshold_y_down_touch ), // input wire [7:0]  probe4 
	.probe5(my_threshold_cb_up_touch  ), // input wire [7:0]  probe5 
	.probe6(my_threshold_cb_down_touch), // input wire [7:0]  probe6 
	.probe7(my_threshold_cr_up_touch  ), // input wire [7:0]  probe7 
	.probe8(my_threshold_cr_down_touch) // input wire [7:0]  probe8
);


endmodule