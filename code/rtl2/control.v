// Descriptions:        电机目标位置计算

module control (
    input           sys_clk,
    input           sys_rst_n,
    input           motor_ready_x,
    input           motor_ready_y,
    input           motor_ready_z,

    input  [2:0]  motor_start_pos,
    input  [3:0]  motor_end_pos,
    input         motor_start,

    input  [3:0]  motor_start_pos2,
    input  [3:0]  motor_end_pos2,
    input         motor_start2,

    output  [15:0]  goal_pulse_x,
    output  [15:0]  goal_pulse_y,
    output  [15:0]  goal_pulse_z,
    output  reg     catch_en,
    output          motor_program_done
);
assign motor_program_done = (motor_program_cnt == 4'd10)? 1:0; 

wire [15:0] goal_pulse_x_handset;
wire [15:0] goal_pulse_y_handset;
wire [15:0] goal_pulse_z_handset;
reg [15:0] goal_pulse_x_auto;
reg [15:0] goal_pulse_y_auto;
reg [15:0] goal_pulse_z_auto;

wire goal_pulse_handset_en;

assign goal_pulse_x = (goal_pulse_handset_en == 1'b1) ? goal_pulse_x_handset : goal_pulse_x_auto;
assign goal_pulse_y = (goal_pulse_handset_en == 1'b1) ? goal_pulse_y_handset : goal_pulse_y_auto;
assign goal_pulse_z = (goal_pulse_handset_en == 1'b1) ? goal_pulse_z_handset : goal_pulse_z_auto;

vio_3 motor_control_vio (
  .clk(sys_clk),                // input wire clk
  .probe_out0(goal_pulse_x_handset),  // output wire [15 : 0] probe_out0
  .probe_out1(goal_pulse_y_handset),  // output wire [15 : 0] probe_out1
  .probe_out2(goal_pulse_z_handset),  // output wire [15 : 0] probe_out2
  .probe_out3(goal_pulse_handset_en)  // output wire [0 : 0] probe_out3
);

reg [28:0] motor_program_clk_cnt;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        motor_program_clk_cnt<=0;
    end
    else if (motor_program_clk_cnt<28'd1000_0000) begin
        motor_program_clk_cnt<=motor_program_clk_cnt+1'b1;
    end
    else 
        motor_program_clk_cnt<=0;
end

reg motor_program_clk;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
        motor_program_clk<=1'b0;
    else if (motor_program_clk_cnt>28'd500_0000)
        motor_program_clk<=1'b1;
    else
        motor_program_clk<=1'b0;
end

wire motor_ready_all;
assign motor_ready_all = motor_ready_x & motor_ready_y & motor_ready_z;

reg  [3:0] motor_program_cnt;

reg  [48:0] all_program [64:0];

always @(posedge motor_program_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        motor_program_cnt<=0;
        all_program[4'd0] <=49'h0_8000_8000_8000;
        all_program[4'd1] <=49'h0_8000_8000_8000;
        all_program[4'd2] <=49'h0_8000_8000_8000;
        all_program[4'd3] <=49'h0_8000_8000_8000;
        all_program[4'd4] <=49'h0_8000_8000_8000;
        all_program[4'd5] <=49'h0_8000_8000_8000;
        all_program[4'd6] <=49'h0_8000_8000_8000;
        all_program[4'd7] <=49'h0_8000_8000_8000;
        goal_pulse_x_auto <=49'h0_8000_8000_8000;
        goal_pulse_y_auto <=49'h0_8000_8000_8000;
        goal_pulse_z_auto <=49'h0_8000_8000_8000;
    end
    else if(motor_start==1'b1)begin
        case (motor_start_pos)
            0:begin
                all_program[4'd0] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd1] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd2] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd3] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            1:begin
                //第1个存储
                all_program[4'd0] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd1] <=49'h0_B900_2250_6D80;//第1个存储放下
                all_program[4'd2] <=49'h1_B900_2250_6D80;//第1个磁吸开
                all_program[4'd3] <=49'h1_B900_2250_8800;//第1个存储抬起
            end 
            2:begin
                //第2个存储
                all_program[4'd0] <=49'h0_B900_3D50_8800;//第2个存储抬起
                all_program[4'd1] <=49'h0_B900_3D50_6D80;//第2个存储放下
                all_program[4'd2] <=49'h1_B900_3D50_6D80;//第2个磁吸开
                all_program[4'd3] <=49'h1_B900_3D50_8800;//第2个存储抬起
            end
            3:begin
                //第3个存储
                all_program[4'd0] <=49'h0_9900_2250_8800;//第3个存储抬起
                all_program[4'd1] <=49'h0_9900_2250_6D80;//第3个存储放下
                all_program[4'd2] <=49'h1_9900_2250_6D80;//第3个磁吸开
                all_program[4'd3] <=49'h1_9900_2250_8800;//第3个存储抬起
            end
            4:begin
                //第4个存储
                all_program[4'd0] <=49'h0_9900_3A50_8800;//第4个存储抬起
                all_program[4'd1] <=49'h0_9900_3A50_6D80;//第4个存储放下
                all_program[4'd2] <=49'h1_9900_3A50_6D80;//第4个磁吸开
                all_program[4'd3] <=49'h1_9900_3A50_8800;//第4个存储抬起
            end
            default: ;
        endcase
        case (motor_end_pos)
            0: begin
                all_program[4'd4] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd5] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd6] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd7] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            1: begin
                //第1个下棋
                all_program[4'd4] <=49'h1_B500_6C00_8800;//第1个下棋抬起
                all_program[4'd5] <=49'h1_B500_6C00_6E80;//第1个下棋放下
                all_program[4'd6] <=49'h0_B500_6C00_6E80;//第1个磁吸关
                all_program[4'd7] <=49'h0_B500_6C00_8800;//第1个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            2: begin
                //第2个下棋
                all_program[4'd4] <=49'h1_B500_8C00_8800;//第2个下棋抬起
                all_program[4'd5] <=49'h1_B500_8C00_6E80;//第2个下棋放下
                all_program[4'd6] <=49'h0_B500_8C00_6E80;//第2个磁吸关
                all_program[4'd7] <=49'h0_B500_8C00_8800;//第2个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            3: begin
                //第3个下棋
                all_program[4'd4] <=49'h1_B500_AC00_8800;//第3个下棋抬起
                all_program[4'd5] <=49'h1_B500_AC00_6E80;//第3个下棋放下
                all_program[4'd6] <=49'h0_B500_AC00_6E80;//第3个磁吸关
                all_program[4'd7] <=49'h0_B500_AC00_8800;//第3个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            4: begin
                //第4个下棋
                all_program[4'd4] <=49'h1_9000_6C00_8800;//第4个下棋抬起
                all_program[4'd5] <=49'h1_9000_6C00_6E80;//第4个下棋放下
                all_program[4'd6] <=49'h0_9000_6C00_6E80;//第4个磁吸关
                all_program[4'd7] <=49'h0_9000_6C00_8800;//第4个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            5: begin
                //第5个下棋
                all_program[4'd4] <=49'h1_9000_8C00_8800;//第5个下棋抬起
                all_program[4'd5] <=49'h1_9000_8C00_6E80;//第5个下棋放下
                all_program[4'd6] <=49'h0_9000_8C00_6E80;//第5个磁吸关
                all_program[4'd7] <=49'h0_9000_8C00_8800;//第5个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            6: begin
                //第6个下棋
                all_program[4'd4] <=49'h1_9000_AC00_8800;//第6个下棋抬起
                all_program[4'd5] <=49'h1_9000_AC00_6E80;//第6个下棋放下
                all_program[4'd6] <=49'h0_9000_AC00_6E80;//第6个磁吸关
                all_program[4'd7] <=49'h0_9000_AC00_8800;//第6个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            7: begin
                //第7个下棋
                all_program[4'd4] <=49'h1_7500_6C00_8800;//第7个下棋抬起
                all_program[4'd5] <=49'h1_7500_6C00_6E80;//第7个下棋放下
                all_program[4'd6] <=49'h0_7500_6C00_6E80;//第7个磁吸关
                all_program[4'd7] <=49'h0_7500_6C00_8800;//第7个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            8: begin
                //第8个下棋
                all_program[4'd4] <=49'h1_7500_8C00_8800;//第8个下棋抬起
                all_program[4'd5] <=49'h1_7500_8C00_6E80;//第8个下棋放下
                all_program[4'd6] <=49'h0_7500_8C00_6E80;//第8个磁吸关
                all_program[4'd7] <=49'h0_7500_8C00_8800;//第8个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            9: begin
                //第9个下棋
                all_program[4'd4] <=49'h1_7500_AC00_8800;//第9个下棋抬起
                all_program[4'd5] <=49'h1_7500_AC00_6E80;//第9个下棋放下
                all_program[4'd6] <=49'h0_7500_AC00_6E80;//第9个磁吸关
                all_program[4'd7] <=49'h0_7500_AC00_8800;//第9个下棋抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            default: ;
        endcase
        motor_program_cnt<=4'd0;
    end

    else if (motor_start2 == 1'b1) begin
        case (motor_end_pos2)
            0:begin
                all_program[4'd4] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd5] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd6] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd7] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd8] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end 
            1:begin
                //第1个存储
                all_program[4'd4] <=49'h1_B900_2250_8800;//第1个存储抬起
                all_program[4'd5] <=49'h1_B900_2250_6D80;//第1个存储放下
                all_program[4'd6] <=49'h0_B900_2250_6D80;//第1个磁吸关
                all_program[4'd7] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end 
            2:begin
                //第2个存储
                all_program[4'd4] <=49'h1_B900_3D50_8800;//第2个存储抬起
                all_program[4'd5] <=49'h1_B900_3D50_6D80;//第2个存储放下
                all_program[4'd6] <=49'h0_B900_3D50_6D80;//第2个磁吸关
                all_program[4'd7] <=49'h0_B900_3D50_8800;//第2个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            3:begin
                //第3个存储
                all_program[4'd4] <=49'h1_9900_2250_8800;//第3个存储抬起
                all_program[4'd5] <=49'h1_9900_2250_6D80;//第3个存储放下
                all_program[4'd6] <=49'h0_9900_2250_6D80;//第3个磁吸关
                all_program[4'd7] <=49'h0_9900_2250_8800;//第3个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            4:begin
                //第4个存储
                all_program[4'd4] <=49'h1_9900_3A50_8800;//第4个存储抬起
                all_program[4'd5] <=49'h1_9900_3A50_6D80;//第4个存储放下
                all_program[4'd6] <=49'h0_9900_3A50_6D80;//第4个磁吸关
                all_program[4'd7] <=49'h0_9900_3A50_8800;//第4个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            5:begin
                //第5个存储
                all_program[4'd4] <=49'h1_7B00_2250_8800;//第5个存储抬起
                all_program[4'd5] <=49'h1_7B00_2250_6D80;//第5个存储放下
                all_program[4'd6] <=49'h0_7B00_2250_6D80;//第5个磁吸关
                all_program[4'd7] <=49'h0_7B00_2250_8800;//第5个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            6:begin
                //第6个存储
                all_program[4'd4] <=49'h1_7900_3F50_8800;//第6个存储抬起
                all_program[4'd5] <=49'h1_7900_3F50_6D80;//第6个存储放下
                all_program[4'd6] <=49'h0_7900_3F50_6D80;//第6个磁吸关
                all_program[4'd7] <=49'h0_7900_3F50_8800;//第6个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            7:begin
                //第7个存储
                all_program[4'd4] <=49'h1_5A00_2250_8800;//第7个存储抬起
                all_program[4'd5] <=49'h1_5A00_2250_6D80;//第7个存储放下
                all_program[4'd6] <=49'h0_5A00_2250_6D80;//第7个磁吸关
                all_program[4'd7] <=49'h0_5A00_2250_8800;//第7个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            8:begin
                //第8个存储
                all_program[4'd4] <=49'h1_5A00_3F50_8800;//第8个存储抬起
                all_program[4'd5] <=49'h1_5A00_3F50_6D80;//第8个存储放下
                all_program[4'd6] <=49'h0_5A00_3F50_6D80;//第8个磁吸关
                all_program[4'd7] <=49'h0_5A00_3F50_8800;//第8个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            9:begin
                //第9个存储
                all_program[4'd4] <=49'h1_5A00_6000_8800;//第9个存储抬起
                all_program[4'd5] <=49'h1_5A00_6000_6D80;//第9个存储放下
                all_program[4'd6] <=49'h0_5A00_6000_6D80;//第9个磁吸关
                all_program[4'd7] <=49'h0_5A00_6000_8800;//第9个存储抬起
                all_program[4'd8] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd9] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd10] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            default: ;
        endcase
        case (motor_start_pos2)
            0: begin
                //第1个下棋
                all_program[4'd0] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd1] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd2] <=49'h0_B900_2250_8800;//第1个存储抬起
                all_program[4'd3] <=49'h0_B900_2250_8800;//第1个存储抬起
            end
            1: begin
                //第1个下棋
                all_program[4'd0] <=49'h0_B500_6C00_8800;//第1个下棋抬起
                all_program[4'd1] <=49'h0_B500_6C00_6E80;//第1个下棋放下
                all_program[4'd2] <=49'h1_B500_6C00_6E80;//第1个磁吸开
                all_program[4'd3] <=49'h1_B500_6C00_8800;//第1个下棋抬起
            end
            2: begin
                //第2个下棋
                all_program[4'd0] <=49'h0_B500_8C00_8800;//第2个下棋抬起
                all_program[4'd1] <=49'h0_B500_8C00_6E80;//第2个下棋放下
                all_program[4'd2] <=49'h1_B500_8C00_6E80;//第2个磁吸开
                all_program[4'd3] <=49'h1_B500_8C00_8800;//第2个下棋抬起
            end
            3: begin
                //第3个下棋
                all_program[4'd0] <=49'h0_B500_AC00_8800;//第3个下棋抬起
                all_program[4'd1] <=49'h0_B500_AC00_6E80;//第3个下棋放下
                all_program[4'd2] <=49'h1_B500_AC00_6E80;//第3个磁吸开
                all_program[4'd3] <=49'h1_B500_AC00_8800;//第3个下棋抬起
            end
            4: begin
                //第4个下棋
                all_program[4'd0] <=49'h0_9000_6C00_8800;//第4个下棋抬起
                all_program[4'd1] <=49'h0_9000_6C00_6E80;//第4个下棋放下
                all_program[4'd2] <=49'h1_9000_6C00_6E80;//第4个磁吸开
                all_program[4'd3] <=49'h1_9000_6C00_8800;//第4个下棋抬起
            end
            5: begin
                //第5个下棋
                all_program[4'd0] <=49'h0_9000_8C00_8800;//第5个下棋抬起
                all_program[4'd1] <=49'h0_9000_8C00_6E80;//第5个下棋放下
                all_program[4'd2] <=49'h1_9000_8C00_6E80;//第5个磁吸开
                all_program[4'd3] <=49'h1_9000_8C00_8800;//第5个下棋抬起
            end
            6: begin
                //第6个下棋
                all_program[4'd0] <=49'h0_9000_AC00_8800;//第6个下棋抬起
                all_program[4'd1] <=49'h0_9000_AC00_6E80;//第6个下棋放下
                all_program[4'd2] <=49'h1_9000_AC00_6E80;//第6个磁吸开
                all_program[4'd3] <=49'h1_9000_AC00_8800;//第6个下棋抬起
            end
            7: begin
                //第7个下棋
                all_program[4'd0] <=49'h0_7500_6C00_8800;//第7个下棋抬起
                all_program[4'd1] <=49'h0_7500_6C00_6E80;//第7个下棋放下
                all_program[4'd2] <=49'h1_7500_6C00_6E80;//第7个磁吸开
                all_program[4'd3] <=49'h1_7500_6C00_8800;//第7个下棋抬起
            end
            8: begin
                //第8个下棋
                all_program[4'd0] <=49'h0_7500_8C00_8800;//第8个下棋抬起
                all_program[4'd1] <=49'h0_7500_8C00_6E80;//第8个下棋放下
                all_program[4'd2] <=49'h1_7500_8C00_6E80;//第8个磁吸开
                all_program[4'd3] <=49'h1_7500_8C00_8800;//第8个下棋抬起
            end
            9: begin
                //第9个下棋
                all_program[4'd0] <=49'h0_7500_AC00_8800;//第9个下棋抬起
                all_program[4'd1] <=49'h0_7500_AC00_6E80;//第9个下棋放下
                all_program[4'd2] <=49'h1_7500_AC00_6E80;//第9个磁吸开
                all_program[4'd3] <=49'h1_7500_AC00_8800;//第9个下棋抬起
            end
            default: ;
        endcase
        motor_program_cnt<=4'd0;
    end
    else if(motor_ready_all==1'b1)begin
        goal_pulse_x_auto <= (all_program[motor_program_cnt]>>32  ) & 16'hffff;       
        goal_pulse_y_auto <= (all_program[motor_program_cnt]>>16  ) & 16'hffff;
        goal_pulse_z_auto <= (all_program[motor_program_cnt]      ) & 16'hffff;
        catch_en          <= (all_program[motor_program_cnt]>>48  ) & 1'b1; 
        if (motor_program_cnt < 4'd10)
            motor_program_cnt<=motor_program_cnt+1'b1;
        else 
            motor_program_cnt<=motor_program_cnt;
    end
    
end

ila_4 motor_program_ila (
	.clk(sys_clk), // input wire clk


	.probe0(goal_pulse_x_handset), // input wire [15:0]  probe0  
	.probe1(goal_pulse_y_handset), // input wire [15:0]  probe1 
	.probe2(goal_pulse_z_handset), // input wire [15:0]  probe2 
	.probe3(goal_pulse_x_auto), // input wire [15:0]  probe3 
	.probe4(goal_pulse_y_auto), // input wire [15:0]  probe4 
	.probe5(goal_pulse_z_auto), // input wire [15:0]  probe5 
	.probe6(goal_pulse_x), // input wire [15:0]  probe6 
	.probe7(goal_pulse_y), // input wire [15:0]  probe7 
	.probe8(goal_pulse_z), // input wire [15:0]  probe8 
	.probe9(motor_program_cnt), // input wire [3:0]  probe9 
	.probe10(goal_pulse_handset_en), // input wire [0:0]  probe10
    .probe11(motor_program_clk), // input wire [0:0]  probe11 
	.probe12(motor_start), // input wire [0:0]  probe12 
	.probe13(motor_ready_all), // input wire [0:0]  probe13 
	.probe14(motor_ready_x), // input wire [0:0]  probe14 
	.probe15(motor_ready_y), // input wire [0:0]  probe15 
	.probe16(motor_ready_z), // input wire [0:0]  probe16
    .probe17(motor_start_pos), // input wire [1:0]  probe17 
	.probe18(motor_end_pos), // input wire [3:0]  probe18 
	.probe19(motor_start) // input wire [0:0]  probe19
);
endmodule