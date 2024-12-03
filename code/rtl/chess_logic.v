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
    input ready_flag,   //玩家按键按下，图像识别完毕
    
    output reg  [3:0] motor_flag ,//输出信号给控制电朿 d1~d9
    output reg  [1:0] win_flag, //3机器赢 2人赢 1平局 0还未分出结果
    
    //定义4个变量用于判断，复位时机器状态
    output reg [3:0]Reset_1,
    output reg [3:0]Reset_2,
    output reg [3:0]Reset_3,
    output reg [3:0]Reset_4,

    output reg [3:0]Reset_A1,
    output reg [3:0]Reset_A2,
    output reg [3:0]Reset_A3,
    output reg [3:0]Reset_A4,
    output reg [3:0]Reset_A5,
    
    output reg [3:0]win_shape  //判断赢棋方式
);


reg [1:0]turn_flag=2'd0;
//人下棋权重为1，机器下棋权重为4，空棋表礿0

//------------<状濁机参数定义>------------------------------------------
parameter   IMAGE       = 3'b001,//棋盘更新
			ROBOT_WIN   = 3'b010,//位置在右辿
            PEOPLE_WIN  = 3'b011,
			ADVANTAGE   = 3'b100,//位置在中闿
            UPDATE_BOARD= 3'b101,//更新棋盘
            JUDGE_WIN   = 3'b110,
			NONE        = 3'b000;//左右中位置传感器未检测到信号
			
//------------<reg定义>-------------------------------------------------
reg	[2:0]	cur_state;					//定义现濁寄存器
reg	[2:0]	next_state;					//定义次濁寄存器
 
//-----------------------------------------------------------------------
//--状濁机第一段：同步时序描述状濁转秿
//-----------------------------------------------------------------------
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		cur_state <= NONE;				//复位初始状濿
	else
		cur_state <= next_state;		//次濁转移到现濿
end
 
//打拍一个周期使得有时间给棋盘更新
reg ready_flag0;
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		ready_flag0 <= 1'b0;				//复位初始状濿
	else
		ready_flag0 <= ready_flag;		//次濁转移到现濿
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

