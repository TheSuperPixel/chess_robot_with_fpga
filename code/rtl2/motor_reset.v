// Descriptions:        电机复位

module motor_reset(
    input sys_clk,
    input sys_rst_n,
    input [2:0] signial,//传感器信号输入
    
    output reg  [1:0] motor_flag //输出信号给driver控制电机

);

//signial[0]    左边    motor_flag <= 2'd1;		//右移
//signial[1]    中间    motor_flag <= 2'd0;		//保持
//signial[2]    右边    motor_flag <= 2'd2;		//左移

//------------<状态机参数定义>------------------------------------------
parameter	LEFT  = 2'b11,//位置在左边
			RIGHT = 2'b10,//位置在右边
			HALF  = 2'b01,//位置在中间
			NONE  = 2'b00;//左右中位置传感器未检测到信号
			
//------------<reg定义>-------------------------------------------------
reg	[1:0]	cur_state;					//定义现态寄存器
reg	[1:0]	next_state;					//定义次态寄存器
 
//-----------------------------------------------------------------------
//--状态机第一段：同步时序描述状态转移
//-----------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		cur_state <= NONE;				//复位初始状态
	else
		cur_state <= next_state;		//次态转移到现态
end
 
//-----------------------------------------------------------------------
//--状态机第二段：组合逻辑判断状态转移条件，描述状态转移规律以及输出
//-----------------------------------------------------------------------

//信号为高电平有效
always@(*)begin
	case(cur_state)						//组合逻辑
										//根据当前状态、输入进行状态转换判断										
		NONE:begin				
			if(signial[0])					
				next_state = LEFT;		//位置在左边
            else if(signial[1])
                next_state = HALF;		//位置在中间
            else if(signial[2])
                next_state = RIGHT;		//位置在右边
			else 
				next_state = NONE;		//没检测到则状态保持	
		end					
		LEFT:begin				
			if(signial[1])
				next_state = HALF;		//位置在中间
			else 
				next_state = NONE;		//没检测到则状态保持
		end
		RIGHT:begin				
			if(signial[1])
				next_state = HALF;		//位置在中间
			else                        
				next_state = NONE;       //没检测到则状态保持
		end	
		HALF:begin				
			                        
				next_state = HALF;      //使得状态保持在中间
		end
		default:begin				
			if(signial[0])					
				next_state = LEFT;		//投币1元，则状态转移到ONE
            else if(signial[1])
                next_state = HALF;		//投币1元，则状态转移到ONE
            else if(signial[2])
                next_state = RIGHT;		//投币1元，则状态转移到ONE
			else 
				next_state = NONE;		//没有投币，则状态保持	
		end					
	endcase
end
 
//-----------------------------------------------------------------------
//--状态机第三段：时序逻辑描述输出
//-----------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		motor_flag <= 2'b1;					//复位、初始状态 
	else
		case(cur_state)					//根据当前状态进行输出
			LEFT:	motor_flag <= 2'd1;		//右移			
			RIGHT:	motor_flag <= 2'd2;		//左移
			HALF:	motor_flag <= 2'd0;		//位置保持在中间，电机停止运行
			NONE:	motor_flag <= motor_flag;//
			default:motor_flag <= motor_flag;//
		endcase
end
 
endmodule


                         