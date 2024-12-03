module chess_logic(
    input sys_clk,
    input sys_rst_n,
    input input_A1,
    input input_A2,
    input input_A3,
    input input_A4,
    input input_A5,
    input input_A6,
    input input_A7,
    input input_A8,
    input input_A9,
    input ready_flag,   //��Ұ������£�ͼ��ʶ�����
    
    output reg  [3:0] motor_flag ,//����źŸ����Ƶ�c d1~d9
    output reg  [1:0] win_flag, //3����Ӯ 2��Ӯ 1ƽ�� 0��δ�ֳ����
    
    //����4�����������жϣ���λʱ����״̬
    output reg [3:0]Reset_1,
    output reg [3:0]Reset_2,
    output reg [3:0]Reset_3,
    output reg [3:0]Reset_4,

    output reg [3:0]Reset_A1,
    output reg [3:0]Reset_A2,
    output reg [3:0]Reset_A3,
    output reg [3:0]Reset_A4,
    output reg [3:0]Reset_A5,
    
    output reg [3:0]win_shape  //�ж�Ӯ�巽ʽ
);


reg [1:0]turn_flag=2'd0;
//������Ȩ��Ϊ1����������Ȩ��Ϊ4�������j0

//------------<״�����������>------------------------------------------
parameter   IMAGE       = 3'b001,//���̸���
			ROBOT_WIN   = 3'b010,//λ�������{
            PEOPLE_WIN  = 3'b011,
			ADVANTAGE   = 3'b100,//λ�������]
            UPDATE_BOARD= 3'b101,//��������
            JUDGE_WIN   = 3'b110,
			NONE        = 3'b000;//������λ�ô�����δ��⵽�ź�
			
//------------<reg����>-------------------------------------------------
reg	[2:0]	cur_state;					//�����֝�Ĵ���
reg	[2:0]	next_state;					//����Ν�Ĵ���
 
//-----------------------------------------------------------------------
//--״�����һ�Σ�ͬ��ʱ������״��ת��
//-----------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		cur_state <= NONE;				//��λ��ʼ״�W
	else
		cur_state <= next_state;		//�Ν�ת�Ƶ��֞W
end
 
//����һ������ʹ����ʱ������̸���
reg ready_flag0;
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		ready_flag0 <= 1'b0;				//��λ��ʼ״�W
	else
		ready_flag0 <= ready_flag;		//�Ν�ת�Ƶ��֞W
end 



reg input_A1_0;
reg input_A2_0;
reg input_A3_0;
reg input_A4_0;
reg input_A5_0;
reg input_A6_0;
reg input_A7_0;
reg input_A8_0;
reg input_A9_0;

//�������ʱ��ͼ��ԭ����Ҫ��һ���źŲŲ����λ
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n) begin
		input_A1_0<= 1'b0;				//��λ��ʼ״�W
        input_A2_0<= 1'b0;
        input_A3_0<= 1'b0;
        input_A4_0<= 1'b0;
        input_A5_0<= 1'b0;
        input_A6_0<= 1'b0;
        input_A7_0<= 1'b0;
        input_A8_0<= 1'b0;
        input_A9_0<= 1'b0;
        end
	else begin
		input_A1_0<= input_A1;	
        input_A2_0<= input_A2;
        input_A3_0<= input_A3;
        input_A4_0<= input_A4;
        input_A5_0<= input_A5;
        input_A6_0<= input_A6;
        input_A7_0<= input_A7;
        input_A8_0<= input_A8;
        input_A9_0<= input_A9;
        end
