// Descriptions:       chess_robot

module chess_robot(    
    input                 sys_clk      ,  //系统时钟
    input                 sys_rst_n    ,  //系统复位，低电平有效
    //摄像头接口                       
    input                 cam_pclk     ,  //cmos 数据像素时钟
    input                 cam_vsync    ,  //cmos 场同步信号
    input                 cam_href     ,  //cmos 行同步信号
    input   [7:0]         cam_data     ,  //cmos 数据
    output                cam_rst_n    ,  //cmos 复位信号，低电平有效
    output                cam_pwdn ,      //电源休眠模式选择 0：正常模式 1：电源休眠模式
    output                cam_scl      ,  //cmos SCCB_SCL线
    inout                 cam_sda      ,  //cmos SCCB_SDA线       
    // DDR3                            
    inout   [15:0]        ddr3_dq      ,  //DDR3 数据
    inout   [1:0]         ddr3_dqs_n   ,  //DDR3 dqs负
    inout   [1:0]         ddr3_dqs_p   ,  //DDR3 dqs正  
    output  [13:0]        ddr3_addr    ,  //DDR3 地址   
    output  [2:0]         ddr3_ba      ,  //DDR3 banck 选择
    output                ddr3_ras_n   ,  //DDR3 行选择
    output                ddr3_cas_n   ,  //DDR3 列选择
    output                ddr3_we_n    ,  //DDR3 读写选择
    output                ddr3_reset_n ,  //DDR3 复位
    output  [0:0]         ddr3_ck_p    ,  //DDR3 时钟正
    output  [0:0]         ddr3_ck_n    ,  //DDR3 时钟负
    output  [0:0]         ddr3_cke     ,  //DDR3 时钟使能
    output  [0:0]         ddr3_cs_n    ,  //DDR3 片选
    output  [1:0]         ddr3_dm      ,  //DDR3_dm
    output  [0:0]         ddr3_odt     ,  //DDR3_odt									   
    //lcd接口                           
    output                lcd_hs       ,  //LCD 行同步信号
    output                lcd_vs       ,  //LCD 场同步信号
    output                lcd_de       ,  //LCD 数据输入使能
    inout       [23:0]    lcd_rgb      ,  //LCD 颜色数据
    output                lcd_bl       ,  //LCD 背光控制信号
    output                lcd_rst      ,  //LCD 复位信号
    output                lcd_pclk     ,  //LCD 采样时钟
    
    //my
    input                 key1,

    input   [2:0]   signial_x,
    input   [2:0]   signial_y,
    input   [2:0]   signial_z,

    output dir_out_x,
    output dir_out_y,
    output dir_out_z,
    output pwm_out_x,
    output pwm_out_y,
    output pwm_out_z,

    output catch_en,
    output led1_equal,
    output led2_player_win,
    output led3_machine_win,

    //TOUCH 接口                  
    inout            touch_sda  ,  //TOUCH IIC数据
    output           touch_scl  ,  //TOUCH IIC时钟
    inout            touch_int  ,  //TOUCH INT信号
    output           touch_rst_n  //TOUCH 复位信号

    );                                 
									   							   
