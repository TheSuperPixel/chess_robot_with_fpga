// Descriptions:        电机顶层

module motor_top(
    input sys_clk,
    input sys_rst_n,

    input   [2:0]   signial_x,
    input   [2:0]   signial_y,
    input   [2:0]   signial_z,

    input  [2:0]  motor_start_pos,
    input  [3:0]  motor_end_pos,
    input         motor_start,

    input  [3:0]  motor_start_pos2,
    input  [3:0]  motor_end_pos2,
    input         motor_start2,

    output dir_out_x,
    output dir_out_y,
    output dir_out_z,
    output pwm_out_x,
    output pwm_out_y,
    output pwm_out_z,
    output catch_en,
    output motor_done

);
wire motor_program_done;
assign motor_done = motor_ready_x && motor_ready_y && motor_ready_z && motor_program_done;

wire  [1:0] motor_flag_x;
wire  [1:0] motor_flag_y;
wire  [1:0] motor_flag_z;

wire motor_ready_x;
wire motor_ready_y;
wire motor_ready_z;
motor_reset  u_motor_reset_x(
    .sys_clk       (sys_clk      ),
    .sys_rst_n     (sys_rst_n    ),
    .signial       (signial_x    ),
    .motor_flag    (motor_flag_x )
    );
    
motor_reset  u_motor_reset_y(
    .sys_clk       (sys_clk      ),
    .sys_rst_n     (sys_rst_n    ),
    .signial       (signial_y    ),
    .motor_flag    (motor_flag_y )
    );
    
motor_reset  u_motor_reset_z(
    .sys_clk       (sys_clk      ),
    .sys_rst_n     (sys_rst_n    ),
    .signial       (signial_z    ),
    .motor_flag    (motor_flag_z )
    );

wire  [15:0]   goal_pulse_x;
wire  [15:0]   goal_pulse_y;
wire  [15:0]   goal_pulse_z;
wire  [15:0]   now_pulse_x;  
wire  [15:0]   now_pulse_y; 
wire  [15:0]   now_pulse_z; 
wire catch_en;

motor_driver my_motor_x(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .calibration_flag(motor_flag_x),
    .goal_pulse (goal_pulse_x),
    .now_pulse  (now_pulse_x),        
    .dir_out    (dir_out_x),     // 方向控制信号 Y7
    .pwm_out    (pwm_out_x),      // PWM控制信号  Y8
    .motor_ready   (motor_ready_x)
);

motor_driver my_motor_y(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .calibration_flag(motor_flag_y),
    .goal_pulse (goal_pulse_y),
    .now_pulse  (now_pulse_y),        
    .dir_out    (dir_out_y),     // 方向控制信号 Y7
    .pwm_out    (pwm_out_y),      // PWM控制信号  Y8
    .motor_ready   (motor_ready_y)
);
motor_driver my_motor_z(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .calibration_flag(motor_flag_z),
    .goal_pulse (goal_pulse_z),
    .now_pulse  (now_pulse_z),        
    .dir_out    (dir_out_z),     // 方向控制信号 Y7
    .pwm_out    (pwm_out_z),      // PWM控制信号  Y8
    .motor_ready   (motor_ready_z)
);

ila_0 motor_pos_ila (
	.clk(sys_clk), // input wire clk


	.probe0(goal_pulse_x), // input wire [15:0]  probe0  
	.probe1(now_pulse_x), // input wire [15:0]  probe1 
	.probe2(goal_pulse_y), // input wire [15:0]  probe2 
	.probe3(now_pulse_y), // input wire [15:0]  probe3 
	.probe4(goal_pulse_z), // input wire [15:0]  probe4 
	.probe5(now_pulse_z), // input wire [15:0]  probe5 
	.probe6(motor_flag_x), // input wire [1:0]  probe6 
	.probe7(motor_flag_y), // input wire [1:0]  probe7 
	.probe8(motor_flag_z), // input wire [1:0]  probe8
    .probe9(signial_x), // input wire [2:0]  probe9 
	.probe10(signial_y), // input wire [2:0]  probe10 
	.probe11(signial_z) // input wire [2:0]  probe11
);

wire  [2:0]  motor_start_pos;
wire  [3:0]  motor_end_pos;
wire         motor_start;

control my_control(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .motor_ready_x(motor_ready_x),
    .motor_ready_y(motor_ready_y),
    .motor_ready_z(motor_ready_z),

    .motor_start_pos(motor_start_pos),
    .motor_end_pos(motor_end_pos),
    .motor_start(motor_start),

    .motor_start_pos2(motor_start_pos2),
    .motor_end_pos2(motor_end_pos2),
    .motor_start2(motor_start2),

    .goal_pulse_x(goal_pulse_x),
    .goal_pulse_y(goal_pulse_y),
    .goal_pulse_z(goal_pulse_z),
    .catch_en(catch_en),
    .motor_program_done (motor_program_done)
    
);


endmodule