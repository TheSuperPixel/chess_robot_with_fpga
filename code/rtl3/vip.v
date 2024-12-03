// Descriptions:        ����ͼ����ģ���װ��

module vip(
    //module clock
    input           clk            ,   // ʱ���ź�
    input           rst_n          ,   // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input           pre_frame_vsync,   
    input           pre_frame_href ,
    input           pre_frame_de   ,
    input    [15:0] pre_rgb        ,

    //ͼ���������ݽӿ�
    output          post_frame_vsync,  // ��ͬ���ź�
    output          post_frame_href ,  // ��ͬ���ź�
    output          post_frame_de   ,  // ��������ʹ��
    output   [15:0] post_rgb,           // RGB565��ɫ����

    input [7:0] my_threshold_y_up_touch    ,
    input [7:0] my_threshold_y_down_touch  ,
    input [7:0] my_threshold_cb_up_touch   ,
    input [7:0] my_threshold_cb_down_touch ,
    input [7:0] my_threshold_cr_up_touch   ,
    input [7:0] my_threshold_cr_down_touch
);

//wire define
wire   [ 7:0]         img_y;
wire   [ 7:0]         img_cb;
wire   [ 7:0]         img_cr;
wire   [ 7:0]         post_img_y;
wire   [ 7:0]         post_img_cb;
wire   [ 7:0]         post_img_cr;
wire                  pe_frame_vsync;
wire                  pe_frame_href;
wire                  pe_frame_clken;
wire                  ycbcr_vsync;
wire                  ycbcr_href;
wire                  ycbcr_de;

//*****************************************************
//**                    main code
//*****************************************************

//����ͼ���x��y����
reg [30:0] image_y_pos;
reg [30:0] image_x_pos;
reg post_frame_href_d1;
wire post_frame_href_up;
assign post_frame_href_up = (~post_frame_href_d1)&&post_frame_href;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        post_frame_href_d1<=0;
    end
    else begin
        post_frame_href_d1<=post_frame_href;
    end