//wire define                          
wire         clk_50m                   ;  //50mhz时钟,提供给lcd驱动时钟
wire         locked                    ;  //时钟锁定信号
wire         rst_n                     ;  //全局复位 								    )          				    
wire         wr_en                     ;  //DDR3控制器模块写使能
wire  [15:0] wr_data                   ;  //DDR3控制器模块写数据
wire         rdata_req                 ;  //DDR3控制器模块读使能
wire  [15:0] rd_data                   ;  //DDR3控制器模块读数据
wire         cmos_frame_valid          ;  //数据有效使能信号
wire         init_calib_complete       ;  //DDR3初始化完成init_calib_complete
wire         sys_init_done             ;  //系统初始化完成(DDR初始化+摄像头初始化)
wire         clk_200m                  ;  //ddr3参考时钟
wire         cmos_frame_vsync          ;  //输出帧有效场同步信号
wire         cmos_frame_href           ;  //输出帧有效行同步信号 
wire         lcd_clk                   ;  //分频产生的LCD 采样时钟
wire  [12:0] h_disp                    ;  //LCD屏水平分辨率
wire  [12:0] v_disp                    ;  //LCD屏垂直分辨率     
wire  [10:0] h_pixel                   ;  //存入ddr3的水平分辨率        
wire  [10:0] v_pixel                   ;  //存入ddr3的屏垂直分辨率
wire  [12:0] y_addr_st                 ; 
wire  [12:0] y_addr_end                ; 
wire  [15:0] lcd_id                    ;  //LCD屏的ID号
wire  [27:0] ddr3_addr_max             ;  //存入DDR3的最大读写地址 
wire  [12:0] total_h_pixel             ;  //水平总像素大小 
wire  [12:0] total_v_pixel             ;  //垂直总像素大小
wire  [15:0] post_rgb                  ;  //处理后的图像数据
wire         post_frame_vsync          ;  //处理后的场信号
wire         post_frame_de             ;  //处理后的数据有效使能 
wire  [10:0] pixel_xpos                ;  //像素点横坐标
wire  [10:0] pixel_ypos                ;  //像素点纵坐标  
//*****************************************************
//**                    main code
//*****************************************************
//待时钟锁定后产生复位结束信号
assign  rst_n = sys_rst_n & locked;

//系统初始化完成：DDR3初始化完成
assign  sys_init_done = init_calib_complete;

//摄像头图像分辨率设置模块
picture_size u_picture_size (
    .rst_n              (rst_n),
    .clk                (clk_50m  ),    
    .lcd_id             (lcd_id),           //LCD的器件ID
                        
    .cmos_h_pixel       (h_disp  ),         //摄像头水平分辨率
    .cmos_v_pixel       (v_disp  ),         //摄像头垂直分辨率  
    .total_h_pixel      (total_h_pixel ),   //水平总像素大小
    .total_v_pixel      (total_v_pixel ),   //垂直总像素大小
    .y_addr_st          (y_addr_st ), 
    .y_addr_end         (y_addr_end),
    .ddr3_addr_max      (ddr3_addr_max)     //ddr3最大读写地址
    );
   
 //ov5640 驱动
ov5640_dri u_ov5640_dri(
    .clk               (clk_50m),
    .rst_n             (rst_n),

    .cam_pclk          (cam_pclk ),
    .cam_vsync         (cam_vsync),
    .cam_href          (cam_href ),
    .cam_data          (cam_data ),
    .cam_rst_n         (cam_rst_n),
    .cam_pwdn          (cam_pwdn ),
    .cam_scl           (cam_scl  ),
    .cam_sda           (cam_sda  ),
    
    .capture_start     (init_calib_complete),
    .cmos_h_pixel      (h_disp),
    .cmos_v_pixel      (v_disp),
    .total_h_pixel     (total_h_pixel),
    .total_v_pixel     (total_v_pixel),
    .y_addr_st         (y_addr_st ), 
    .y_addr_end        (y_addr_end),
    .cmos_frame_vsync  (cmos_frame_vsync),
    .cmos_frame_href   (cmos_frame_href),
    .cmos_frame_valid  (cmos_frame_valid),
    .cmos_frame_data   (wr_data)
    );  
    
 //图像处理模块
vip u_vip(
    //module clock
    .clk                   (cam_pclk),          // 时钟信号
    .rst_n                 (rst_n ),            // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync       (cmos_frame_vsync),
    .pre_frame_href        (cmos_frame_href),
    .pre_frame_de          (cmos_frame_valid),
    .pre_rgb               (wr_data),
    //图像处理后的数据接口
    .post_frame_vsync      (post_frame_vsync),  // 处理后的场信号
    .post_frame_href       ( ),                 // 处理后的行信号
    .post_frame_de         (post_frame_de),     // 处理后的数据有效使能 
    .post_rgb              (post_rgb),           // 处理后的图像数据

    .my_threshold_y_up_touch    (my_threshold_y_up_touch   ),
    .my_threshold_y_down_touch  (my_threshold_y_down_touch ),
    .my_threshold_cb_up_touch   (my_threshold_cb_up_touch  ),
    .my_threshold_cb_down_touch (my_threshold_cb_down_touch),
    .my_threshold_cr_up_touch   (my_threshold_cr_up_touch  ),
    .my_threshold_cr_down_touch (my_threshold_cr_down_touch)
);      

