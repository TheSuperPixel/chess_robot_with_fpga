// Descriptions:        电机驱动

module motor_driver(
    input               sys_clk,
    input               sys_rst_n,
    input [1:0] calibration_flag,
    input  [15:0]       goal_pulse, 
    output reg [15:0]   now_pulse,   
    output reg          dir_out,     // 方向控制信号 Y7
    output              pwm_out,      // PWM控制信号  Y8
    output reg          motor_ready
);

// 定义计数器的最大值，用于100us延迟
parameter MAX_COUNT = 5000 - 1;

// 定义计数器
reg [12:0] pwm_count; // 13位来存储最大值
reg        pwm_clk;
assign pwm_out = pwm_clk & pwm_en;

//-----------------main code-----------------------------

//pwm时钟控制，每100us翻转一次电平
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pwm_clk <= 1'b0;
        pwm_count <= 1'b0;
    end 
    else if (pwm_count > MAX_COUNT) begin
        pwm_clk <= ~pwm_clk; // 翻转PWM信号
        pwm_count <= 1'b0;  // 重置计数器
    end 
    else 
        pwm_count <= pwm_count + 1'b1; // 增加计数器
end

reg pwm_en;
reg calibration_already;
always @(posedge pwm_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)begin
        now_pulse<=16'd32768;
        calibration_already<=1'b0;
        motor_ready<=1'b0;
    end 
    else if(calibration_already==1'b0)begin
        if(calibration_flag==2'd1)begin
            dir_out <= 1'b1;
            pwm_en <= 1'b1;
            calibration_already<=1'b0;
            motor_ready<=1'b0;
        end
        else if(calibration_flag==2'd2)begin
            dir_out <= 1'b0;
            pwm_en <= 1'b1;
            calibration_already<=1'b0;
            motor_ready<=1'b0;
        end
        else if(calibration_flag==2'd0)begin
            calibration_already<=1'b1;
            motor_ready<=1'b0;
        end
    end
    else if(calibration_already==1'b1)begin
        if(now_pulse==goal_pulse)begin
            pwm_en<=1'b0;
            motor_ready<=1'b1;
        end
        else if(now_pulse>goal_pulse)begin
            pwm_en<=1'b1;
            dir_out<=1'b1;
            now_pulse<=now_pulse-1'b1;
            motor_ready<=1'b0;
        end
        else if(now_pulse<goal_pulse)begin
            pwm_en<=1'b1;
            dir_out<=1'b0;
            now_pulse<=now_pulse+1'b1;
            motor_ready<=1'b0;
        end
    end
end
endmodule