//由于输出时序图的原因需要打一拍信号才不会错位
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n) begin
		input_A1_0<= 1'b0;				//复位初始状濿
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
//--状濁机第二段：组合逻辑判断状濁转移条件，描述状濁转移规律以及输凿
//-----------------------------------------------------------------------
reg [2:0]input_cnt;
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		input_cnt <= 3'b0;				//复位初始状濿
	else   if(ready_flag==1'b1)
		input_cnt <= input_cnt+3'b1;		//次濁转移到现濿
    else 
        input_cnt <= input_cnt;		//次濁转移到现濿
end 

//判断玩家棋子位置
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		Reset_A1<=4'd0;
        Reset_A2<=4'd0;
        Reset_A3<=4'd0;
        Reset_A4<=4'd0;
        Reset_A5<=4'd0;			//复位初始状濿
        end
	else if(win_flag==2'd0)begin 
          case(input_cnt)
            3'd1    : begin 
                        if(input_A1_0==1'd1)
                            Reset_A1<=4'd1;        //人下表示1
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
                    if(input_A1_0==1'd1&&Reset_A1!=4'd1)//第一颗位置棋子下棋，并且玩家第一手没有下在该位置
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
                    if(input_A1_0==1'd1&&Reset_A1!=4'd1&&Reset_A2!=4'd1)//第一颗位置棋子下棋，并且玩家第一手没有下在该位置
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
                 if(input_A1_0==1'd1&&Reset_A1!=4'd1&&Reset_A2!=4'd1&&Reset_A3!=4'd1)//第一颗位置棋子下棋，并且玩家第一手没有下在该位置
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
                
                if(input_A1_0==1'd1&&Reset_A1!=4'd1&&Reset_A2!=4'd1&&Reset_A3!=4'd1&&Reset_A4!=4'd1)//第一颗位置棋子下棋，并且玩家第一手没有下在该位置
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


//信号为高电平有效
always@(*)begin
	case(cur_state)						//组合逻辑
										//根据当前状濁?输入进行状态转换判斿										
		NONE:begin				        //等待玩家输入
			if(ready_flag0==1'b1)   //按键按下					
				next_state = IMAGE;		//位置在左辿
			else 
				next_state = NONE;		//没检测到则状态保挿	
		end					
		IMAGE:begin				    //根据棋盘当前状态，判断下一个状态
			if(turn_flag==2'd1)
				next_state = ROBOT_WIN;		//位置在中闿
            else if(turn_flag==2'd2)
                next_state = PEOPLE_WIN;		//位置在中闿
			else if(turn_flag==2'd3)
				next_state = ADVANTAGE;		//没检测到则状态保挿
            else
                next_state = IMAGE;	
		end
		ROBOT_WIN:begin				
			
				next_state = UPDATE_BOARD;       //没检测到则状态保挿
		end	
        PEOPLE_WIN:begin				
			
				next_state = UPDATE_BOARD;       //没检测到则状态保挿
		end	
		ADVANTAGE:begin		
		
                next_state = UPDATE_BOARD;       //没检测到则状态保挿
            
		end
        UPDATE_BOARD:begin		
		
                next_state = JUDGE_WIN;       //没检测到则状态保挿
            
		end
        JUDGE_WIN:begin		
		
                next_state = NONE;       //没检测到则状态保挿
            
		end
		default:begin				
			if(ready_flag==1'b1)   //按键按下					
				next_state = IMAGE;		//位置在左辿
			else 
				next_state = NONE;		//没检测到则状态保挿
		end					
	endcase
end
 
//-----------------------------------------------------------------------
//--状濁机第三段：时序逻辑描述输出
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







// 组合逻辑部分
  // 计算胜利条件
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


//判断赢棋的方式 0表示尚未分出结果，1-8表示方式，9表示平局


always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		win_shape <= 4'd0;				//复位初始状濿,没有分出结果
	else if(SUM1==4'd12||SUM1==4'd3)win_shape <= 4'd1;//第一行
	else if(SUM2==4'd12||SUM2==4'd3)win_shape <= 4'd2;//第二行
	else if(SUM3==4'd12||SUM3==4'd3)win_shape <= 4'd3;//第三行
    else if(SUM4==4'd12||SUM4==4'd3)win_shape <= 4'd4;//第一列
    else if(SUM5==4'd12||SUM5==4'd3)win_shape <= 4'd5;//第二列
    else if(SUM6==4'd12||SUM6==4'd3)win_shape <= 4'd6;//第三列
    else if(SUM7==4'd12||SUM7==4'd3)win_shape <= 4'd7;//左上到右下
    else if(SUM8==4'd12||SUM8==4'd3)win_shape <= 4'd8;//右上到左下
    else if(input_cnt==3'd5)win_shape <= 4'd9;         //平局
    else 
        win_shape <= win_shape;		//次濁转移到现濿
end 


  





always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		motor_flag <= 4'd0;					//复位、初始状怿
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
		case(cur_state)					//根据当前状濁进行输凿
			IMAGE:begin
   
                        if(SUM1==4'd8||SUM2==4'd8||SUM3==4'd8||SUM4==4'd8
                         ||SUM5==4'd8||SUM6==4'd8||SUM7==4'd8||SUM8==4'd8)
                         
                            turn_flag<=2'd1;    //机器能赢
                            
                        else if(SUM1==4'd2||SUM2==4'd2||SUM3==4'd2||SUM4==4'd2
                         ||SUM5==4'd2||SUM6==4'd2||SUM7==4'd2||SUM8==4'd2 )
                         
                            turn_flag<=2'd2;    //人能赢

                        else 
                            turn_flag<=2'd3;
                            
                        motor_flag <= 4'd0;		//右移
                end
			ROBOT_WIN:	    
                begin
                //*****************机器能赢****************************//
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
                    
            if(input_cnt==3'd2&&A1==4'd1&&A5==4'd4&&A9==4'd1)         //王烽光BUG
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
            
           
            
   
            end //状态的结束
                    
            UPDATE_BOARD:   //更新棋盘状态
                    begin
                        
                        //机器下完棋需要更新
                            if (input_cnt==3'd1&&win_flag==2'd0)begin    //机器下了第一步并且未分出胜负
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
                            else begin  //仍未获胜时
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
                      
            JUDGE_WIN:   //更新棋盘状态
                            begin
                        //机器权重是4，人的权重是1
                        if(SUM1==4'd12||SUM2==4'd12||SUM3==4'd12||SUM4==4'd12
                         ||SUM5==4'd12||SUM6==4'd12||SUM7==4'd12||SUM8==4'd12)//机器赢
                            win_flag <=2'd3;
                        else if(SUM1==4'd3||SUM2==4'd3||SUM3==4'd3||SUM4==4'd3//人赢
                         ||SUM5==4'd3||SUM6==4'd3||SUM7==4'd3||SUM8==4'd3)
                            win_flag <=2'd2;
                        else if(input_cnt==3'd5) //玩家下了5手，并且机器下了4手还是没人赢，平局
                            win_flag <=2'd1;        
                        else  
                            win_flag <=2'd0;     //还没分出结果
                      end


                        
                       
                        
			NONE:	    
                    begin
                    motor_flag <= 4'd0;
                    turn_flag<=2'd0;  
                   
                       
                    
                        if(input_A1==1'd1)
                            A1<=3'd1;        //人下表示1
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


                         