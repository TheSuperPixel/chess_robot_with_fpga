// Descriptions:        lcd驱动模块

module lcd_driver(
    input               lcd_clk,      //lcd模块驱动时钟
    input               sys_clk,
    input               rst_n,        //复位信号
    input   [15:0]      lcd_id,       //LCD屏ID
    input   [15:0]      pixel_data,   //像素点数据
    output  reg         data_req  ,   //请求像素点颜色数据输入 
    output  reg [10:0]  pixel_xpos,   //像素点横坐标
    output  reg [10:0]  pixel_ypos,   //像素点纵坐标
    output  reg [10:0]  h_disp,       //LCD屏水平分辨率
    output  reg [10:0]  v_disp,       //LCD屏垂直分辨率 
    output              out_vsync,    //帧复位，高有效   
    //RGB LCD接口                          
    output              lcd_hs,       //LCD 行同步信号
    output              lcd_vs,       //LCD 场同步信号
    output  reg         lcd_de,       //LCD 数据输入使能
    output  [15:0]      lcd_rgb,      //LCD RGB565颜色数据
    output              lcd_bl,       //LCD 背光控制信号
    output              lcd_rst,      //LCD 复位信号
    output              lcd_pclk,      //LCD 采样时钟   

    output reg my_full1_detect,
    output reg my_full2_detect,
    output reg my_full3_detect,
    output reg my_full4_detect,
    output reg my_full5_detect,
    output reg my_full6_detect,
    output reg my_full7_detect,
    output reg my_full8_detect,
    output reg my_full9_detect,

    input my_full1_store,
    input my_full2_store,
    input my_full3_store,
    input my_full4_store,
    input my_full5_store,
    input my_full6_store,
    input my_full7_store,
    input my_full8_store,
    input my_full9_store,

    input [7:0] my_threshold_y_up_touch    ,
    input [7:0] my_threshold_y_down_touch  ,
    input [7:0] my_threshold_cb_up_touch   ,
    input [7:0] my_threshold_cb_down_touch ,
    input [7:0] my_threshold_cr_up_touch   ,
    input [7:0] my_threshold_cr_down_touch ,
    input [3:0] win_shape,
    input [3:0] machine_full_1 ,
    input [3:0] machine_full_2 ,
    input [3:0] machine_full_3 ,
    input [3:0] machine_full_4 ,
    input [1:0] win_flag,
    input motor_reset_touch
    );                             
                                                        
//parameter define  
// 4.3' 480*272
parameter  H_SYNC_4342   =  11'd41;     //行同步
parameter  H_BACK_4342   =  11'd2;      //行显示后沿
parameter  H_DISP_4342   =  11'd480;    //行有效数据
parameter  H_FRONT_4342  =  11'd2;      //行显示前沿
parameter  H_TOTAL_4342  =  11'd525;    //行扫描周期
   
parameter  V_SYNC_4342   =  11'd10;     //场同步
parameter  V_BACK_4342   =  11'd2;      //场显示后沿
parameter  V_DISP_4342   =  11'd272;    //场有效数据
parameter  V_FRONT_4342  =  11'd2;      //场显示前沿
parameter  V_TOTAL_4342  =  11'd286;    //场扫描周期
   
// 7' 800*480   
parameter  H_SYNC_7084   =  11'd128;    //行同步
parameter  H_BACK_7084   =  11'd88;     //行显示后沿
parameter  H_DISP_7084   =  11'd800;    //行有效数据
parameter  H_FRONT_7084  =  11'd40;     //行显示前沿
parameter  H_TOTAL_7084  =  11'd1056;   //行扫描周期
   
parameter  V_SYNC_7084   =  11'd2;      //场同步
parameter  V_BACK_7084   =  11'd33;     //场显示后沿
parameter  V_DISP_7084   =  11'd480;    //场有效数据
parameter  V_FRONT_7084  =  11'd10;     //场显示前沿
parameter  V_TOTAL_7084  =  11'd525;    //场扫描周期       
   
// 7' 1024*600   
parameter  H_SYNC_7016   =  11'd20;     //行同步
parameter  H_BACK_7016   =  11'd140;    //行显示后沿
parameter  H_DISP_7016   =  11'd1024;   //行有效数据
parameter  H_FRONT_7016  =  11'd160;    //行显示前沿
parameter  H_TOTAL_7016  =  11'd1344;   //行扫描周期
   
parameter  V_SYNC_7016   =  11'd3;      //场同步
parameter  V_BACK_7016   =  11'd20;     //场显示后沿
parameter  V_DISP_7016   =  11'd600;    //场有效数据
parameter  V_FRONT_7016  =  11'd12;     //场显示前沿
parameter  V_TOTAL_7016  =  11'd635;    //场扫描周期
   
// 10.1' 1280*800   
parameter  H_SYNC_1018   =  11'd10;     //行同步
parameter  H_BACK_1018   =  11'd80;     //行显示后沿
parameter  H_DISP_1018   =  11'd1280;   //行有效数据
parameter  H_FRONT_1018  =  11'd70;     //行显示前沿
parameter  H_TOTAL_1018  =  11'd1440;   //行扫描周期
   
parameter  V_SYNC_1018   =  11'd3;      //场同步
parameter  V_BACK_1018   =  11'd10;     //场显示后沿
parameter  V_DISP_1018   =  11'd800;    //场有效数据
parameter  V_FRONT_1018  =  11'd10;     //场显示前沿
parameter  V_TOTAL_1018  =  11'd823;    //场扫描周期

// 4.3' 800*480   
parameter  H_SYNC_4384   =  11'd128;    //行同步
parameter  H_BACK_4384   =  11'd88;     //行显示后沿
parameter  H_DISP_4384   =  11'd800;    //行有效数据
parameter  H_FRONT_4384  =  11'd40;     //行显示前沿
parameter  H_TOTAL_4384  =  11'd1056;   //行扫描周期
   
parameter  V_SYNC_4384   =  11'd2;      //场同步
parameter  V_BACK_4384   =  11'd33;     //场显示后沿
parameter  V_DISP_4384   =  11'd480;    //场有效数据
parameter  V_FRONT_4384  =  11'd10;     //场显示前沿
parameter  V_TOTAL_4384  =  11'd525;    //场扫描周期    

//reg define
reg  [10:0] h_sync ;
reg  [10:0] h_back ;
reg  [10:0] h_total;
reg  [10:0] v_sync ;
reg  [10:0] v_back ;
reg  [10:0] v_total;
reg  [10:0] h_cnt  ;
reg  [10:0] v_cnt  ;

//wire define
wire       lcd_en;

//*****************************************************
//**                    main code
//*****************************************************

//识别色块位置
wire [10:0]  side_length;
wire [10:0]  my_point_1_x;
wire [10:0]  my_point_1_y;
wire [10:0]  my_point_2_x;
wire [10:0]  my_point_2_y;
wire [10:0]  my_point_3_x;
wire [10:0]  my_point_3_y;
wire [10:0]  my_point_4_x;
wire [10:0]  my_point_4_y;
wire [10:0]  my_point_5_x;
wire [10:0]  my_point_5_y;
wire [10:0]  my_point_6_x;
wire [10:0]  my_point_6_y;
wire [10:0]  my_point_7_x;
wire [10:0]  my_point_7_y;
wire [10:0]  my_point_8_x;
wire [10:0]  my_point_8_y;
wire [10:0]  my_point_9_x;
wire [10:0]  my_point_9_y;

