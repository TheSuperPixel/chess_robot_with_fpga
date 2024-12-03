// Descriptions:        ͼ�����ֵ��ֵ������

module binarization(
    //module clock
    input               clk             ,   // ʱ���ź�
    input               rst_n           ,   // ��λ�źţ�����Ч��

    //ͼ����ǰ�����ݽӿ�
    input               ycbcr_vsync     ,   // vsync�ź�
    input               ycbcr_href      ,   // href�ź�
    input               ycbcr_de        ,   // data enable�ź�
    input   [7:0]       luminance       ,
    input   [7:0]       my_threshold_up ,
    input   [7:0]       my_threshold_down,
    //ͼ����������ݽӿ�
    output              post_vsync      ,   // vsync�ź�
    output              post_href       ,   // href�ź�
    output              post_de         ,   // data enable�ź�
    output   reg        monoc               // monochrome��1=�ף�0=�ڣ�
);

//reg define
reg    ycbcr_vsync_d;
reg    ycbcr_href_d ;
reg    ycbcr_de_d   ;
wire   [7:0] my_threshold;
//*****************************************************
//**                    main code
//*****************************************************

assign  post_vsync = ycbcr_vsync_d;
assign  post_href  = ycbcr_href_d ;
assign  post_de    = ycbcr_de_d   ;

//��ֵ��ֵ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        monoc <= 1'b0;
    else if((luminance >= my_threshold_down)&&(luminance <= my_threshold_up))  //��ֵ
        monoc <= 1'b1;
    else
        monoc <= 1'b0;
end

//��ʱ1����ͬ��ʱ���ź�
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ycbcr_vsync_d <= 1'd0;
        ycbcr_href_d <= 1'd0;
        ycbcr_de_d    <= 1'd0;
    end
    else begin
        ycbcr_vsync_d <= ycbcr_vsync;
        ycbcr_href_d  <= ycbcr_href ;
        ycbcr_de_d    <= ycbcr_de   ;
    end
end
endmodule 