//ddr3读写控制模块
ddr3_top u_ddr3_top (
    .rst_n                 (rst_n),                 //复位,低有效
    .init_calib_complete   (init_calib_complete),   //ddr3初始化完成信号    
    //ddr3接口信号         
    .app_addr_rd_min       (28'd0),                 //读DDR3的起始地址
    .app_addr_rd_max       (ddr3_addr_max[27:0]),   //读DDR3的结束地址
    .rd_bust_len           (h_disp[10:4]),          //从DDR3中读数据时的突发长度
    .app_addr_wr_min       (28'd0),                 //写DDR3的起始地址
    .app_addr_wr_max       (ddr3_addr_max[27:0]),   //写DDR3的结束地址
    .wr_bust_len           (h_disp[10:4]),          //从DDR3中写数据时的突发长度
    // DDR3 IO接口                
    .ddr3_dq               (ddr3_dq),               //DDR3 数据
    .ddr3_dqs_n            (ddr3_dqs_n),            //DDR3 dqs负
    .ddr3_dqs_p            (ddr3_dqs_p),            //DDR3 dqs正  
    .ddr3_addr             (ddr3_addr),             //DDR3 地址   
    .ddr3_ba               (ddr3_ba),               //DDR3 banck 选择
    .ddr3_ras_n            (ddr3_ras_n),            //DDR3 行选择
    .ddr3_cas_n            (ddr3_cas_n),            //DDR3 列选择
    .ddr3_we_n             (ddr3_we_n),             //DDR3 读写选择
    .ddr3_reset_n          (ddr3_reset_n),          //DDR3 复位
    .ddr3_ck_p             (ddr3_ck_p),             //DDR3 时钟正
    .ddr3_ck_n             (ddr3_ck_n),             //DDR3 时钟负  
    .ddr3_cke              (ddr3_cke),              //DDR3 时钟使能
    .ddr3_cs_n             (ddr3_cs_n),             //DDR3 片选
    .ddr3_dm               (ddr3_dm),               //DDR3_dm
    .ddr3_odt              (ddr3_odt),              //DDR3_odt
    // System Clock Ports                            
    .sys_clk_i             (clk_200m),   
    // Reference Clock Ports                         
    .clk_ref_i             (clk_200m), 
    //用户
    .ddr3_read_valid       (1'b1),                  //DDR3 读使能
    .ddr3_pingpang_en      (1'b1),                  //DDR3 乒乓操作使能
    .wr_clk                (cam_pclk),              //写时钟
    .wr_load               (post_frame_vsync),      //输入源更新信号   
	.wr_en                 (post_frame_de),         //数据有效使能信号
    .wrdata                (post_rgb),              //有效数据 
    .rd_clk                (lcd_clk),               //读时钟 
    .rd_load               (rd_vsync),              //输出源更新信号    
    .rddata                (rd_data),               //rfifo输出数据
    .rdata_req             (rdata_req)              //请求数据输入     
     );                

 clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1              (clk_200m),     
    .clk_out2              (clk_50m),
    // Status and control signals
    .reset                 (~sys_rst_n), 
    .locked                (locked),       
   // Clock in ports
    .clk_in1               (sys_clk)
    );     

//LCD驱动显示模块
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (clk_50m),
    .sys_rst_n             (rst_n ),
	.sys_init_done         (sys_init_done),		
				           
    //lcd接口 				           
    .lcd_id                (lcd_id),                //LCD屏的ID号 
    .lcd_hs                (lcd_hs),                //LCD 行同步信号
    .lcd_vs                (lcd_vs),                //LCD 场同步信号
    .lcd_de                (lcd_de),                //LCD 数据输入使能
    .lcd_rgb               (lcd_rgb),               //LCD 颜色数据
    .lcd_bl                (lcd_bl),                //LCD 背光控制信号
    .lcd_rst               (lcd_rst),               //LCD 复位信号
    .lcd_pclk              (lcd_pclk),              //LCD 采样时钟
    .lcd_clk               (lcd_clk), 	            //LCD 驱动时钟
	//用户接口			           
    .out_vsync             (rd_vsync),              //lcd场信号
    .h_disp                (),                      //行分辨率  
    .v_disp                (),                      //场分辨率  
    .pixel_xpos            (pixel_xpos),
    .pixel_ypos            (pixel_ypos),       
    .data_in               (rd_data),	            //rfifo输出数据
    .data_req              (rdata_req),              //请求数据输入
    .my_full1_detect       (my_full1_detect),
    .my_full2_detect       (my_full2_detect),
    .my_full3_detect       (my_full3_detect),
    .my_full4_detect       (my_full4_detect),
    .my_full5_detect       (my_full5_detect),
    .my_full6_detect       (my_full6_detect),
    .my_full7_detect       (my_full7_detect),
    .my_full8_detect       (my_full8_detect),
    .my_full9_detect       (my_full9_detect),
    .my_full1_store        (my_full1_store),
    .my_full2_store        (my_full2_store),
    .my_full3_store        (my_full3_store),
    .my_full4_store        (my_full4_store),
    .my_full5_store        (my_full5_store),
    .my_full6_store        (my_full6_store),
    .my_full7_store        (my_full7_store),
    .my_full8_store        (my_full8_store),
    .my_full9_store        (my_full9_store),
    .my_threshold_y_up_touch    (my_threshold_y_up_touch   ),
    .my_threshold_y_down_touch  (my_threshold_y_down_touch ),
    .my_threshold_cb_up_touch   (my_threshold_cb_up_touch  ),
    .my_threshold_cb_down_touch (my_threshold_cb_down_touch),
    .my_threshold_cr_up_touch   (my_threshold_cr_up_touch  ),
    .my_threshold_cr_down_touch (my_threshold_cr_down_touch),
    .win_shape(win_shape),
    .machine_full_1 (Reset_1),
    .machine_full_2 (Reset_2),
    .machine_full_3 (Reset_3),
    .machine_full_4 (Reset_4),
    .win_flag(win_flag),
    .motor_reset_touch(motor_reset_touch)
    );   

//9个位置检测实时信号
wire my_full1_detect;
wire my_full2_detect;
wire my_full3_detect;
wire my_full4_detect;
wire my_full5_detect;
wire my_full6_detect;
wire my_full7_detect;
wire my_full8_detect;
wire my_full9_detect;

//9个位置检测打1拍信号
reg my_full1_d1;
reg my_full2_d1;
reg my_full3_d1;
reg my_full4_d1;
reg my_full5_d1;
reg my_full6_d1;
reg my_full7_d1;
reg my_full8_d1;
reg my_full9_d1;

//检测状态
reg [2:0] detect_state;
parameter	WAIT_MOTOR_START    = 3'd0;//等待电机开始运动
parameter	WAIT_MOTOR_END      = 3'd1;//等待电机运动完
parameter	WAIT_PLAYER_SET     = 3'd2;//等待棋子被放置
parameter   WAIT_PLAYER_DONE    = 3'd3;//等待棋子放好了并且一段时间内不改变
parameter	WAIT_LOGIC_DONE     = 3'd4;//等待logic模块完成

//自动识别棋子是否被放置
reg [28:0] detect_cnt;
reg detect_done;
wire motor_done;
always @(posedge clk_50m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        detect_cnt<=0;
        detect_state<=0;
        detect_done<=0;
    end
    else begin
        case (detect_state)
            WAIT_MOTOR_START:begin//等待电机开始运动
                if (motor_done == 1'b0) begin
                    detect_state<= WAIT_MOTOR_END;
                end
            end
            WAIT_MOTOR_END:begin//等待电机运动完
                if (motor_done == 1'b1) begin
                    my_full1_d1 <= my_full1_detect;
                    my_full2_d1 <= my_full2_detect;
                    my_full3_d1 <= my_full3_detect;
                    my_full4_d1 <= my_full4_detect;
                    my_full5_d1 <= my_full5_detect;
                    my_full6_d1 <= my_full6_detect;
                    my_full7_d1 <= my_full7_detect;
                    my_full8_d1 <= my_full8_detect;
                    my_full9_d1 <= my_full9_detect;
                    detect_state<= WAIT_PLAYER_SET;
                end
            end
            WAIT_PLAYER_SET:begin//等待棋子被放置
                if((win_flag==2'd0)&&((my_full1_detect!=my_full1_d1) || (my_full2_detect!=my_full2_d1) || (my_full3_detect!=my_full3_d1) || (my_full4_detect!=my_full4_d1) || (my_full5_detect!=my_full5_d1) || (my_full6_detect!=my_full6_d1) || (my_full7_detect!=my_full7_d1) || (my_full8_detect!=my_full8_d1) || (my_full9_detect!=my_full9_d1))) begin
                    detect_state<= WAIT_PLAYER_DONE;
                    detect_cnt<=0;
                end
            end
            WAIT_PLAYER_DONE:begin//等待棋子放好了并且一段时间内不改变
                if (detect_cnt<28'd1_000_000_000) begin
                    if ((my_full1_detect==my_full1_d1) && (my_full2_detect==my_full2_d1) && (my_full3_detect==my_full3_d1) && (my_full4_detect==my_full4_d1) && (my_full5_detect==my_full5_d1) && (my_full6_detect==my_full6_d1) && (my_full7_detect==my_full7_d1) && (my_full8_detect==my_full8_d1) && (my_full9_detect==my_full9_d1)) begin
                        detect_cnt<=detect_cnt+1'b1;
                        if (detect_cnt>28'd999_999_000) begin
                            detect_done<=1;
                            detect_cnt<=0;
                            detect_state<= WAIT_LOGIC_DONE;
                        end
                    end
                    else begin
                        detect_cnt<=0;
                        my_full1_d1 <= my_full1_detect;
                        my_full2_d1 <= my_full2_detect;
                        my_full3_d1 <= my_full3_detect;
                        my_full4_d1 <= my_full4_detect;
                        my_full5_d1 <= my_full5_detect;
                        my_full6_d1 <= my_full6_detect;
                        my_full7_d1 <= my_full7_detect;
                        my_full8_d1 <= my_full8_detect;
                        my_full9_d1 <= my_full9_detect;
                    end
                end
                else 
                    detect_cnt<=0;
            end
            WAIT_LOGIC_DONE:begin//等待logic模块完成
                detect_done<=0;
                if (motor_start==1'b1) begin
                    detect_state<= WAIT_MOTOR_START;
                end    
            end
            default: ;
        endcase
    end
end

//logic模块生成输入9个棋子位置信息
reg my_full1_store;
reg my_full2_store;
reg my_full3_store;
reg my_full4_store;
reg my_full5_store;
reg my_full6_store;
reg my_full7_store;
reg my_full8_store;
reg my_full9_store;

reg detect_done_d0;
reg detect_done_d1;
wire player_ready_flag;
assign player_ready_flag = detect_done_d1 && (!detect_done_d0);

always @(posedge clk_50m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        my_full1_store<=1'b0;
        my_full2_store<=1'b0;
        my_full3_store<=1'b0;
        my_full4_store<=1'b0;
        my_full5_store<=1'b0;
        my_full6_store<=1'b0;
        my_full7_store<=1'b0;
        my_full8_store<=1'b0;
        my_full9_store<=1'b0;
    end
    else if(player_ready_flag==1'b1)begin
        my_full1_store <= my_full1_detect;
        my_full2_store <= my_full2_detect;
        my_full3_store <= my_full3_detect;
        my_full4_store <= my_full4_detect;
        my_full5_store <= my_full5_detect;
        my_full6_store <= my_full6_detect;
        my_full7_store <= my_full7_detect;
        my_full8_store <= my_full8_detect;
        my_full9_store <= my_full9_detect; 
    end
    else begin
        my_full1_store <= my_full1_store;
        my_full2_store <= my_full2_store;
        my_full3_store <= my_full3_store;
        my_full4_store <= my_full4_store;
        my_full5_store <= my_full5_store;
        my_full6_store <= my_full6_store;
        my_full7_store <= my_full7_store;
        my_full8_store <= my_full8_store;
        my_full9_store <= my_full9_store; 
    end
end

// player_ready_flag打拍
reg player_ready_flag_d1;
reg player_ready_flag_d2;
reg player_ready_flag_d3;
reg player_ready_flag_d4;
reg player_ready_flag_d5;
reg player_ready_flag_d6;
reg player_ready_flag_d7;
reg player_ready_flag_d8;
always @(posedge clk_50m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        detect_done_d0<=0;
        detect_done_d1<=0;
        player_ready_flag_d1<=0;
        player_ready_flag_d2<=0;
        player_ready_flag_d3<=0;
        player_ready_flag_d4<=0;
        player_ready_flag_d5<=0;
        player_ready_flag_d6<=0;
        player_ready_flag_d7<=0;
        player_ready_flag_d8<=0;
    end
    else begin
        detect_done_d0<=detect_done;
        detect_done_d1<=detect_done_d0;

        player_ready_flag_d1<=player_ready_flag;
        player_ready_flag_d2<=player_ready_flag_d1;
        player_ready_flag_d3<=player_ready_flag_d2;
        player_ready_flag_d4<=player_ready_flag_d3;
        player_ready_flag_d5<=player_ready_flag_d4;
        player_ready_flag_d6<=player_ready_flag_d5;
        player_ready_flag_d7<=player_ready_flag_d6;
        player_ready_flag_d8<=player_ready_flag_d7;
    end
end

//logic模块处理
wire [3:0] motor_flag;
wire [1:0] win_flag;
wire [3:0]Reset_1;
wire [3:0]Reset_2;
wire [3:0]Reset_3;
wire [3:0]Reset_4;
wire [3:0]Reset_A1;
wire [3:0]Reset_A2;
wire [3:0]Reset_A3;
wire [3:0]Reset_A4;
wire [3:0]Reset_A5;
wire [3:0]win_shape;
chess_logic my_chess_logic(
    .sys_clk(clk_50m),
    .sys_rst_n(sys_rst_n),
    .input_A1(my_full1_store),
    .input_A2(my_full2_store),
    .input_A3(my_full3_store),
    .input_A4(my_full4_store),
    .input_A5(my_full5_store),
    .input_A6(my_full6_store),
    .input_A7(my_full7_store),
    .input_A8(my_full8_store),
    .input_A9(my_full9_store),
    .ready_flag(player_ready_flag),   //玩家按键按下，图像识别完毕
    
    .motor_flag(motor_flag), //输出信号给控制电朿 d1~d9
    .win_flag(win_flag),

    .Reset_1(Reset_1),
    .Reset_2(Reset_2),
    .Reset_3(Reset_3),
    .Reset_4(Reset_4),

    .Reset_A1(Reset_A1),
    .Reset_A2(Reset_A2),
    .Reset_A3(Reset_A3),
    .Reset_A4(Reset_A4),
    .Reset_A5(Reset_A5),
    .win_shape(win_shape)
);

//logic模块输出win_flag处理
assign led1_equal = (win_flag==2'd1)? 1:0;
assign led2_player_win = (win_flag==2'd2)? 1:0;
assign led3_machine_win = (win_flag==2'd3)? 1:0;


reg  [2:0]  motor_start_pos;
reg  [3:0]  motor_end_pos;
reg         motor_start;
reg [28:0]  motor_program_disable_cnt;

//确定电机开始位置和motor_start信号生成
always @(posedge clk_50m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        motor_start_pos<=0;
        motor_end_pos<=0;
    end
    else if (player_ready_flag_d1) begin
        motor_start_pos<=motor_start_pos+1;
    end
    else if(motor_flag!=0)begin
        motor_end_pos<=motor_flag;
    end
    else if((player_ready_flag_d8==1) && (motor_start_pos<=3'd4))begin
        motor_start<=1;
    end
    else if(motor_program_disable_cnt==1'b1)begin
        motor_start<=0;
    end 
end

//motor_start信号生成
always @(posedge clk_50m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        motor_program_disable_cnt<=0;
    end
    else if (motor_program_disable_cnt!=0)begin
        motor_program_disable_cnt<=motor_program_disable_cnt-1'b1;
    end
    else if ((motor_start == 1) || (motor_start2 == 1))begin
        motor_program_disable_cnt<=28'd1000_0000;
    end
end

wire catch_en;
motor_top u_motor_top(
    .sys_clk(clk_50m),
    .sys_rst_n(sys_rst_n),

    .signial_x(signial_x),
    .signial_y(signial_y),
    .signial_z(signial_z),

    .motor_start_pos(motor_start_pos),
    .motor_end_pos(motor_end_pos),
    .motor_start(motor_start),

    .motor_start_pos2(motor_start_pos2),
    .motor_end_pos2(motor_end_pos2),
    .motor_start2(motor_start2),

    .dir_out_x(dir_out_x),
    .dir_out_y(dir_out_y),
    .dir_out_z(dir_out_z),
    .pwm_out_x(pwm_out_x),
    .pwm_out_y(pwm_out_y),
    .pwm_out_z(pwm_out_z),
    .catch_en(catch_en),
    .motor_done(motor_done)

);

ila_2 chess_logic_output_ila (
	.clk(clk_50m), // input wire clk

	.probe0(my_full1_detect), // input wire [0:0]  probe0  
	.probe1(my_full2_detect), // input wire [0:0]  probe1 
	.probe2(my_full3_detect), // input wire [0:0]  probe2 
	.probe3(my_full4_detect), // input wire [0:0]  probe3 
	.probe4(my_full5_detect), // input wire [0:0]  probe4 
	.probe5(my_full6_detect), // input wire [0:0]  probe5 
	.probe6(my_full7_detect), // input wire [0:0]  probe6 
	.probe7(my_full8_detect), // input wire [0:0]  probe7 
	.probe8(my_full9_detect), // input wire [0:0]  probe8 
	.probe9(detect_done), // input wire [0:0]  probe9 
	.probe10(detect_done_d0), // input wire [0:0]  probe10 
	.probe11(detect_done_d1), // input wire [0:0]  probe11 
	.probe12(player_ready_flag), // input wire [0:0]  probe12 
	.probe13(motor_flag), // input wire [3:0]  probe13
    .probe14(motor_start_pos), // input wire [2:0]  probe14 
	.probe15(motor_end_pos), // input wire [3:0]  probe15 
	.probe16(motor_start), // input wire [0:0]  probe16
    .probe17(win_flag), // input wire [1:0]  probe17
    .probe18(detect_state), // input wire [2:0]  probe18 
	.probe19(motor_done), // input wire [0:0]  probe19 
	.probe20(detect_cnt), // input wire [28:0]  probe20 
    .probe21(Reset_1), // input wire [3:0]  probe21 
	.probe22(Reset_2), // input wire [3:0]  probe22 
	.probe23(Reset_3), // input wire [3:0]  probe23 
	.probe24(Reset_4), // input wire [3:0]  probe24
    .probe25(reset_state), // input wire [3:0]  probe25 
	.probe26(motor_start_pos2), // input wire [3:0]  probe26 
	.probe27(motor_end_pos2),  // input wire [3:0]  probe27 
	.probe28(motor_start2), // input wire [0:0]  probe28
    .probe29(motor_program_disable_cnt), // input wire [28:0]  probe29
    .probe30(Reset_A1), // input wire [3:0]  probe30 
	.probe31(Reset_A2), // input wire [3:0]  probe31 
	.probe32(Reset_A3), // input wire [3:0]  probe32 
	.probe33(Reset_A4), // input wire [3:0]  probe33 
	.probe34(Reset_A5), // input wire [3:0]  probe34
    .probe35(touch_data) // input wire [31:0]  probe35
);

//棋子复位逻辑
reg [3:0] reset_state;
reg  [3:0]  motor_start_pos2;
reg  [3:0]  motor_end_pos2;
reg         motor_start2;
//棋子复位开始信号处理
wire reset_start;
wire motor_reset_touch;
assign reset_start = (!key1 || motor_reset_touch ) == 1'b1 ? 1 : 0 ;
always @(posedge clk_50m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        reset_state<=4'd0;
        motor_start2<=0;
    end
    else if(motor_program_disable_cnt==29'b1)begin
        motor_start2<=0;
    end
    else if (reset_start==1'b1) begin
        reset_state<=4'd1;
        motor_start2<=1'b1;
    end
    else if ((motor_done==1'b1)&&((reset_state==4'd1)||(reset_state==4'd2)||(reset_state==4'd3)||(reset_state==4'd4)||(reset_state==4'd5)||(reset_state==4'd6)||(reset_state==4'd7)||(reset_state==4'd8))&&(motor_start2==1'b0)) begin
        reset_state<=reset_state+1;
        motor_start2<=1'b1;
    end
    else if(reset_state==4'd9)begin
        reset_state<=4'd0;
        motor_start2<=1'b1;
    end
    else begin
        reset_state<=reset_state;
        motor_start2<=motor_start2;
    end
    case (reset_state)
        4'd1: begin
            motor_start_pos2<=Reset_1;
            motor_end_pos2<=(Reset_1!=0)? 1:0;
        end
        4'd2: begin
            motor_start_pos2<=Reset_2;
            motor_end_pos2<=(Reset_2!=0)? 2:0;
        end
        4'd3: begin
            motor_start_pos2<=Reset_3;
            motor_end_pos2<=(Reset_3!=0)? 3:0;
        end
        4'd4: begin
            motor_start_pos2<=Reset_4;
            motor_end_pos2<=(Reset_4!=0)? 4:0;
        end

        4'd5: begin
            motor_start_pos2<=Reset_A1;
            motor_end_pos2<=(Reset_A1!=0)? 5:0;
        end
        4'd6: begin
            motor_start_pos2<=Reset_A2;
            motor_end_pos2<=(Reset_A2!=0)? 6:0;
        end
        4'd7: begin
            motor_start_pos2<=Reset_A3;
            motor_end_pos2<=(Reset_A3!=0)? 7:0;
        end
        4'd8: begin
            motor_start_pos2<=Reset_A4;
            motor_end_pos2<=(Reset_A4!=0)? 8:0;
        end
        4'd9: begin
            motor_start_pos2<=Reset_A5;
            motor_end_pos2<=(Reset_A5!=0)? 9:0;
        end
        default: ;
    endcase
end

//触摸驱动顶层模块   
wire [31:0] touch_data; 
touch_top  u_touch_top(
    .clk            (clk_50m    ),
    .rst_n          (sys_rst_n  ),

    .touch_rst_n    (touch_rst_n),
    .touch_int      (touch_int  ),
    .touch_scl      (touch_scl  ),
    .touch_sda      (touch_sda  ),
    
    .lcd_id         (lcd_id     ),
    .data           (touch_data)
);

// 触摸解算算法
wire [7:0] my_threshold_y_up_touch    ;
wire [7:0] my_threshold_y_down_touch  ;
wire [7:0] my_threshold_cb_up_touch   ;
wire [7:0] my_threshold_cb_down_touch ;
wire [7:0] my_threshold_cr_up_touch   ;
wire [7:0] my_threshold_cr_down_touch ;
touch_solve my_touch_solve(
    .clk(clk_50m),
    .rst_n(sys_rst_n),
    .touch_data(touch_data),
    .my_threshold_y_up_touch    (my_threshold_y_up_touch   ) ,
    .my_threshold_y_down_touch  (my_threshold_y_down_touch ) ,
    .my_threshold_cb_up_touch   (my_threshold_cb_up_touch  ) ,
    .my_threshold_cb_down_touch (my_threshold_cb_down_touch) ,
    .my_threshold_cr_up_touch   (my_threshold_cr_up_touch  ) ,
    .my_threshold_cr_down_touch (my_threshold_cr_down_touch) ,
    .motor_reset_touch          (motor_reset_touch)
);
endmodule