vio_2 color_detect_position_vio (
  .clk(sys_clk),                  // input wire clk
  .probe_out0(my_point_1_x),    // output wire [10 : 0] probe_out0
  .probe_out1(my_point_1_y),    // output wire [10 : 0] probe_out1
  .probe_out2(my_point_2_x),    // output wire [10 : 0] probe_out2
  .probe_out3(my_point_2_y),    // output wire [10 : 0] probe_out3
  .probe_out4(my_point_3_x),    // output wire [10 : 0] probe_out4
  .probe_out5(my_point_3_y),    // output wire [10 : 0] probe_out5
  .probe_out6(my_point_4_x),    // output wire [10 : 0] probe_out6
  .probe_out7(my_point_4_y),    // output wire [10 : 0] probe_out7
  .probe_out8(my_point_5_x),    // output wire [10 : 0] probe_out8
  .probe_out9(my_point_5_y),    // output wire [10 : 0] probe_out9
  .probe_out10(my_point_6_x),  // output wire [10 : 0] probe_out10
  .probe_out11(my_point_6_y),  // output wire [10 : 0] probe_out11
  .probe_out12(my_point_7_x),  // output wire [10 : 0] probe_out12
  .probe_out13(my_point_7_y),  // output wire [10 : 0] probe_out13
  .probe_out14(my_point_8_x),  // output wire [10 : 0] probe_out14
  .probe_out15(my_point_8_y),  // output wire [10 : 0] probe_out15
  .probe_out16(my_point_9_x),  // output wire [10 : 0] probe_out16
  .probe_out17(my_point_9_y),  // output wire [10 : 0] probe_out17
  .probe_out18(side_length),  // output wire [10 : 0] probe_out18
  .probe_out19(my_threshold)  // output wire [11 : 0] probe_out19
);

//色块识别
reg my_full1_en;
reg my_full2_en;
reg my_full3_en;
reg my_full4_en;
reg my_full5_en;
reg my_full6_en;
reg my_full7_en;
reg my_full8_en;
reg my_full9_en;
reg [11:0] my_full1_cnt;
reg [11:0] my_full2_cnt;
reg [11:0] my_full3_cnt;
reg [11:0] my_full4_cnt;
reg [11:0] my_full5_cnt;
reg [11:0] my_full6_cnt;
reg [11:0] my_full7_cnt;
reg [11:0] my_full8_cnt;
reg [11:0] my_full9_cnt;

wire [11:0] my_threshold;

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full1_en<=1'b0;
        my_full1_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_1_x)&&(pixel_xpos<(my_point_1_x+side_length))&&(pixel_ypos>my_point_1_y)&&(pixel_ypos<my_point_1_y+side_length))begin
        my_full1_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full1_cnt<=my_full1_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_1_x+side_length))&&(pixel_ypos==(my_point_1_y+side_length-1)))begin
        my_full1_en<=1'b1;
        if (my_full1_cnt>my_threshold)
            my_full1_detect<=1'b1;
        else
            my_full1_detect<=1'b0;
    end
    else begin
        my_full1_en<=1'b0;
        my_full1_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full2_en<=1'b0;
        my_full2_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_2_x)&&(pixel_xpos<(my_point_2_x+side_length))&&(pixel_ypos>my_point_2_y)&&(pixel_ypos<my_point_2_y+side_length))begin
        my_full2_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full2_cnt<=my_full2_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_2_x+side_length))&&(pixel_ypos==(my_point_2_y+side_length-1)))begin
        my_full2_en<=1'b1;
        if (my_full2_cnt>my_threshold)
            my_full2_detect<=1'b1;
        else
            my_full2_detect<=1'b0;
    end
    else begin
        my_full2_en<=1'b0;
        my_full2_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full3_en<=1'b0;
        my_full3_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_3_x)&&(pixel_xpos<(my_point_3_x+side_length))&&(pixel_ypos>my_point_3_y)&&(pixel_ypos<my_point_3_y+side_length))begin
        my_full3_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full3_cnt<=my_full3_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_3_x+side_length))&&(pixel_ypos==(my_point_3_y+side_length-1)))begin
        my_full3_en<=1'b1;
        if (my_full3_cnt>my_threshold)
            my_full3_detect<=1'b1;
        else
            my_full3_detect<=1'b0;
    end
    else begin
        my_full3_en<=1'b0;
        my_full3_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full4_en<=1'b0;
        my_full4_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_4_x)&&(pixel_xpos<(my_point_4_x+side_length))&&(pixel_ypos>my_point_4_y)&&(pixel_ypos<my_point_4_y+side_length))begin
        my_full4_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full4_cnt<=my_full4_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_4_x+side_length))&&(pixel_ypos==(my_point_4_y+side_length-1)))begin
        my_full4_en<=1'b1;
        if (my_full4_cnt>my_threshold)
            my_full4_detect<=1'b1;
        else
            my_full4_detect<=1'b0;
    end
    else begin
        my_full4_en<=1'b0;
        my_full4_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full5_en<=1'b0;
        my_full5_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_5_x)&&(pixel_xpos<(my_point_5_x+side_length))&&(pixel_ypos>my_point_5_y)&&(pixel_ypos<my_point_5_y+side_length))begin
        my_full5_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full5_cnt<=my_full5_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_5_x+side_length))&&(pixel_ypos==(my_point_5_y+side_length-1)))begin
        my_full5_en<=1'b1;
        if (my_full5_cnt>my_threshold)
            my_full5_detect<=1'b1;
        else
            my_full5_detect<=1'b0;
    end
    else begin
        my_full5_en<=1'b0;
        my_full5_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full6_en<=1'b0;
        my_full6_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_6_x)&&(pixel_xpos<(my_point_6_x+side_length))&&(pixel_ypos>my_point_6_y)&&(pixel_ypos<my_point_6_y+side_length))begin
        my_full6_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full6_cnt<=my_full6_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_6_x+side_length))&&(pixel_ypos==(my_point_6_y+side_length-1)))begin
        my_full6_en<=1'b1;
        if (my_full6_cnt>my_threshold)
            my_full6_detect<=1'b1;
        else
            my_full6_detect<=1'b0;
    end
    else begin
        my_full6_en<=1'b0;
        my_full6_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full7_en<=1'b0;
        my_full7_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_7_x)&&(pixel_xpos<(my_point_7_x+side_length))&&(pixel_ypos>my_point_7_y)&&(pixel_ypos<my_point_7_y+side_length))begin
        my_full7_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full7_cnt<=my_full7_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_7_x+side_length))&&(pixel_ypos==(my_point_7_y+side_length-1)))begin
        my_full7_en<=1'b1;
        if (my_full7_cnt>my_threshold)
            my_full7_detect<=1'b1;
        else
            my_full7_detect<=1'b0;
    end
    else begin
        my_full7_en<=1'b0;
        my_full7_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full8_en<=1'b0;
        my_full8_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_8_x)&&(pixel_xpos<(my_point_8_x+side_length))&&(pixel_ypos>my_point_8_y)&&(pixel_ypos<my_point_8_y+side_length))begin
        my_full8_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full8_cnt<=my_full8_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_8_x+side_length))&&(pixel_ypos==(my_point_8_y+side_length-1)))begin
        my_full8_en<=1'b1;
        if (my_full8_cnt>my_threshold)
            my_full8_detect<=1'b1;
        else
            my_full8_detect<=1'b0;
    end
    else begin
        my_full8_en<=1'b0;
        my_full8_cnt<=12'd0;
    end
end

