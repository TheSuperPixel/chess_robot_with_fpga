// Descriptions:        LCD����ģ��
                      
module lcd_rgb_top(
    input           sys_clk      ,  //ϵͳʱ��
    input           sys_rst_n,      //��λ�ź�  
    input           sys_init_done, 
    //lcd�ӿ�  
    output          lcd_clk,        //LCD����ʱ��    
    output          lcd_hs,         //LCD ��ͬ���ź�
    output          lcd_vs,         //LCD ��ͬ���ź�
    output          lcd_de,         //LCD ��������ʹ��
    inout  [23:0]   lcd_rgb,        //LCD RGB��ɫ����
    output          lcd_bl,         //LCD ��������ź�
    output          lcd_rst,        //LCD ��λ�ź�
    output          lcd_pclk,       //LCD ����ʱ��
    output  [15:0]  lcd_id,         //LCD��ID  
    output          out_vsync,      //lcd���ź� 
    output  [10:0]  pixel_xpos,     //���ص������
    output  [10:0]  pixel_ypos,     //���ص�������        
    output  [10:0]  h_disp,         //LCD��ˮƽ�ֱ���
    output  [10:0]  v_disp,         //LCD����ֱ�ֱ���         
    input   [15:0]  data_in,        //��������   
    output          data_req,        //������������
    
    output my_full1_detect,
    output my_full2_detect,
    output my_full3_detect,
    output my_full4_detect,
    output my_full5_detect,
    output my_full6_detect,
    output my_full7_detect,
    output my_full8_detect,
    output my_full9_detect,

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

//wire define
wire  [15:0] lcd_rgb_565;           //�����16λlcd����
wire  [23:0] lcd_rgb_o ;            //LCD �����ɫ����
wire  [23:0] lcd_rgb_i ;            //LCD ������ɫ����
//*****************************************************
//**                    main code
//***************************************************** 


//������ͷ16bit����ת��Ϊ24bit��lcd����
assign lcd_rgb_o = {lcd_rgb_565[15:11],3'b000,lcd_rgb_565[10:5],2'b00,
                    lcd_rgb_565[4:0],3'b000};          

//�������ݷ����л�
assign lcd_rgb = lcd_de ?  lcd_rgb_o :  {24{1'bz}};
assign lcd_rgb_i = lcd_rgb;
            
//ʱ�ӷ�Ƶģ��    
clk_div u_clk_div(
    .clk                    (sys_clk  ),
    .rst_n                  (sys_rst_n),
    .lcd_id                 (lcd_id   ),
    .lcd_pclk               (lcd_clk  )
    );  

//��LCD IDģ��
rd_id u_rd_id(
    .clk                    (sys_clk  ),
    .rst_n                  (sys_rst_n),
    .lcd_rgb                (lcd_rgb_i),
    .lcd_id                 (lcd_id   )
    );  

//lcd����ģ��
lcd_driver u_lcd_driver(           
    .lcd_clk        (lcd_clk),  
    .sys_clk        (sys_clk),
    .rst_n          (sys_rst_n & sys_init_done), 
    .lcd_id         (lcd_id),   

    .lcd_hs         (lcd_hs),       
    .lcd_vs         (lcd_vs),       
    .lcd_de         (lcd_de),       
    .lcd_rgb        (lcd_rgb_565),
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_pclk       (lcd_pclk),
    
    .pixel_data     (data_in), 
    .data_req       (data_req),
    .out_vsync      (out_vsync),
    .h_disp         (h_disp),
    .v_disp         (v_disp), 
    .pixel_xpos     (pixel_xpos), 
    .pixel_ypos     (pixel_ypos),

    .my_full1_detect(my_full1_detect),
    .my_full2_detect(my_full2_detect),
    .my_full3_detect(my_full3_detect),
    .my_full4_detect(my_full4_detect),
    .my_full5_detect(my_full5_detect),
    .my_full6_detect(my_full6_detect),
    .my_full7_detect(my_full7_detect),
    .my_full8_detect(my_full8_detect),
    .my_full9_detect(my_full9_detect),

    .my_full1_store(my_full1_store),
    .my_full2_store(my_full2_store),
    .my_full3_store(my_full3_store),
    .my_full4_store(my_full4_store),
    .my_full5_store(my_full5_store),
    .my_full6_store(my_full6_store),
    .my_full7_store(my_full7_store),
    .my_full8_store(my_full8_store),
    .my_full9_store(my_full9_store),

    .my_threshold_y_up_touch    (my_threshold_y_up_touch   ),
    .my_threshold_y_down_touch  (my_threshold_y_down_touch ),
    .my_threshold_cb_up_touch   (my_threshold_cb_up_touch  ),
    .my_threshold_cb_down_touch (my_threshold_cb_down_touch),
    .my_threshold_cr_up_touch   (my_threshold_cr_up_touch  ),
    .my_threshold_cr_down_touch (my_threshold_cr_down_touch),

    .win_shape                  (win_shape),

    .machine_full_1 (machine_full_1),
    .machine_full_2 (machine_full_2),
    .machine_full_3 (machine_full_3),
    .machine_full_4 (machine_full_4),
    
    .win_flag(win_flag),
    .motor_reset_touch(motor_reset_touch)
    ); 
                 
endmodule 