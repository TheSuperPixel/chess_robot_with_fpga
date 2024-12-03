// Descriptions:        �����λ

module motor_reset(
    input sys_clk,
    input sys_rst_n,
    input [2:0] signial,//�������ź�����
    
    output reg  [1:0] motor_flag //����źŸ�driver���Ƶ��

);

//signial[0]    ���    motor_flag <= 2'd1;		//����
//signial[1]    �м�    motor_flag <= 2'd0;		//����
//signial[2]    �ұ�    motor_flag <= 2'd2;		//����

//------------<״̬����������>------------------------------------------
parameter	LEFT  = 2'b11,//λ�������
			RIGHT = 2'b10,//λ�����ұ�
			HALF  = 2'b01,//λ�����м�
			NONE  = 2'b00;//������λ�ô�����δ��⵽�ź�
			
//------------<reg����>-------------------------------------------------
reg	[1:0]	cur_state;					//������̬�Ĵ���
reg	[1:0]	next_state;					//�����̬�Ĵ���
 
//-----------------------------------------------------------------------
//--״̬����һ�Σ�ͬ��ʱ������״̬ת��
//-----------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		cur_state <= NONE;				//��λ��ʼ״̬
	else
		cur_state <= next_state;		//��̬ת�Ƶ���̬
end
 
//-----------------------------------------------------------------------
//--״̬���ڶ��Σ�����߼��ж�״̬ת������������״̬ת�ƹ����Լ����
//-----------------------------------------------------------------------

//�ź�Ϊ�ߵ�ƽ��Ч
always@(*)begin
	case(cur_state)						//����߼�
										//���ݵ�ǰ״̬���������״̬ת���ж�										
		NONE:begin				
			if(signial[0])					
				next_state = LEFT;		//λ�������
            else if(signial[1])
                next_state = HALF;		//λ�����м�
            else if(signial[2])
                next_state = RIGHT;		//λ�����ұ�
			else 
				next_state = NONE;		//û��⵽��״̬����	
		end					
		LEFT:begin				
			if(signial[1])
				next_state = HALF;		//λ�����м�
			else 
				next_state = NONE;		//û��⵽��״̬����
		end
		RIGHT:begin				
			if(signial[1])
				next_state = HALF;		//λ�����м�
			else                        
				next_state = NONE;       //û��⵽��״̬����
		end	
		HALF:begin				
			                        
				next_state = HALF;      //ʹ��״̬�������м�
		end
		default:begin				
			if(signial[0])					
				next_state = LEFT;		//Ͷ��1Ԫ����״̬ת�Ƶ�ONE
            else if(signial[1])
                next_state = HALF;		//Ͷ��1Ԫ����״̬ת�Ƶ�ONE
            else if(signial[2])
                next_state = RIGHT;		//Ͷ��1Ԫ����״̬ת�Ƶ�ONE
			else 
				next_state = NONE;		//û��Ͷ�ң���״̬����	
		end					
	endcase
end
 
//-----------------------------------------------------------------------
//--״̬�������Σ�ʱ���߼��������
//-----------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		motor_flag <= 2'b1;					//��λ����ʼ״̬ 
	else
		case(cur_state)					//���ݵ�ǰ״̬�������
			LEFT:	motor_flag <= 2'd1;		//����			
			RIGHT:	motor_flag <= 2'd2;		//����
			HALF:	motor_flag <= 2'd0;		//λ�ñ������м䣬���ֹͣ����
			NONE:	motor_flag <= motor_flag;//
			default:motor_flag <= motor_flag;//
		endcase
end
 
endmodule


                         