always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)begin
        my_full9_en<=1'b0;
        my_full9_cnt<=12'd0;
    end
    else if ((pixel_xpos>my_point_9_x)&&(pixel_xpos<(my_point_9_x+side_length))&&(pixel_ypos>my_point_9_y)&&(pixel_ypos<my_point_9_y+side_length))begin
        my_full9_en<=1'b1;
        if (pixel_data>16'hfff0)
            my_full9_cnt<=my_full9_cnt+1'b1;
    end
    else if ((pixel_xpos==(my_point_9_x+side_length))&&(pixel_ypos==(my_point_9_y+side_length-1)))begin
        my_full9_en<=1'b1;
        if (my_full9_cnt>my_threshold)
            my_full9_detect<=1'b1;
        else
            my_full9_detect<=1'b0;
    end
    else begin
        my_full9_en<=1'b0;
        my_full9_cnt<=12'd0;
    end
end

//填充青色滑块
reg my_full_ui_en_cyan;
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        my_full_ui_en_cyan<=0;
    end
    else if ((((pixel_xpos>11'd770)&&(pixel_xpos<11'd790))&&((pixel_ypos>11'd10)&&(pixel_ypos<11'd220)))||
             (((pixel_xpos>11'd770)&&(pixel_xpos<11'd790))&&((pixel_ypos>11'd240)&&(pixel_ypos<11'd450)))||
             (((pixel_xpos>11'd710)&&(pixel_xpos<11'd730))&&((pixel_ypos>11'd10)&&(pixel_ypos<11'd220)))||
             (((pixel_xpos>11'd710)&&(pixel_xpos<11'd730))&&((pixel_ypos>11'd240)&&(pixel_ypos<11'd450)))||
             (((pixel_xpos>11'd650)&&(pixel_xpos<11'd670))&&((pixel_ypos>11'd10)&&(pixel_ypos<11'd220)))||
             (((pixel_xpos>11'd650)&&(pixel_xpos<11'd670))&&((pixel_ypos>11'd240)&&(pixel_ypos<11'd450))))begin
        my_full_ui_en_cyan<=1;
    end
    else begin
        my_full_ui_en_cyan<=0;
    end
end

//填充红色滑块指针
reg my_full_ui_en_red;
wire [10:0] my_threshold_y_up_pixel;
wire [10:0] my_threshold_y_down_pixel;
wire [10:0] my_threshold_cb_up_pixel;
wire [10:0] my_threshold_cb_down_pixel;
wire [10:0] my_threshold_cr_up_pixel;
wire [10:0] my_threshold_cr_down_pixel;
assign my_threshold_y_up_pixel   = (11'd220-11'd30) - ( ((11'd220-11'd10-11'd30)  * my_threshold_y_up_touch    )/256 );
assign my_threshold_y_down_pixel = (11'd450-11'd30) - ( ((11'd450-11'd240-11'd30) * my_threshold_y_down_touch  )/256 );
assign my_threshold_cb_up_pixel  = (11'd220-11'd30) - ( ((11'd220-11'd10-11'd30)  * my_threshold_cb_up_touch   )/256 );
assign my_threshold_cb_down_pixel= (11'd450-11'd30) - ( ((11'd450-11'd240-11'd30) * my_threshold_cb_down_touch )/256 );
assign my_threshold_cr_up_pixel  = (11'd220-11'd30) - ( ((11'd220-11'd10-11'd30)  * my_threshold_cr_up_touch   )/256 );
assign my_threshold_cr_down_pixel= (11'd450-11'd30) - ( ((11'd450-11'd240-11'd30) * my_threshold_cr_down_touch )/256 );
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        my_full_ui_en_red<=0;
    end
    else if ((((pixel_xpos>11'd640)&&(pixel_xpos<11'd680))&&((pixel_ypos>my_threshold_y_up_pixel   )&&(pixel_ypos<(my_threshold_y_up_pixel   +11'd30))))||
             (((pixel_xpos>11'd640)&&(pixel_xpos<11'd680))&&((pixel_ypos>my_threshold_y_down_pixel )&&(pixel_ypos<(my_threshold_y_down_pixel +11'd30))))||
             (((pixel_xpos>11'd700)&&(pixel_xpos<11'd740))&&((pixel_ypos>my_threshold_cb_up_pixel  )&&(pixel_ypos<(my_threshold_cb_up_pixel  +11'd30))))||
             (((pixel_xpos>11'd700)&&(pixel_xpos<11'd740))&&((pixel_ypos>my_threshold_cb_down_pixel)&&(pixel_ypos<(my_threshold_cb_down_pixel+11'd30))))||
             (((pixel_xpos>11'd760)&&(pixel_xpos<11'd800))&&((pixel_ypos>my_threshold_cr_up_pixel  )&&(pixel_ypos<(my_threshold_cr_up_pixel  +11'd30))))||
             (((pixel_xpos>11'd760)&&(pixel_xpos<11'd800))&&((pixel_ypos>my_threshold_cr_down_pixel)&&(pixel_ypos<(my_threshold_cr_down_pixel+11'd30)))))begin
        my_full_ui_en_red<=1; 
    end
    else begin
        my_full_ui_en_red<=0;
    end
end

// 填充白色棋局边框
//         5
//      ------------------------------
//      |         |         |         |
//     1|        2|        3|        4|
//      |  6      |         |         |
//      -------------------------------
//      |         |         |         |
//      |         |         |         |
//      |  7      |         |         |
//      -------------------------------
//      |         |         |         |
//      |         |         |         |
//      |  8      |         |         |
//      -------------------------------
//
reg my_full_ui_en_white;
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        my_full_ui_en_white<=0;
    end
    else if ((((pixel_xpos>11'd420)&&(pixel_xpos<(11'd420+11'd10)))&&((pixel_ypos>11'd10)&&(pixel_ypos<(11'd10+11'd180))))|| //1
             (((pixel_xpos>11'd480)&&(pixel_xpos<(11'd480+11'd10)))&&((pixel_ypos>11'd10)&&(pixel_ypos<(11'd10+11'd180))))|| //2
             (((pixel_xpos>11'd540)&&(pixel_xpos<(11'd540+11'd10)))&&((pixel_ypos>11'd10)&&(pixel_ypos<(11'd10+11'd180))))|| //3
             (((pixel_xpos>11'd599)&&(pixel_xpos<(11'd599+11'd10)))&&((pixel_ypos>11'd10)&&(pixel_ypos<(11'd10+11'd180))))|| //4
             (((pixel_xpos>11'd420)&&(pixel_xpos<(11'd420+11'd180)))&&((pixel_ypos>11'd10)&&(pixel_ypos<(11'd10+11'd10))))|| //5
             (((pixel_xpos>11'd420)&&(pixel_xpos<(11'd420+11'd180)))&&((pixel_ypos>11'd70)&&(pixel_ypos<(11'd70+11'd10))))|| //6
             (((pixel_xpos>11'd420)&&(pixel_xpos<(11'd420+11'd180)))&&((pixel_ypos>11'd130)&&(pixel_ypos<(11'd130+11'd10))))|| //7
             (((pixel_xpos>11'd420)&&(pixel_xpos<(11'd420+11'd180+11'd10)))&&((pixel_ypos>11'd189)&&(pixel_ypos<(11'd189+11'd10)))))begin//8
                my_full_ui_en_white<=1;
             end
    else
        my_full_ui_en_white<=0;
end

//      填充粉色玩家棋子
//      ------------------------------
//      |         |         |         |
//      |    1    |    2    |    3    |
//      |         |         |         |
//      -------------------------------
//      |         |         |         |
//      |    4    |    5    |    6    |
//      |         |         |         |
//      -------------------------------
//      |         |         |         |
//      |    7    |    8    |    9    |
//      |         |         |         |
//      -------------------------------
//
reg my_full_ui_en_pink;
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        my_full_ui_en_pink<=0;
    end
    else if ((((pixel_xpos>(11'd420+11'd15))&&(pixel_xpos<(11'd420+11'd15+11'd40)))&&((pixel_ypos>(11'd010+11'd15))&&(pixel_ypos<(11'd010+11'd15+11'd40)))&&(my_full1_store == 1'b1))||
             (((pixel_xpos>(11'd480+11'd15))&&(pixel_xpos<(11'd480+11'd15+11'd40)))&&((pixel_ypos>(11'd010+11'd15))&&(pixel_ypos<(11'd010+11'd15+11'd40)))&&(my_full2_store == 1'b1))||
             (((pixel_xpos>(11'd540+11'd15))&&(pixel_xpos<(11'd540+11'd15+11'd40)))&&((pixel_ypos>(11'd010+11'd15))&&(pixel_ypos<(11'd010+11'd15+11'd40)))&&(my_full3_store == 1'b1))||
             (((pixel_xpos>(11'd420+11'd15))&&(pixel_xpos<(11'd420+11'd15+11'd40)))&&((pixel_ypos>(11'd070+11'd15))&&(pixel_ypos<(11'd070+11'd15+11'd40)))&&(my_full4_store == 1'b1))||
             (((pixel_xpos>(11'd480+11'd15))&&(pixel_xpos<(11'd480+11'd15+11'd40)))&&((pixel_ypos>(11'd070+11'd15))&&(pixel_ypos<(11'd070+11'd15+11'd40)))&&(my_full5_store == 1'b1))||
             (((pixel_xpos>(11'd540+11'd15))&&(pixel_xpos<(11'd540+11'd15+11'd40)))&&((pixel_ypos>(11'd070+11'd15))&&(pixel_ypos<(11'd070+11'd15+11'd40)))&&(my_full6_store == 1'b1))||
             (((pixel_xpos>(11'd420+11'd15))&&(pixel_xpos<(11'd420+11'd15+11'd40)))&&((pixel_ypos>(11'd130+11'd15))&&(pixel_ypos<(11'd130+11'd15+11'd40)))&&(my_full7_store == 1'b1))||
             (((pixel_xpos>(11'd480+11'd15))&&(pixel_xpos<(11'd480+11'd15+11'd40)))&&((pixel_ypos>(11'd130+11'd15))&&(pixel_ypos<(11'd130+11'd15+11'd40)))&&(my_full8_store == 1'b1))||
             (((pixel_xpos>(11'd540+11'd15))&&(pixel_xpos<(11'd540+11'd15+11'd40)))&&((pixel_ypos>(11'd130+11'd15))&&(pixel_ypos<(11'd130+11'd15+11'd40)))&&(my_full9_store == 1'b1)))begin
                my_full_ui_en_pink<=1;
             end
    else begin
        my_full_ui_en_pink<=0;
    end
end

//填充绿色机器棋子
reg my_full_ui_en_green;
wire my_full1_machine;
wire my_full2_machine;
wire my_full3_machine;
wire my_full4_machine;
wire my_full5_machine;
wire my_full6_machine;
wire my_full7_machine;
wire my_full8_machine;
wire my_full9_machine;
assign my_full1_machine = ((machine_full_1==4'd1)||(machine_full_2==4'd1)||(machine_full_3==4'd1)||(machine_full_4==4'd1)) == 1'b1 ? 1 : 0;
assign my_full2_machine = ((machine_full_1==4'd2)||(machine_full_2==4'd2)||(machine_full_3==4'd2)||(machine_full_4==4'd2)) == 1'b1 ? 1 : 0;
assign my_full3_machine = ((machine_full_1==4'd3)||(machine_full_2==4'd3)||(machine_full_3==4'd3)||(machine_full_4==4'd3)) == 1'b1 ? 1 : 0;
assign my_full4_machine = ((machine_full_1==4'd4)||(machine_full_2==4'd4)||(machine_full_3==4'd4)||(machine_full_4==4'd4)) == 1'b1 ? 1 : 0;
assign my_full5_machine = ((machine_full_1==4'd5)||(machine_full_2==4'd5)||(machine_full_3==4'd5)||(machine_full_4==4'd5)) == 1'b1 ? 1 : 0;
assign my_full6_machine = ((machine_full_1==4'd6)||(machine_full_2==4'd6)||(machine_full_3==4'd6)||(machine_full_4==4'd6)) == 1'b1 ? 1 : 0;
assign my_full7_machine = ((machine_full_1==4'd7)||(machine_full_2==4'd7)||(machine_full_3==4'd7)||(machine_full_4==4'd7)) == 1'b1 ? 1 : 0;
assign my_full8_machine = ((machine_full_1==4'd8)||(machine_full_2==4'd8)||(machine_full_3==4'd8)||(machine_full_4==4'd8)) == 1'b1 ? 1 : 0;
assign my_full9_machine = ((machine_full_1==4'd9)||(machine_full_2==4'd9)||(machine_full_3==4'd9)||(machine_full_4==4'd9)) == 1'b1 ? 1 : 0;
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        my_full_ui_en_green<=0;
    end
    else if ((((pixel_xpos>(11'd420+11'd15))&&(pixel_xpos<(11'd420+11'd15+11'd40)))&&((pixel_ypos>(11'd010+11'd15))&&(pixel_ypos<(11'd010+11'd15+11'd40)))&&(my_full1_machine == 1'b1))||
             (((pixel_xpos>(11'd480+11'd15))&&(pixel_xpos<(11'd480+11'd15+11'd40)))&&((pixel_ypos>(11'd010+11'd15))&&(pixel_ypos<(11'd010+11'd15+11'd40)))&&(my_full2_machine == 1'b1))||
             (((pixel_xpos>(11'd540+11'd15))&&(pixel_xpos<(11'd540+11'd15+11'd40)))&&((pixel_ypos>(11'd010+11'd15))&&(pixel_ypos<(11'd010+11'd15+11'd40)))&&(my_full3_machine == 1'b1))||
             (((pixel_xpos>(11'd420+11'd15))&&(pixel_xpos<(11'd420+11'd15+11'd40)))&&((pixel_ypos>(11'd070+11'd15))&&(pixel_ypos<(11'd070+11'd15+11'd40)))&&(my_full4_machine == 1'b1))||
             (((pixel_xpos>(11'd480+11'd15))&&(pixel_xpos<(11'd480+11'd15+11'd40)))&&((pixel_ypos>(11'd070+11'd15))&&(pixel_ypos<(11'd070+11'd15+11'd40)))&&(my_full5_machine == 1'b1))||
             (((pixel_xpos>(11'd540+11'd15))&&(pixel_xpos<(11'd540+11'd15+11'd40)))&&((pixel_ypos>(11'd070+11'd15))&&(pixel_ypos<(11'd070+11'd15+11'd40)))&&(my_full6_machine == 1'b1))||
             (((pixel_xpos>(11'd420+11'd15))&&(pixel_xpos<(11'd420+11'd15+11'd40)))&&((pixel_ypos>(11'd130+11'd15))&&(pixel_ypos<(11'd130+11'd15+11'd40)))&&(my_full7_machine == 1'b1))||
             (((pixel_xpos>(11'd480+11'd15))&&(pixel_xpos<(11'd480+11'd15+11'd40)))&&((pixel_ypos>(11'd130+11'd15))&&(pixel_ypos<(11'd130+11'd15+11'd40)))&&(my_full8_machine == 1'b1))||
             (((pixel_xpos>(11'd540+11'd15))&&(pixel_xpos<(11'd540+11'd15+11'd40)))&&((pixel_ypos>(11'd130+11'd15))&&(pixel_ypos<(11'd130+11'd15+11'd40)))&&(my_full9_machine == 1'b1)))begin
                my_full_ui_en_green<=1;
             end
    else if((pixel_xpos >= CHAR_X_START_reset - 1'b1) && (pixel_xpos < CHAR_X_START_reset + CHAR_WIDTH_reset - 1'b1)
         && (pixel_ypos >= CHAR_Y_START_reset) && (pixel_ypos < CHAR_Y_START_reset + CHAR_HEIGHT_reset)
         && (motor_reset_touch == 1'b1)) begin
        if(reset_char[char_y_cnt_reset][CHAR_WIDTH_reset -1'b1 - char_x_cnt_reset])
            my_full_ui_en_green <= 1;    //显示字符
        else
            my_full_ui_en_green <= 0;    //显示字符区域的背景色
    end
    else begin
        my_full_ui_en_green<=0;
    end
end

//  填充黄色棋局判定记号   
//    7      4         5         6      8
//     \     |         |         |     /
//      - - - - - - - - - - - - - - --
//      |  \ |    |    |    |    | /  |
//   ------------------------------------1
//      |    | \  |    |    | /  |    |
//      - - - - - - - - - - - - - - ---
//      |    |    | \  |  / |    |    |
//   ------------------------------------2
//      |    |    | /  |  \ |    |    |
//      - - - - - - - - - - - - - - ---
//      |    |  / |    |    |  \ |    |
//   ------------------------------------3
//      |  / |    |    |    |    | \  |
//      - - - - - - - - - - - - - - ---
//      '    |         |         |     \
reg my_full_ui_en_yellow;
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n) begin
        my_full_ui_en_yellow<=0;
    end
    else if(( (pixel_xpos>(11'd420+11'd20)) && (pixel_xpos<(11'd420+11'd180-11'd20)) && (pixel_ypos>11'd040) && (pixel_ypos<(11'd040+11'd10)) &&(win_shape==4'd1))|| //1
          ( (pixel_xpos>(11'd420+11'd20)) && (pixel_xpos<(11'd420+11'd180-11'd20)) && (pixel_ypos>11'd100) && (pixel_ypos<(11'd100+11'd10)) &&(win_shape==4'd2))|| //2
          ( (pixel_xpos>(11'd420+11'd20)) && (pixel_xpos<(11'd420+11'd180-11'd20)) && (pixel_ypos>11'd160) && (pixel_ypos<(11'd160+11'd10)) &&(win_shape==4'd3))|| //3
          ( (pixel_xpos>11'd450) && (pixel_xpos<(11'd450+11'd10)) && (pixel_ypos>(11'd10+11'd20)) && (pixel_ypos<(11'd10+11'd180-11'd20)) && (win_shape==4'd4))|| //4
          ( (pixel_xpos>11'd510) && (pixel_xpos<(11'd510+11'd10)) && (pixel_ypos>(11'd10+11'd20)) && (pixel_ypos<(11'd10+11'd180-11'd20)) && (win_shape==4'd5))|| //5
          ( (pixel_xpos>11'd570) && (pixel_xpos<(11'd570+11'd10)) && (pixel_ypos>(11'd10+11'd20)) && (pixel_ypos<(11'd10+11'd180-11'd20)) && (win_shape==4'd6))|| //6
          ((pixel_xpos>(pixel_ypos+11'd410-11'd5)) && (pixel_xpos<(pixel_ypos+11'd410+11'd5)) && (pixel_xpos>(11'd420+11'd20)) && (pixel_xpos<(11'd600-11'd20)) && (win_shape==4'd7))|| //7
          ((pixel_xpos>(11'd620-pixel_ypos-11'd5)) && (pixel_xpos<(11'd610-pixel_ypos+11'd5)) && (pixel_xpos>(11'd420+11'd20)) && (pixel_xpos<(11'd600-11'd20)) && (win_shape==4'd8)))begin //8
        my_full_ui_en_yellow<=1;
    end
    else
        my_full_ui_en_yellow<=0;
end

//填充橘色“玩家赢”
reg my_full_ui_en_orange;
reg   [95:0] player_win_char[31:0];  //字符数组
always @(posedge lcd_pclk) begin
    player_win_char[0 ]<=96'h000000000000000000000000;
    player_win_char[1 ]<=96'h000000000000000000000000;
    player_win_char[2 ]<=96'h000000000006000000020000;
    player_win_char[3 ]<=96'h000000200003800000018000;
    player_win_char[4 ]<=96'h0019FFF00001800000018030;
    player_win_char[5 ]<=96'h3FF80000040080103FFFFFF8;
    player_win_char[6 ]<=96'h0300000007FFFFF801000000;
    player_win_char[7 ]<=96'h030000000400003801000080;
    player_win_char[8 ]<=96'h030000000C00002003FFFFC0;
    player_win_char[9 ]<=96'h030000001800034001000100;
    player_win_char[10]<=96'h0300000001FFFF8001FFFF80;
    player_win_char[11]<=96'h030000000006000001000100;
    player_win_char[12]<=96'h03300008000C000001000100;
    player_win_char[13]<=96'h3FFFFFFC001A018001FFFF00;
    player_win_char[14]<=96'h03006300003303C001000100;
    player_win_char[15]<=96'h0300630000C1860000402020;
    player_win_char[16]<=96'h03006300030398000FEFF7F0;
    player_win_char[17]<=96'h030063000C06E8000C482420;
    player_win_char[18]<=96'h03006300100C44000C492420;
    player_win_char[19]<=96'h030043000030E4000FC9A420;
    player_win_char[20]<=96'h0300C3000061E6000C492720;
    player_win_char[21]<=96'h031CC3000183E2000C4925A0;
    player_win_char[22]<=96'h03E0C300060723000C4924A0;
    player_win_char[23]<=96'h07818308180C21800FC92420;
    player_win_char[24]<=96'h7C018308001820E00C4B2420;
    player_win_char[25]<=96'h30030308006020780843C424;
    player_win_char[26]<=96'h2006030800C0603808426C24;
    player_win_char[27]<=96'h000C030C0700601018462824;
    player_win_char[28]<=96'h001803FE180FE00013C41024;
    player_win_char[29]<=96'h006001FC2003C00020C8203C;
    player_win_char[30]<=96'h008000000001800040904000;
    player_win_char[31]<=96'h000000000000000000000000;
end

//填充橘色“机器赢”
reg   [95:0] machine_win_char[31:0];  //字符数组
always @(posedge lcd_pclk) begin
    machine_win_char[0 ]<=96'h000000000000000000000000;
    machine_win_char[1 ]<=96'h000000000000000000000000;
    machine_win_char[2 ]<=96'h038000000000000000020000;
    machine_win_char[3 ]<=96'h03C000000004004000018000;
    machine_win_char[4 ]<=96'h0383818003FE3FE000018030;
    machine_win_char[5 ]<=96'h0383FFC0020C30C03FFFFFF8;
    machine_win_char[6 ]<=96'h0383C3C0020C30C001000000;
    machine_win_char[7 ]<=96'h0383C380020C30C001000080;
    machine_win_char[8 ]<=96'h0383C380020C30C003FFFFC0;
    machine_win_char[9 ]<=96'h03BBC38003FC3FC001000100;
    machine_win_char[10]<=96'h7FFFC380020C30C001FFFF80;
    machine_win_char[11]<=96'h2383C38002030C0001000100;
    machine_win_char[12]<=96'h0383C3800003071001000100;
    machine_win_char[13]<=96'h0783C3800006033801FFFF00;
    machine_win_char[14]<=96'h07E3C3803FFFFFFC01000100;
    machine_win_char[15]<=96'h07FBC380000C200000402020;
    machine_win_char[16]<=96'h0FBFC380001818000FEFF7F0;
    machine_win_char[17]<=96'h0F9FC38000300C000C482420;
    machine_win_char[18]<=96'h0F9FC380006007000C492420;
    machine_win_char[19]<=96'h1F83C38001C003E00FC9A420;
    machine_win_char[20]<=96'h1F838380070400FC0C492720;
    machine_win_char[21]<=96'h3B8383801BFE7FF80C4925A0;
    machine_win_char[22]<=96'h3383838C630460C00C4924A0;
    machine_win_char[23]<=96'h7387838C030460C00FC92420;
    machine_win_char[24]<=96'h6387038C030460C00C4B2420;
    machine_win_char[25]<=96'h0387038C030460C00843C424;
    machine_win_char[26]<=96'h038E039E030460C008426C24;
    machine_win_char[27]<=96'h039C03FE03FC7FC018462824;
    machine_win_char[28]<=96'h03B801FE030460C013C41024;
    machine_win_char[29]<=96'h03F000000200608020C8203C;
    machine_win_char[30]<=96'h03E000000000000040904000;
    machine_win_char[31]<=96'h000000000000000000000000;
end

//填充橘色“平局了”
reg   [95:0] equal_win_char[31:0];  //字符数组
always @(posedge lcd_pclk) begin
    equal_win_char[0 ]<=96'h000000000000000000000000;
    equal_win_char[1 ]<=96'h000000000000000000000000;
    equal_win_char[2 ]<=96'h000000000000000000000000;
    equal_win_char[3 ]<=96'h000000600200004000000040;
    equal_win_char[4 ]<=96'h0FFFFFF003FFFFE00FFFFFE0;
    equal_win_char[5 ]<=96'h00018000030000C0000001F0;
    equal_win_char[6 ]<=96'h00018000030000C000000380;
    equal_win_char[7 ]<=96'h02018180030000C000000600;
    equal_win_char[8 ]<=96'h010181C0030000C000000C00;
    equal_win_char[9 ]<=96'h00C1818003FFFFC000001000;
    equal_win_char[10]<=96'h00C18300030000C000002000;
    equal_win_char[11]<=96'h00E18200030000000001C000;
    equal_win_char[12]<=96'h00618400030000000001C000;
    equal_win_char[13]<=96'h006188000300001000018000;
    equal_win_char[14]<=96'h0021880003FFFFF800018000;
    equal_win_char[15]<=96'h000190180300003000018000;
    equal_win_char[16]<=96'h7FFFFFFC0300003000018000;
    equal_win_char[17]<=96'h000180000310083000018000;
    equal_win_char[18]<=96'h00018000031FFC3000018000;
    equal_win_char[19]<=96'h000180000318083000018000;
    equal_win_char[20]<=96'h000180000318083000018000;
    equal_win_char[21]<=96'h000180000218083000018000;
    equal_win_char[22]<=96'h000180000618083000018000;
    equal_win_char[23]<=96'h00018000061FF83000018000;
    equal_win_char[24]<=96'h000180000418083000018000;
    equal_win_char[25]<=96'h000180000418003000018000;
    equal_win_char[26]<=96'h000180000800003000018000;
    equal_win_char[27]<=96'h0001800008000C3000618000;
    equal_win_char[28]<=96'h00018000100003E0001F8000;
    equal_win_char[29]<=96'h00018000200000E000070000;
    equal_win_char[30]<=96'h000100000000008000020000;
    equal_win_char[31]<=96'h000000000000000000000000;
end

//填充橘色“Y” “Cb” “Cr”
reg   [7:0] y_char[15:0];  //字符数组
reg   [15:0] cb_char[15:0];  //字符数组
reg   [15:0] cr_char[15:0];  //字符数组
always @(posedge lcd_pclk) begin
    y_char[0 ]<=8'h00;
    y_char[1 ]<=8'h00;
    y_char[2 ]<=8'h00;
    y_char[3 ]<=8'hEE;
    y_char[4 ]<=8'h44;
    y_char[5 ]<=8'h44;
    y_char[6 ]<=8'h28;
    y_char[7 ]<=8'h28;
    y_char[8 ]<=8'h10;
    y_char[9 ]<=8'h10;
    y_char[10]<=8'h10;
    y_char[11]<=8'h10;
    y_char[12]<=8'h10;
    y_char[13]<=8'h38;
    y_char[14]<=8'h00;
    y_char[15]<=8'h00;
end
always @(posedge lcd_pclk) begin
    cb_char[0 ]<=16'h0000;
    cb_char[1 ]<=16'h0000;
    cb_char[2 ]<=16'h0000;
    cb_char[3 ]<=16'h3E00;
    cb_char[4 ]<=16'h42C0;
    cb_char[5 ]<=16'h4240;
    cb_char[6 ]<=16'h8040;
    cb_char[7 ]<=16'h8058;
    cb_char[8 ]<=16'h8064;
    cb_char[9 ]<=16'h8042;
    cb_char[10]<=16'h8042;
    cb_char[11]<=16'h4242;
    cb_char[12]<=16'h4464;
    cb_char[13]<=16'h3858;
    cb_char[14]<=16'h0000;
    cb_char[15]<=16'h0000;
end
always @(posedge lcd_pclk) begin
    cr_char[0 ]<=16'h0000;
    cr_char[1 ]<=16'h0000;
    cr_char[2 ]<=16'h0000;
    cr_char[3 ]<=16'h3E00;
    cr_char[4 ]<=16'h4200;
    cr_char[5 ]<=16'h4200;
    cr_char[6 ]<=16'h8000;
    cr_char[7 ]<=16'h80EE;
    cr_char[8 ]<=16'h8032;
    cr_char[9 ]<=16'h8020;
    cr_char[10]<=16'h8020;
    cr_char[11]<=16'h4220;
    cr_char[12]<=16'h4420;
    cr_char[13]<=16'h38F8;
    cr_char[14]<=16'h0000;
    cr_char[15]<=16'h0000;
end

//填充橘色“棋子复位”
reg   [127:0] reset_char[31:0];  //字符数组
always @(posedge lcd_pclk) begin
    reset_char[0 ]<=128'h00000000000000000000000000000000;
    reset_char[1 ]<=128'h00000000000000000000000000000000;
    reset_char[2 ]<=128'h03818180000000000020000000808000;
    reset_char[3 ]<=128'h03C1E1E0000000400038000000E04000;
    reset_char[4 ]<=128'h0381C1C003FFFFE00060003000C03000;
    reset_char[5 ]<=128'h0381C1C0000001F000FFFFF800C03000;
    reset_char[6 ]<=128'h0381C1F80000038000C0000001803800;
    reset_char[7 ]<=128'h038FFFFC000006000180000001801000;
    reset_char[8 ]<=128'h03B9C1C000000C000380010001000030;
    reset_char[9 ]<=128'h7FFDC1C000003000067FFF80033FFFF8;
    reset_char[10]<=128'h3381C1C0000160000860018002000000;
    reset_char[11]<=128'h0381C1C00001C0001060018007800000;
    reset_char[12]<=128'h0781FFC00001C000207FFF8007000080;
    reset_char[13]<=128'h07E1C1C000018010006001800F0401C0;
    reset_char[14]<=128'h07F1C1C000018038006001800B0201C0;
    reset_char[15]<=128'h07F9C1C03FFFFFFC006001801B020180;
    reset_char[16]<=128'h0FB9FFC000018000007FFF8013030180;
    reset_char[17]<=128'h0FB9C1C0000180000078010023030100;
    reset_char[18]<=128'h1F81C1C0000180000018010043018300;
    reset_char[19]<=128'h1F81C1C800018000003FFF8003018300;
    reset_char[20]<=128'h1B81C1DC000180000038030003018200;
    reset_char[21]<=128'h3BBFFFFE00018000006C060003018200;
    reset_char[22]<=128'h339800000001800000C41C0003018200;
    reset_char[23]<=128'h6380E300000180000183380003018400;
    reset_char[24]<=128'h0381F1C0000180000303F00003000400;
    reset_char[25]<=128'h0383E0F0000180000401C00003000400;
    reset_char[26]<=128'h03878078000180000803F00003000800;
    reset_char[27]<=128'h0387007C00218000000E3E0003000818;
    reset_char[28]<=128'h039E003C001F800000380FF4033FFFFC;
    reset_char[29]<=128'h03B8001C0007000001C001F803000000;
    reset_char[30]<=128'h03F0001C000200003E00001002000000;
    reset_char[31]<=128'h00000000000000000000000000000000;
end

//填充橘色“玩家赢” “机器赢” “平局了”
localparam CHAR_X_START_win= 11'd420;     //字符起始点横坐标
localparam CHAR_Y_START_win= 11'd210;    //字符起始点纵坐标
localparam CHAR_WIDTH_win  = 11'd96;    //字符宽度,3个字符:32*3
localparam CHAR_HEIGHT_win = 11'd32;     //字符高度
wire  [10:0]  char_x_cnt_win;       //横坐标计数器
wire  [10:0]  char_y_cnt_win;       //纵坐标计数器
assign  char_x_cnt_win = pixel_xpos + 1'b1  - CHAR_X_START_win; //像素点相对于字符区域起始点水平坐标
assign  char_y_cnt_win = pixel_ypos - CHAR_Y_START_win; //像素点相对于字符区域起始点垂直坐标

//填充橘色“Y”
localparam CHAR_X_START_y= 11'd650;     //字符起始点横坐标
localparam CHAR_Y_START_y= 11'd460;    //字符起始点纵坐标
localparam CHAR_WIDTH_y  = 11'd8;    //字符宽度
localparam CHAR_HEIGHT_y = 11'd16;     //字符高度
wire  [10:0]  char_x_cnt_y;       //横坐标计数器
wire  [10:0]  char_y_cnt_y;       //纵坐标计数器
assign  char_x_cnt_y = pixel_xpos + 1'b1  - CHAR_X_START_y; //像素点相对于字符区域起始点水平坐标
assign  char_y_cnt_y = pixel_ypos - CHAR_Y_START_y; //像素点相对于字符区域起始点垂直坐标

//填充橘色“Cb”
localparam CHAR_X_START_cb= 11'd710;     //字符起始点横坐标
localparam CHAR_Y_START_cb= 11'd460;    //字符起始点纵坐标
localparam CHAR_WIDTH_cb  = 11'd16;    //字符宽度
localparam CHAR_HEIGHT_cb = 11'd16;     //字符高度
wire  [10:0]  char_x_cnt_cb;       //横坐标计数器
wire  [10:0]  char_y_cnt_cb;       //纵坐标计数器
assign  char_x_cnt_cb = pixel_xpos + 1'b1  - CHAR_X_START_cb; //像素点相对于字符区域起始点水平坐标
assign  char_y_cnt_cb = pixel_ypos - CHAR_Y_START_cb; //像素点相对于字符区域起始点垂直坐标

//填充橘色“Cr”
localparam CHAR_X_START_cr= 11'd770;     //字符起始点横坐标
localparam CHAR_Y_START_cr= 11'd460;    //字符起始点纵坐标
localparam CHAR_WIDTH_cr  = 11'd16;    //字符宽度
localparam CHAR_HEIGHT_cr = 11'd16;     //字符高度
wire  [10:0]  char_x_cnt_cr;       //横坐标计数器
wire  [10:0]  char_y_cnt_cr;       //纵坐标计数器
assign  char_x_cnt_cr = pixel_xpos + 1'b1  - CHAR_X_START_cr; //像素点相对于字符区域起始点水平坐标
assign  char_y_cnt_cr = pixel_ypos - CHAR_Y_START_cr; //像素点相对于字符区域起始点垂直坐标

//填充橘色“棋子复位”
localparam CHAR_X_START_reset= 11'd10;     //字符起始点横坐标
localparam CHAR_Y_START_reset= 11'd430;    //字符起始点纵坐标
localparam CHAR_WIDTH_reset  = 11'd128;    //字符宽度,3个字符:32*4
localparam CHAR_HEIGHT_reset = 11'd32;     //字符高度
wire  [10:0]  char_x_cnt_reset;       //横坐标计数器
wire  [10:0]  char_y_cnt_reset;       //纵坐标计数器
assign  char_x_cnt_reset = pixel_xpos + 1'b1  - CHAR_X_START_reset; //像素点相对于字符区域起始点水平坐标
assign  char_y_cnt_reset = pixel_ypos - CHAR_Y_START_reset; //像素点相对于字符区域起始点垂直坐标

//填充所有橘色文字
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        my_full_ui_en_orange <= 0;
    else if((pixel_xpos >= CHAR_X_START_win - 1'b1) && (pixel_xpos < CHAR_X_START_win + CHAR_WIDTH_win - 1'b1)
         && (pixel_ypos >= CHAR_Y_START_win) && (pixel_ypos < CHAR_Y_START_win + CHAR_HEIGHT_win)) begin
        if(((equal_win_char[char_y_cnt_win][CHAR_WIDTH_win -1'b1 - char_x_cnt_win])&&(win_flag==2'd1))||
           ((player_win_char[char_y_cnt_win][CHAR_WIDTH_win -1'b1 - char_x_cnt_win])&&(win_flag==2'd2))||
           ((machine_win_char[char_y_cnt_win][CHAR_WIDTH_win -1'b1 - char_x_cnt_win])&&(win_flag==2'd3)))
            my_full_ui_en_orange <= 1;    //显示字符
        else
            my_full_ui_en_orange <= 0;    //显示字符区域的背景色
    end
    else if((pixel_xpos >= CHAR_X_START_y - 1'b1) && (pixel_xpos < CHAR_X_START_y + CHAR_WIDTH_y - 1'b1)
         && (pixel_ypos >= CHAR_Y_START_y) && (pixel_ypos < CHAR_Y_START_y + CHAR_HEIGHT_y)) begin
        if(y_char[char_y_cnt_y][CHAR_WIDTH_y -1'b1 - char_x_cnt_y])
            my_full_ui_en_orange <= 1;    //显示字符
        else
            my_full_ui_en_orange <= 0;    //显示字符区域的背景色
    end
    else if((pixel_xpos >= CHAR_X_START_cb - 1'b1) && (pixel_xpos < CHAR_X_START_cb + CHAR_WIDTH_cb - 1'b1)
         && (pixel_ypos >= CHAR_Y_START_cb) && (pixel_ypos < CHAR_Y_START_cb + CHAR_HEIGHT_cb)) begin
        if(cb_char[char_y_cnt_cb][CHAR_WIDTH_cb -1'b1 - char_x_cnt_cb])
            my_full_ui_en_orange <= 1;    //显示字符
        else
            my_full_ui_en_orange <= 0;    //显示字符区域的背景色
    end
    else if((pixel_xpos >= CHAR_X_START_cr - 1'b1) && (pixel_xpos < CHAR_X_START_cr + CHAR_WIDTH_cr - 1'b1)
         && (pixel_ypos >= CHAR_Y_START_cr) && (pixel_ypos < CHAR_Y_START_cr + CHAR_HEIGHT_cr)) begin
        if(cr_char[char_y_cnt_cr][CHAR_WIDTH_cr -1'b1 - char_x_cnt_cr])
            my_full_ui_en_orange <= 1;    //显示字符
        else
            my_full_ui_en_orange <= 0;    //显示字符区域的背景色
    end
    else if((pixel_xpos >= CHAR_X_START_reset - 1'b1) && (pixel_xpos < CHAR_X_START_reset + CHAR_WIDTH_reset - 1'b1)
         && (pixel_ypos >= CHAR_Y_START_reset) && (pixel_ypos < CHAR_Y_START_reset + CHAR_HEIGHT_reset)) begin
        if(reset_char[char_y_cnt_reset][CHAR_WIDTH_reset -1'b1 - char_x_cnt_reset])
            my_full_ui_en_orange <= 1;    //显示字符
        else
            my_full_ui_en_orange <= 0;    //显示字符区域的背景色
    end
    else
        my_full_ui_en_orange <= 0;        //屏幕背景色
end

//填充棋子检测色块
wire my_full_ui_en_cyan_alpha;
assign my_full_ui_en_cyan_alpha = ((my_full1_en&&my_full1_detect)||(my_full2_en&&my_full2_detect)||(my_full3_en&&my_full3_detect)||
                                   (my_full4_en&&my_full4_detect)||(my_full5_en&&my_full5_detect)||(my_full6_en&&my_full6_detect)||
                                   (my_full7_en&&my_full7_detect)||(my_full8_en&&my_full8_detect)||(my_full9_en&&my_full9_detect)) == 1'b1 ? 1 : 0 ;
wire my_full_ui_en_blue_alpha;
assign my_full_ui_en_blue_alpha = (my_full1_en||my_full2_en||my_full3_en||my_full4_en||my_full5_en||my_full6_en||my_full7_en||my_full8_en||my_full9_en) == 1'b1 ? 1 : 0 ;


assign lcd_bl   = 1'b1;           //RGB LCD显示模块背光控制信号
assign lcd_rst  = 1'b1;           //RGB LCD显示模块系统复位信号
assign lcd_pclk = lcd_clk;        //RGB LCD显示模块采样时钟

//RGB LCD 采用数据输入使能信号同步时，行场同步信号需要拉高
assign lcd_hs  = 1'b1;
assign lcd_vs  = 1'b1;

//使能RGB565数据输出
assign  lcd_en = ((h_cnt >= h_sync + h_back) && (h_cnt < h_sync + h_back + h_disp)
                  && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp)) 
                  ? 1'b1 : 1'b0;
 
//帧复位，高有效               
assign out_vsync = ((h_cnt <= 100) && (v_cnt == 1)) ? 1'b1 : 1'b0;

//RGB565数据输出
reg  [15:0] pixel_processed;
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        pixel_processed<=0;
    else if (my_full_ui_en_cyan_alpha == 1'b1 )
        pixel_processed<=(((pixel_data&16'd31727)|16'd15)|16'd992);
    else if (my_full_ui_en_blue_alpha == 1'b1)
        pixel_processed<=(pixel_data&16'd31727)|16'd15;
    else if(my_full_ui_en_red == 1'b1)
        pixel_processed<=16'd63488;
    else if(my_full_ui_en_cyan == 1'b1)
        pixel_processed<=16'd2047;
    else if(my_full_ui_en_yellow == 1'b1)
        pixel_processed<=16'd65504;
    else if (my_full_ui_en_white == 1'b1)
        pixel_processed<=16'hffff;
    else if (my_full_ui_en_green == 1'b1)
        pixel_processed<=16'd2016;
    else if (my_full_ui_en_pink == 1'b1)
        pixel_processed<=16'd47287;
    else if (my_full_ui_en_orange == 1'b1)
        pixel_processed<=16'd64480;
    else
        pixel_processed<=pixel_data;
end

ila_5 screen_color_ila (
	.clk(lcd_pclk), // input wire clk

	.probe0(pixel_data), // input wire [15:0]  probe0  
	.probe1(pixel_processed), // input wire [15:0]  probe1 
	.probe2(my_full_ui_en_blue_alpha), // input wire [0:0]  probe2 
	.probe3(my_full_ui_en_cyan), // input wire [0:0]  probe3 
	.probe4(my_full_ui_en_cyan_alpha), // input wire [0:0]  probe4 
	.probe5(my_full_ui_en_green), // input wire [0:0]  probe5 
	.probe6(my_full_ui_en_orange), // input wire [0:0]  probe6 
	.probe7(my_full_ui_en_pink), // input wire [0:0]  probe7 
	.probe8(my_full_ui_en_red), // input wire [0:0]  probe8 
	.probe9(my_full_ui_en_white), // input wire [0:0]  probe9 
	.probe10(my_full_ui_en_yellow) // input wire [0:0]  probe10
);

assign lcd_rgb = lcd_de ? pixel_processed : 16'd0;

//像素点坐标
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        pixel_xpos <= 11'd0;
    else if(data_req)
        pixel_xpos <= h_cnt + 2'd2 - h_sync - h_back ;
    else 
        pixel_xpos <= 11'd0;
end
       
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        pixel_ypos <= 11'd0;
    else if(v_cnt >= (v_sync + v_back)&&v_cnt < (v_sync + v_back + v_disp))
        pixel_ypos <= v_cnt + 1'b1 - (v_sync + v_back) ;
    else 
        pixel_ypos <= 11'd0;
end

//行场时序参数
always @(posedge lcd_clk) begin
    case(lcd_id)
        16'h4342 : begin
            h_sync  <= H_SYNC_4342; 
            h_back  <= H_BACK_4342; 
            h_disp  <= H_DISP_4342; 
            h_total <= H_TOTAL_4342;
            v_sync  <= V_SYNC_4342; 
            v_back  <= V_BACK_4342; 
            v_disp  <= V_DISP_4342; 
            v_total <= V_TOTAL_4342;            
        end
        16'h7084 : begin
            h_sync  <= H_SYNC_7084; 
            h_back  <= H_BACK_7084; 
            h_disp  <= H_DISP_7084; 
            h_total <= H_TOTAL_7084;
            v_sync  <= V_SYNC_7084; 
            v_back  <= V_BACK_7084; 
            v_disp  <= V_DISP_7084; 
            v_total <= V_TOTAL_7084;        
        end
        16'h7016 : begin
            h_sync  <= H_SYNC_7016; 
            h_back  <= H_BACK_7016; 
            h_disp  <= H_DISP_7016; 
            h_total <= H_TOTAL_7016;
            v_sync  <= V_SYNC_7016; 
            v_back  <= V_BACK_7016; 
            v_disp  <= V_DISP_7016; 
            v_total <= V_TOTAL_7016;            
        end
        16'h4384 : begin
            h_sync  <= H_SYNC_4384; 
            h_back  <= H_BACK_4384; 
            h_disp  <= H_DISP_4384; 
            h_total <= H_TOTAL_4384;
            v_sync  <= V_SYNC_4384; 
            v_back  <= V_BACK_4384; 
            v_disp  <= V_DISP_4384; 
            v_total <= V_TOTAL_4384;             
        end        
        16'h1018 : begin
            h_sync  <= H_SYNC_1018; 
            h_back  <= H_BACK_1018; 
            h_disp  <= H_DISP_1018; 
            h_total <= H_TOTAL_1018;
            v_sync  <= V_SYNC_1018; 
            v_back  <= V_BACK_1018; 
            v_disp  <= V_DISP_1018; 
            v_total <= V_TOTAL_1018;        
        end
        default : begin
            h_sync  <= H_SYNC_4342; 
            h_back  <= H_BACK_4342; 
            h_disp  <= H_DISP_4342; 
            h_total <= H_TOTAL_4342;
            v_sync  <= V_SYNC_4342; 
            v_back  <= V_BACK_4342; 
            v_disp  <= V_DISP_4342; 
            v_total <= V_TOTAL_4342;          
        end
    endcase	
end

//数据使能信号		
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)	
		lcd_de <= 1'b0;
	else
		lcd_de <= data_req;
end
				  
//请求像素点颜色数据输入  
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)	
		data_req <= 1'b0;
	else if((h_cnt >= h_sync + h_back - 2'd2) && (h_cnt < h_sync + h_back + h_disp - 2'd2)
             && (v_cnt >= v_sync + v_back) && (v_cnt < v_sync + v_back + v_disp))
		data_req <= 1'b1;
	else
		data_req <= 1'b0;
end

//行计数器对像素时钟计数
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        h_cnt <= 11'd0;
    else begin
        if(h_cnt == h_total - 1'b1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 1'b1;           
    end
end

//场计数器对行计数
always@ (posedge lcd_clk or negedge rst_n) begin
    if(!rst_n) 
        v_cnt <= 11'd0;
    else begin
        if(h_cnt == h_total - 1'b1) begin
            if(v_cnt == v_total - 1'b1)
                v_cnt <= 11'd0;
            else
                v_cnt <= v_cnt + 1'b1;    
        end
    end    
end
 
endmodule 