end
always @(posedge post_frame_de or negedge rst_n) begin
    if ((!rst_n)||(post_frame_href==1'b0)) begin
        image_x_pos<=0;
    end
    else if (post_frame_de==1'b1) begin
        image_x_pos<=image_x_pos+1;
    end
    else begin
        image_x_pos<=image_x_pos;
    end
end
always @(posedge post_frame_de or negedge rst_n) begin
    if ((!rst_n)||(post_frame_vsync== 1'b1)) begin
        image_y_pos<=0;
    end
    else if (post_frame_href_up == 1'b1)begin
        image_y_pos<=image_y_pos+1;
    end
end



ila_1 myila_1 (
	.clk(clk), // input wire clk


	.probe0(image_x_pos), // input wire [29:0]  probe0  
	.probe1(image_y_pos), // input wire [29:0]  probe1 
	.probe2(post_frame_de), // input wire [0:0]  probe2 
	.probe3(post_frame_vsync), // input wire [0:0]  probe3
	.probe4(post_frame_href), // input wire [0:0]  probe4
    .probe5(monoc_img_buffer_w_addr), // input wire [17:0]  probe5 
	.probe6(monoc_img_buffer_r_addr), // input wire [17:0]  probe6
    .probe7(compressed_w_en), // input wire [0:0]  probe7 
	.probe8(compressed_r_en), // input wire [0:0]  probe8
    .probe9(compressed_w_clk), // input wire [0:0]  probe9 
	.probe10(compressed_r_clk) // input wire [0:0]  probe10
);

//���ɻ�������ͼ��ram����ʱ��
reg [17:0] monoc_img_buffer_w_addr;
reg [17:0] monoc_img_buffer_r_addr;

wire compressed_w_clk;
wire compressed_w_en;
assign compressed_w_en = (((image_x_pos % 2 == 1)&&(image_y_pos % 2 == 1)&&(image_x_pos<=31'd800)&&(image_y_pos<31'd480))==1'b1)? 1 : 0;
assign compressed_w_clk = compressed_w_en & post_frame_de;

wire compressed_r_clk;
wire compressed_r_en;
assign compressed_r_en = (((image_x_pos<=31'd400)&&(image_y_pos<=31'd240))==1'b1)? 1 : 0;
assign compressed_r_clk = compressed_r_en & post_frame_de;

//���ɻ�������ͼ��ram��д��ַ�Ͷ���ַ
always @(posedge post_frame_de or negedge rst_n) begin
    if (!rst_n) begin
        monoc_img_buffer_w_addr<=0;
    end
    else if (compressed_w_en==1'b1) begin
        monoc_img_buffer_w_addr<=monoc_img_buffer_w_addr+1;
    end
    else if((image_x_pos==31'd799)&&(image_y_pos==31'd480))begin
        monoc_img_buffer_w_addr<=0;
    end
    else begin
        monoc_img_buffer_w_addr<=monoc_img_buffer_w_addr;
    end
end

always @(posedge post_frame_de or negedge rst_n) begin
    if (!rst_n) begin
        monoc_img_buffer_r_addr<=0;
    end
    else if ((compressed_r_en==1'b1)&&((image_x_pos+1) % 400 != 0))begin
        monoc_img_buffer_r_addr<=monoc_img_buffer_r_addr+1;
    end 
    else if((image_x_pos==31'd401)&&(image_y_pos==31'd240))begin
        monoc_img_buffer_r_addr<=0;
    end
    else begin
        monoc_img_buffer_r_addr<=monoc_img_buffer_r_addr;
    end
end

blk_mem_gen_1 my_blk_mem_gen_1 (
  .clka(compressed_w_clk),    // input wire clka
  .wea(1),      // input wire [0 : 0] wea
  .addra(monoc_img_buffer_w_addr),  // input wire [16 : 0] addra
  .dina(monoc_all),    // input wire [0 : 0] dina
  .clkb(compressed_r_clk),    // input wire clkb
  .addrb(monoc_img_buffer_r_addr),  // input wire [16 : 0] addrb
  .doutb(compressed_monoc)  // output wire [0 : 0] doutb
);

//����ź�
wire compressed_monoc;
assign  post_rgb = ((image_x_pos<=31'd400)&&(image_y_pos<31'd240))? {16{compressed_monoc}}:pre_rgb;

//RGBתYCbCrģ��
rgb2ycbcr u_rgb2ycbcr(
    //module clock
    .clk             (clk    ),            // ʱ���ź�
    .rst_n           (rst_n  ),            // ��λ�źţ�����Ч��
    //ͼ����ǰ�����ݽӿ�
    .pre_frame_vsync (pre_frame_vsync),    // vsync�ź�
    .pre_frame_href  (pre_frame_href ),    // href�ź�
    .pre_frame_de    (pre_frame_de   ),    // data enable�ź�
    .img_red         (pre_rgb[15:11] ),
    .img_green       (pre_rgb[10:5 ] ),
    .img_blue        (pre_rgb[ 4:0 ] ),
    //ͼ���������ݽӿ�
    .post_frame_vsync(pe_frame_vsync),     // vsync�ź�
    .post_frame_href (pe_frame_href ),     // href�ź�
    .post_frame_de   (pe_frame_clken),     // data enable�ź�
    .img_y           (img_y),              //�Ҷ�����
    .img_cb          (img_cb),
    .img_cr          (img_cr)
);

//�Ҷ�ͼ��ֵ�˲�
vip_gray_median_filter u_vip_gray_median_filter_y(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //Ԥ����ͼ������
    .pe_frame_vsync (pe_frame_vsync),      // vsync�ź�
    .pe_frame_href  (pe_frame_href),       // href�ź�
    .pe_frame_clken (pe_frame_clken),      // data enable�ź�
    .pe_img       (img_y),               
                                           
    //������ͼ������                     
    .pos_frame_vsync (ycbcr_vsync),        // vsync�ź�
    .pos_frame_href  (ycbcr_href ),        // href�ź�
    .pos_frame_clken (ycbcr_de),           // data enable�ź�
    .pos_img       (post_img_y)          //��ֵ�˲���ĻҶ�����
);

vip_gray_median_filter u_vip_gray_median_filter_cb(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //Ԥ����ͼ������
    .pe_frame_vsync (pe_frame_vsync),      // vsync�ź�
    .pe_frame_href  (pe_frame_href),       // href�ź�
    .pe_frame_clken (pe_frame_clken),      // data enable�ź�
    .pe_img       (img_cb),               
                                           
    //������ͼ������                     
    .pos_frame_vsync (),        // vsync�ź�
    .pos_frame_href  (),        // href�ź�
    .pos_frame_clken (),           // data enable�ź�
    .pos_img       (post_img_cb)          //��ֵ�˲���ĻҶ�����
);

vip_gray_median_filter u_vip_gray_median_filter_cr(
    .clk    (clk),   
    .rst_n  (rst_n), 
    
    //Ԥ����ͼ������
    .pe_frame_vsync (pe_frame_vsync),      // vsync�ź�
    .pe_frame_href  (pe_frame_href),       // href�ź�
    .pe_frame_clken (pe_frame_clken),      // data enable�ź�
    .pe_img       (img_cr),               
                                           
    //������ͼ������                     
    .pos_frame_vsync (),        // vsync�ź�
    .pos_frame_href  (),        // href�ź�
    .pos_frame_clken (),           // data enable�ź�
    .pos_img       (post_img_cr)          //��ֵ�˲���ĻҶ�����
);

//��ֵģ��
wire                  monoc_y;
wire                  monoc_cb;
wire                  monoc_cr;
wire                  monoc_all;
assign monoc_all= monoc_y & monoc_cb & monoc_cr;
binarization  u_binarization_y(
    .clk         (clk),
    .rst_n       (rst_n),
    //ͼ����ǰ�����ݽӿ�     
    .ycbcr_vsync (ycbcr_vsync),
    .ycbcr_href  (ycbcr_href),
    .ycbcr_de    (ycbcr_de),
    .luminance   (post_img_y),
    .my_threshold_up (my_threshold_y_up),
    .my_threshold_down (my_threshold_y_down),
    //ͼ���������ݽӿ�     
    .post_vsync  (post_frame_vsync),
    .post_href   (post_frame_href),
    .post_de     (post_frame_de),
    .monoc       (monoc_y)                   //��ֵ���������
);
binarization  u_binarization_cb(
    .clk         (clk),
    .rst_n       (rst_n),
    //ͼ����ǰ�����ݽӿ�     
    .ycbcr_vsync (ycbcr_vsync),
    .ycbcr_href  (ycbcr_href),
    .ycbcr_de    (ycbcr_de),
    .luminance   (post_img_cb),
    .my_threshold_up (my_threshold_cb_up),
    .my_threshold_down (my_threshold_cb_down),
    //ͼ���������ݽӿ�     
    .post_vsync  (),
    .post_href   (),
    .post_de     (),
    .monoc       (monoc_cb)                   //��ֵ���������
);
binarization  u_binarization_cr(
    .clk         (clk),
    .rst_n       (rst_n),
    //ͼ����ǰ�����ݽӿ�     
    .ycbcr_vsync (ycbcr_vsync),
    .ycbcr_href  (ycbcr_href),
    .ycbcr_de    (ycbcr_de),
    .luminance   (post_img_cr),
    .my_threshold_up (my_threshold_cr_up),
    .my_threshold_down (my_threshold_cr_down),
    //ͼ���������ݽӿ�     
    .post_vsync  (),
    .post_href   (),
    .post_de     (),
    .monoc       (monoc_cr)                   //��ֵ���������
);

//��ֵ��ֵ����
wire [7:0] my_threshold_y_up    ;
wire [7:0] my_threshold_y_down  ;
wire [7:0] my_threshold_cb_up   ;
wire [7:0] my_threshold_cb_down ;
wire [7:0] my_threshold_cr_up   ;
wire [7:0] my_threshold_cr_down ;

assign my_threshold_y_up    = (my_threshold_vio_en == 1'b1) ? my_threshold_y_up_vio    : my_threshold_y_up_touch    ;
assign my_threshold_y_down  = (my_threshold_vio_en == 1'b1) ? my_threshold_y_down_vio  : my_threshold_y_down_touch  ;
assign my_threshold_cb_up   = (my_threshold_vio_en == 1'b1) ? my_threshold_cb_up_vio   : my_threshold_cb_up_touch   ;
assign my_threshold_cb_down = (my_threshold_vio_en == 1'b1) ? my_threshold_cb_down_vio : my_threshold_cb_down_touch ;
assign my_threshold_cr_up   = (my_threshold_vio_en == 1'b1) ? my_threshold_cr_up_vio   : my_threshold_cr_up_touch   ;
assign my_threshold_cr_down = (my_threshold_vio_en == 1'b1) ? my_threshold_cr_down_vio : my_threshold_cr_down_touch ;

wire [7:0] my_threshold_y_up_vio     ;
wire [7:0] my_threshold_y_down_vio   ;
wire [7:0] my_threshold_cb_up_vio    ;
wire [7:0] my_threshold_cb_down_vio  ;
wire [7:0] my_threshold_cr_up_vio    ;
wire [7:0] my_threshold_cr_down_vio  ;

wire my_threshold_vio_en;

vio_1 color_threhold_set_vio (
  .clk(clk),                // input wire clk
  .probe_out0(my_threshold_y_up_vio     ),  // output wire [7 : 0] probe_out0
  .probe_out1(my_threshold_y_down_vio   ),  // output wire [7 : 0] probe_out1
  .probe_out2(my_threshold_cb_up_vio    ),  // output wire [7 : 0] probe_out2
  .probe_out3(my_threshold_cb_down_vio  ),  // output wire [7 : 0] probe_out3
  .probe_out4(my_threshold_cr_up_vio    ),  // output wire [7 : 0] probe_out4
  .probe_out5(my_threshold_cr_down_vio  ),  // output wire [7 : 0] probe_out5
  .probe_out7(my_threshold_vio_en)  // output wire [0 : 0] probe_out7
);
endmodule