end 




 
//-----------------------------------------------------------------------
//--״����ڶ��Σ�����߼��ж�״��ת������������״��ת�ƹ����Լ�����
//-----------------------------------------------------------------------
reg [2:0]input_cnt;
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		input_cnt <= 3'b0;				//��λ��ʼ״�W
	else   if(ready_flag==1'b1)
		input_cnt <= input_cnt+3'b1;		//�Ν�ת�Ƶ��֞W
    else 
        input_cnt <= input_cnt;		//�Ν�ת�Ƶ��֞W
end 

//�ж��������λ��
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		Reset_A1<=4'd0;
        Reset_A2<=4'd0;
        Reset_A3<=4'd0;
        Reset_A4<=4'd0;
        Reset_A5<=4'd0;			//��λ��ʼ״�W
        end
	else if(win_flag==2'd0)begin 
          case(input_cnt)
            3'd1    : begin 
                        if(input_A1_0==1'd1)
                            Reset_A1<=4'd1;        //���±�ʾ1
                        else if(input_A2_0==1'd1)
                            Reset_A1<=4'd2;
                        else if(input_A3_0==1'd1)
                            Reset_A1<=4'd3;
                        else if(input_A4_0==1'd1)
                            Reset_A1<=4'd4;
                        else if(input_A5_0==1'd1)
                            Reset_A1<=4'd5;
                        else if(input_A6_0==1'd1)
                            Reset_A1<=4'd6;
                        else if(input_A7_0==1'd1)
                            Reset_A1<=4'd7;
                        else if(input_A8_0==1'd1)
                            Reset_A1<=4'd8;
                        else if(input_A9_0==1'd1)
                            Reset_A1<=4'd9;
                        else ;
            		end    // If sel=0, output is a
            3'd2    : begin 
                    if(input_A1_0==1'd1&&Reset_A1!=4'd1)//��һ��λ���������壬������ҵ�һ��û�����ڸ�λ��
                            Reset_A2<=4'd1;        
                        else if(input_A2_0==1'd1&&Reset_A1!=4'd2)
                            Reset_A2<=4'd2;
                        else if(input_A3_0==1'd1&&Reset_A1!=4'd3)
                            Reset_A2<=4'd3;
                        else if(input_A4_0==1'd1&&Reset_A1!=4'd4)
                            Reset_A2<=4'd4;
                        else if(input_A5_0==1'd1&&Reset_A1!=4'd5)
                            Reset_A2<=4'd5;
                        else if(input_A6_0==1'd1&&Reset_A1!=4'd6)
                            Reset_A2<=4'd6;
                        else if(input_A7_0==1'd1&&Reset_A1!=4'd7)
                            Reset_A2<=4'd7;
                        else if(input_A8_0==1'd1&&Reset_A1!=4'd8)
                            Reset_A2<=4'd8;
                        else if(input_A9_0==1'd1&&Reset_A1!=4'd9)
                            Reset_A2<=4'd9;
                        else ;


            	    end         // If sel=1, output is b
            3'd3    : begin 
                    if(input_A1_0==1'd1&&Reset_A1!=4'd1&&Reset_A2!=4'd1)//��һ��λ���������壬������ҵ�һ��û�����ڸ�λ��
                            Reset_A3<=4'd1;        
                        else if(input_A2_0==1'd1&&Reset_A1!=4'd2&&Reset_A2!=4'd2)
                            Reset_A3<=4'd2;
                        else if(input_A3_0==1'd1&&Reset_A1!=4'd3&&Reset_A2!=4'd3)
                            Reset_A3<=4'd3;
                        else if(input_A4_0==1'd1&&Reset_A1!=4'd4&&Reset_A2!=4'd4)
                            Reset_A3<=4'd4;
                        else if(input_A5_0==1'd1&&Reset_A1!=4'd5&&Reset_A2!=4'd5)
                            Reset_A3<=4'd5;
                        else if(input_A6_0==1'd1&&Reset_A1!=4'd6&&Reset_A2!=4'd6)
                            Reset_A3<=4'd6;
                        else if(input_A7_0==1'd1&&Reset_A1!=4'd7&&Reset_A2!=4'd7)
                            Reset_A3<=4'd7;
                        else if(input_A8_0==1'd1&&Reset_A1!=4'd8&&Reset_A2!=4'd8)
                            Reset_A3<=4'd8;
                        else if(input_A9_0==1'd1&&Reset_A1!=4'd9&&Reset_A2!=4'd9)
                            Reset_A3<=4'd9;
                        else ;

            		end        // If sel=2, output is c
            3'd4    : begin 
                 if(input_A1_0==1'd1&&Reset_A1!=4'd1&&Reset_A2!=4'd1&&Reset_A3!=4'd1)//��һ��λ���������壬������ҵ�һ��û�����ڸ�λ��
                            Reset_A4<=4'd1;        
                        else if(input_A2_0==1'd1&&Reset_A1!=4'd2&&Reset_A2!=4'd2&&Reset_A3!=4'd2)
                            Reset_A4<=4'd2;
                        else if(input_A3_0==1'd1&&Reset_A1!=4'd3&&Reset_A2!=4'd3&&Reset_A3!=4'd3)
                            Reset_A4<=4'd3;
                        else if(input_A4_0==1'd1&&Reset_A1!=4'd4&&Reset_A2!=4'd4&&Reset_A3!=4'd4)
                            Reset_A4<=4'd4;
                        else if(input_A5_0==1'd1&&Reset_A1!=4'd5&&Reset_A2!=4'd5&&Reset_A3!=4'd5)
                            Reset_A4<=4'd5;
                        else if(input_A6_0==1'd1&&Reset_A1!=4'd6&&Reset_A2!=4'd6&&Reset_A3!=4'd6)
                            Reset_A4<=4'd6;
                        else if(input_A7_0==1'd1&&Reset_A1!=4'd7&&Reset_A2!=4'd7&&Reset_A3!=4'd7)
                            Reset_A4<=4'd7;
                        else if(input_A8_0==1'd1&&Reset_A1!=4'd8&&Reset_A2!=4'd8&&Reset_A3!=4'd8)
                            Reset_A4<=4'd8;
                        else if(input_A9_0==1'd1&&Reset_A1!=4'd9&&Reset_A2!=4'd9&&Reset_A3!=4'd9)
                            Reset_A4<=4'd9;
                        else ;

            		end// If sel=0, output is a
            3'd5    : begin 
                
                if(input_A1_0==1'd1&&Reset_A1!=4'd1&&Reset_A2!=4'd1&&Reset_A3!=4'd1&&Reset_A4!=4'd1)//��һ��λ���������壬������ҵ�һ��û�����ڸ�λ��
                            Reset_A5<=4'd1;        
                        else if(input_A2_0==1'd1&&Reset_A1!=4'd2&&Reset_A2!=4'd2&&Reset_A3!=4'd2&&Reset_A4!=4'd2)
                            Reset_A5<=4'd2;
                        else if(input_A3_0==1'd1&&Reset_A1!=4'd3&&Reset_A2!=4'd3&&Reset_A3!=4'd3&&Reset_A4!=4'd3)
                            Reset_A5<=4'd3;
                        else if(input_A4_0==1'd1&&Reset_A1!=4'd4&&Reset_A2!=4'd4&&Reset_A3!=4'd4&&Reset_A4!=4'd4)
                            Reset_A5<=4'd4;
                        else if(input_A5_0==1'd1&&Reset_A1!=4'd5&&Reset_A2!=4'd5&&Reset_A3!=4'd5&&Reset_A4!=4'd5)
                            Reset_A5<=4'd5;
                        else if(input_A6_0==1'd1&&Reset_A1!=4'd6&&Reset_A2!=4'd6&&Reset_A3!=4'd6&&Reset_A4!=4'd6)
                            Reset_A5<=4'd6;
                        else if(input_A7_0==1'd1&&Reset_A1!=4'd7&&Reset_A2!=4'd7&&Reset_A3!=4'd7&&Reset_A4!=4'd7)
                            Reset_A5<=4'd7;
                        else if(input_A8_0==1'd1&&Reset_A1!=4'd8&&Reset_A2!=4'd8&&Reset_A3!=4'd8&&Reset_A4!=4'd8)
                            Reset_A5<=4'd8;
                        else if(input_A9_0==1'd1&&Reset_A1!=4'd9&&Reset_A2!=4'd9&&Reset_A3!=4'd9&&Reset_A4!=4'd9)
                            Reset_A5<=4'd9;
                        else ;

            		end// If sel=0, output is a
            		// If sel=1, output is b                   
            default  : ; 		// If sel is anything else, out is always 0
        endcase
    end
		
    else begin
        Reset_A1<=Reset_A1;
        Reset_A2<=Reset_A2;
        Reset_A3<=Reset_A3;
        Reset_A4<=Reset_A4;
        Reset_A5<=Reset_A5;	
    end
end 


//�ź�Ϊ�ߵ�ƽ��Ч
always@(*)begin
	case(cur_state)						//����߼�
										//���ݵ�ǰ״��?�������״̬ת���Д�										
		NONE:begin				        //�ȴ��������
			if(ready_flag0==1'b1)   //��������					
				next_state = IMAGE;		//λ�������{
			else 
				next_state = NONE;		//û��⵽��״̬����	
		end					
		IMAGE:begin				    //�������̵�ǰ״̬���ж���һ��״̬
			if(turn_flag==2'd1)
				next_state = ROBOT_WIN;		//λ�������]
            else if(turn_flag==2'd2)
                next_state = PEOPLE_WIN;		//λ�������]
			else if(turn_flag==2'd3)
				next_state = ADVANTAGE;		//û��⵽��״̬����
            else
                next_state = IMAGE;	
		end
		ROBOT_WIN:begin				
			
				next_state = UPDATE_BOARD;       //û��⵽��״̬����
		end	
        PEOPLE_WIN:begin				
			
				next_state = UPDATE_BOARD;       //û��⵽��״̬����
		end	
		ADVANTAGE:begin		
		
                next_state = UPDATE_BOARD;       //û��⵽��״̬����
            
		end
        UPDATE_BOARD:begin		
		
                next_state = JUDGE_WIN;       //û��⵽��״̬����
            
		end
        JUDGE_WIN:begin		
		
                next_state = NONE;       //û��⵽��״̬����
            
		end
		default:begin				
			if(ready_flag==1'b1)   //��������					
				next_state = IMAGE;		//λ�������{
			else 
				next_state = NONE;		//û��⵽��״̬����
		end					
	endcase
end
 
//-----------------------------------------------------------------------
//--״��������Σ�ʱ���߼��������
//-----------------------------------------------------------------------

reg [2:0]A1=3'd0;
reg [2:0]A2=3'd0;
reg [2:0]A3=3'd0;
reg [2:0]A4=3'd0;
reg [2:0]A5=3'd0;
reg [2:0]A6=3'd0;
reg [2:0]A7=3'd0;
reg [2:0]A8=3'd0;
reg [2:0]A9=3'd0;






reg [3:0]SUM1=4'd0;
reg [3:0]SUM2=4'd0;
reg [3:0]SUM3=4'd0;
reg [3:0]SUM4=4'd0;
reg [3:0]SUM5=4'd0;
reg [3:0]SUM6=4'd0;
reg [3:0]SUM7=4'd0;
reg [3:0]SUM8=4'd0;







// ����߼�����
  // ����ʤ������
always @(*) begin
    SUM1= A1 + A2 + A3;
    SUM2= A4 + A5 + A6;
    SUM3= A7 + A8 + A9;
    SUM4= A1 + A4 + A7;
    SUM5= A2 + A5 + A8;
    SUM6= A3 + A6 + A9;
    SUM7= A1 + A5 + A9;
    SUM8= A3 + A5 + A7;
end


//�ж�Ӯ��ķ�ʽ 0��ʾ��δ�ֳ������1-8��ʾ��ʽ��9��ʾƽ��


always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		win_shape <= 4'd0;				//��λ��ʼ״�W,û�зֳ����
	else if(SUM1==4'd12||SUM1==4'd3)win_shape <= 4'd1;//��һ��
	else if(SUM2==4'd12||SUM2==4'd3)win_shape <= 4'd2;//�ڶ���
	else if(SUM3==4'd12||SUM3==4'd3)win_shape <= 4'd3;//������
    else if(SUM4==4'd12||SUM4==4'd3)win_shape <= 4'd4;//��һ��
    else if(SUM5==4'd12||SUM5==4'd3)win_shape <= 4'd5;//�ڶ���
    else if(SUM6==4'd12||SUM6==4'd3)win_shape <= 4'd6;//������
    else if(SUM7==4'd12||SUM7==4'd3)win_shape <= 4'd7;//���ϵ�����
    else if(SUM8==4'd12||SUM8==4'd3)win_shape <= 4'd8;//���ϵ�����
    else if(input_cnt==3'd5)win_shape <= 4'd9;         //ƽ��
    else 
        win_shape <= win_shape;		//�Ν�ת�Ƶ��֞W
end 


  





always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		motor_flag <= 4'd0;					//��λ����ʼ״��
        A1<=3'd0;
        A2<=3'd0;
        A3<=3'd0;
        A4<=3'd0;
        A5<=3'd0;
        A6<=3'd0;
        A7<=3'd0;
        A8<=3'd0;
        A9<=3'd0;
        
        Reset_1<=4'd0;
        Reset_2<=4'd0;
        Reset_3<=4'd0;
        Reset_4<=4'd0;
        
        
        
        turn_flag<=2'd0;
        win_flag <=2'd0;
        end
	else
		case(cur_state)					//���ݵ�ǰ״���������
			IMAGE:begin
   
                        if(SUM1==4'd8||SUM2==4'd8||SUM3==4'd8||SUM4==4'd8
                         ||SUM5==4'd8||SUM6==4'd8||SUM7==4'd8||SUM8==4'd8)
                         
                            turn_flag<=2'd1;    //������Ӯ
                            
                        else if(SUM1==4'd2||SUM2==4'd2||SUM3==4'd2||SUM4==4'd2
                         ||SUM5==4'd2||SUM6==4'd2||SUM7==4'd2||SUM8==4'd2 )
                         
                            turn_flag<=2'd2;    //����Ӯ

                        else 
                            turn_flag<=2'd3;
                            
                        motor_flag <= 4'd0;		//����
                end
			ROBOT_WIN:	    
                begin
                //*****************������Ӯ****************************//
                        if(SUM1==4'd8)begin
                            if(A1==3'd0)
                                motor_flag <=4'd1;		
                            else if(A2==3'd0)
                                motor_flag <=4'd2;
                            else
                                motor_flag <=4'd3;
                            end
                        else if(SUM2==4'd8)begin
                            if(A4==3'd0)
                                motor_flag <=4'd4;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd6;
                            end
                        
                        else if(SUM3==4'd8)begin
                            if(A7==3'd0)
                                motor_flag <=4'd7;		
                            else if(A8==3'd0)
                                motor_flag <=4'd8;
                            else
                                motor_flag <=4'd9;
                            end
                        
                        else if(SUM4==4'd8)begin
                            if(A1==3'd0)
                                motor_flag <=4'd1;		
                            else if(A4==3'd0)
                                motor_flag <=4'd4;
                            else
                                motor_flag <=4'd7;
                            end
                        
                        else if(SUM5==4'd8)begin
                            if(A2==3'd0)
                                motor_flag <=4'd2;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd8;
                            end
                        
                        else if(SUM6==4'd8)begin
                            if(A3==3'd0)
                                motor_flag <=4'd3;		
                            else if(A6==3'd0)
                                motor_flag <=4'd6;
                            else
                                motor_flag <=4'd9;
                            end
                        
                        else if(SUM7==4'd8)begin
                            if(A1==3'd0)
                                motor_flag <=4'd1;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd9;
                            end
                        
                        else if(SUM8==4'd8)begin
                            if(A3==3'd0)
                                motor_flag <=4'd3;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd7;
                            end
                        
                        else motor_flag <=4'd0;
                        
                         
               
                    end
                    
            PEOPLE_WIN:begin
                        if(SUM1==4'd2)begin
                            if(A1==3'd0)
                                motor_flag <=4'd1;		
                            else if(A2==3'd0)
                                motor_flag <=4'd2;
                            else
                                motor_flag <=4'd3;
                            end
                        else if(SUM2==4'd2)begin
                            if(A4==3'd0)
                                motor_flag <=4'd4;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd6;
                            end
                        
                        else if(SUM3==4'd2)begin
                            if(A7==3'd0)
                                motor_flag <=4'd7;		
                            else if(A8==3'd0)
                                motor_flag <=4'd8;
                            else
                                motor_flag <=4'd9;
                            end
                        
                        else if(SUM4==4'd2)begin
                            if(A1==3'd0)
                                motor_flag <=4'd1;		
                            else if(A4==3'd0)
                                motor_flag <=4'd4;
                            else
                                motor_flag <=4'd7;
                            end
                        
                        else if(SUM5==4'd2)begin
                            if(A2==3'd0)
                                motor_flag <=4'd2;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd8;
                            end
                        
                        else if(SUM6==4'd2)begin
                            if(A3==3'd0)
                                motor_flag <=4'd3;		
                            else if(A6==3'd0)
                                motor_flag <=4'd6;
                            else
                                motor_flag <=4'd9;
                            end
                        
                        else if(SUM7==4'd2)begin
                            if(A1==3'd0)
                                motor_flag <=4'd1;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd9;
                            end
                        
                        else if(SUM8==4'd2)begin
                            if(A3==3'd0)
                                motor_flag <=4'd3;		
                            else if(A5==3'd0)
                                motor_flag <=4'd5;
                            else
                                motor_flag <=4'd7;
                            end
                        
                        else motor_flag <=4'd0;   
                     
                end
            
            
			ADVANTAGE:  begin
                    
            if(input_cnt==3'd2&&A1==4'd1&&A5==4'd4&&A9==4'd1)         //�����BUG
                motor_flag<=4'd2; 
            else if(input_cnt==3'd2&&A3==4'd1&&A5==4'd4&&A7==4'd1)
                motor_flag<=4'd2; 
            else if(A5==3'd0)
                motor_flag<=4'd5;       
            else if(A1==3'd0)
                motor_flag<=4'd1;
  
            else if(A3==3'd0)
                motor_flag<=4'd3;
   
            else if(A7==3'd0)
                motor_flag<=4'd7;
                
            else if(A9==3'd0)
                motor_flag<=4'd9;
     
            else if(A2==3'd0)
                motor_flag<=4'd2;
       
            else if(A4==3'd0)
                motor_flag<=4'd4;
              
            else if(A6==3'd0)
                motor_flag<=4'd6;
              
            else if(A8==3'd0)
                motor_flag<=4'd8;
            
            else motor_flag<=4'd0;
            
           
            
   
            end //״̬�Ľ���
                    
            UPDATE_BOARD:   //��������״̬
                    begin
                        
                        //������������Ҫ����
                            if (input_cnt==3'd1&&win_flag==2'd0)begin    //�������˵�һ������δ�ֳ�ʤ��
                                case(motor_flag)
                                  4'd1    : begin A1 <=3'd4; Reset_1<=4'd1;		end    // If sel=0, output is a
                                  4'd2    : begin A2 <=3'd4; Reset_1<=4'd2;	    end         // If sel=1, output is b
                                  4'd3    : begin A3 <=3'd4; Reset_1<=4'd3;		end        // If sel=2, output is c
                                  4'd4    : begin A4 <=3'd4; Reset_1<=4'd4;		end// If sel=0, output is a
                                  4'd5    : begin A5 <=3'd4; Reset_1<=4'd5;		end// If sel=1, output is b
                                  4'd6    : begin A6 <=3'd4; Reset_1<=4'd6;		end// If sel=2, output is c
                                  4'd7    : begin A7 <=3'd4; Reset_1<=4'd7; 		end// If sel=0, output is a
                                  4'd8    : begin A8 <=3'd4; Reset_1<=4'd8; 		end// If sel=1, output is b
                                  4'd9    : begin A9 <=3'd4; Reset_1<=4'd9;		end// If sel=2, output is c                      
                                  default  : ; 		// If sel is anything else, out is always 0
                                endcase
                            end
                            else if(input_cnt==3'd2&&win_flag==2'd0)begin
                                    case(motor_flag)
                                      4'd1    : begin A1 <=3'd4; Reset_2<=4'd1;		end    // If sel=0, output is a
                                      4'd2    : begin A2 <=3'd4; Reset_2<=4'd2;	    end         // If sel=1, output is b
                                      4'd3    : begin A3 <=3'd4; Reset_2<=4'd3;		end        // If sel=2, output is c
                                      4'd4    : begin A4 <=3'd4; Reset_2<=4'd4;		end// If sel=0, output is a
                                      4'd5    : begin A5 <=3'd4; Reset_2<=4'd5;		end// If sel=1, output is b
                                      4'd6    : begin A6 <=3'd4; Reset_2<=4'd6;		end// If sel=2, output is c
                                      4'd7    : begin A7 <=3'd4; Reset_2<=4'd7; 	end// If sel=0, output is a
                                      4'd8    : begin A8 <=3'd4; Reset_2<=4'd8; 	end// If sel=1, output is b
                                      4'd9    : begin A9 <=3'd4; Reset_2<=4'd9;		end// If sel=2, output is c                      
                                      default  : ; 		// If sel is anything else, out is always 0
                                    endcase
                                end
                            else if(input_cnt==3'd3&&win_flag==2'd0)begin
                                    case(motor_flag)
                                      4'd1    : begin A1 <=3'd4; Reset_3<=4'd1;		end    // If sel=0, output is a
                                      4'd2    : begin A2 <=3'd4; Reset_3<=4'd2;	    end         // If sel=1, output is b
                                      4'd3    : begin A3 <=3'd4; Reset_3<=4'd3;		end        // If sel=2, output is c
                                      4'd4    : begin A4 <=3'd4; Reset_3<=4'd4;		end// If sel=0, output is a
                                      4'd5    : begin A5 <=3'd4; Reset_3<=4'd5;		end// If sel=1, output is b
                                      4'd6    : begin A6 <=3'd4; Reset_3<=4'd6;		end// If sel=2, output is c
                                      4'd7    : begin A7 <=3'd4; Reset_3<=4'd7; 	end// If sel=0, output is a
                                      4'd8    : begin A8 <=3'd4; Reset_3<=4'd8; 	end// If sel=1, output is b
                                      4'd9    : begin A9 <=3'd4; Reset_3<=4'd9;		end// If sel=2, output is c                      
                                      default  : ; 		// If sel is anything else, out is always 0
                                    endcase
                                end
                            else if(input_cnt==3'd4&&win_flag==2'd0)begin
                                    case(motor_flag)
                                      4'd1    : begin A1 <=3'd4; Reset_4<=4'd1;		end    // If sel=0, output is a
                                      4'd2    : begin A2 <=3'd4; Reset_4<=4'd2;	    end         // If sel=1, output is b
                                      4'd3    : begin A3 <=3'd4; Reset_4<=4'd3;		end        // If sel=2, output is c
                                      4'd4    : begin A4 <=3'd4; Reset_4<=4'd4;		end// If sel=0, output is a
                                      4'd5    : begin A5 <=3'd4; Reset_4<=4'd5;		end// If sel=1, output is b
                                      4'd6    : begin A6 <=3'd4; Reset_4<=4'd6;		end// If sel=2, output is c
                                      4'd7    : begin A7 <=3'd4; Reset_4<=4'd7; 	end// If sel=0, output is a
                                      4'd8    : begin A8 <=3'd4; Reset_4<=4'd8; 	end// If sel=1, output is b
                                      4'd9    : begin A9 <=3'd4; Reset_4<=4'd9;		end// If sel=2, output is c                      
                                      default  : ; 		// If sel is anything else, out is always 0
                                    endcase
                            end
                            else begin  //��δ��ʤʱ
                                case(motor_flag)
                                      4'd1    : A1 <=3'd4;    // If sel=0, output is a
                                      4'd2    : A2 <=3'd4;         // If sel=1, output is b
                                      4'd3    : A3 <=3'd4;        // If sel=2, output is c
                                      4'd4    : A4 <=3'd4;// If sel=0, output is a
                                      4'd5    : A5 <=3'd4;// If sel=1, output is b
                                      4'd6    : A6 <=3'd4;// If sel=2, output is c
                                      4'd7    : A7 <=3'd4;// If sel=0, output is a
                                      4'd8    : A8 <=3'd4;// If sel=1, output is b
                                      4'd9    : A9 <=3'd4;// If sel=2, output is c                      
                                      default  : ; 		// If sel is anything else, out is always 0
                                endcase
                            end
                    end
                      
            JUDGE_WIN:   //��������״̬
                            begin
                        //����Ȩ����4���˵�Ȩ����1
                        if(SUM1==4'd12||SUM2==4'd12||SUM3==4'd12||SUM4==4'd12
                         ||SUM5==4'd12||SUM6==4'd12||SUM7==4'd12||SUM8==4'd12)//����Ӯ
                            win_flag <=2'd3;
                        else if(SUM1==4'd3||SUM2==4'd3||SUM3==4'd3||SUM4==4'd3//��Ӯ
                         ||SUM5==4'd3||SUM6==4'd3||SUM7==4'd3||SUM8==4'd3)
                            win_flag <=2'd2;
                        else if(input_cnt==3'd5) //�������5�֣����һ�������4�ֻ���û��Ӯ��ƽ��
                            win_flag <=2'd1;        
                        else  
                            win_flag <=2'd0;     //��û�ֳ����
                      end


                        
                       
                        
			NONE:	    
                    begin
                    motor_flag <= 4'd0;
                    turn_flag<=2'd0;  
                   
                       
                    
                        if(input_A1==1'd1)
                            A1<=3'd1;        //���±�ʾ1
                        if(input_A2==1'd1)
                            A2<=3'd1;
                        if(input_A3==1'd1)
                            A3<=3'd1;
                        if(input_A4==1'd1)
                            A4<=3'd1;
                        if(input_A5==1'd1)
                            A5<=3'd1;
                        if(input_A6==1'd1)
                            A6<=3'd1;
                        if(input_A7==1'd1)
                            A7<=3'd1;
                        if(input_A8==1'd1)
                            A8<=3'd1;
                        if(input_A9==1'd1)
                            A9<=3'd1;
                        else ;
                    
                    end
            
            
			default:    motor_flag <= 4'd0;
		endcase
end
 
endmodule


                         