module DST (
    input                   [ 0 : 0]            rst_n,  //复位使能低电平有效
    input                   [ 0 : 0]            clk, //pixel clk,于 800x600@72Hz 的规格，应当选用 50MHz

    //output      reg         [ 0 : 0]            hen,    //水平显示有效
    //output      reg         [ 0 : 0]            ven,    //垂直显示有效,传递给 DDP 用于产生坐标
    output      reg         [ 0 : 0]            hs,     //行同步
    output      reg         [ 0 : 0]            vs      //场同步,传递给 VGA 显示器用于同步
);
reg [0:0] hen,ven;
wire clk_px , locked;
clkchange my(
    .clk_out1(clk_px),
    .reset(1'b1),
    .locked(locked),
    .clk_in1(clk)
);
localparam HSW_t    = 119;                              //水平同步信号的宽度，以 clk_px 为单位计算
localparam HBP_t    = 63;                               //表示从水平同步信号结束开始到一行的有效数据开始之间的 clk_px 个数
localparam HEN_t    = 799;                              //水平显示有效区域，对应水平像素分辨率
localparam HFP_t    = 55;                               //表示一行的有效数据结束到下一个水平同步信号开始之间的 clk_px 个数
                                                        //800x600@72Hz对应定时参数-1，因为0参与计数
localparam VSW_t    = 5;                                //表示垂直同步脉冲的宽度，以行数为单位计算
localparam VBP_t    = 22;                               //表示在一帧图像开始时，垂直同步信号以后的无效的行数
localparam VEN_t    = 599;                              //垂直显示有效区域，对应垂直像素分辨率
localparam VFP_t    = 36;                               //表示在一帧图像开始时，垂直同步信号以后的无效的行数

localparam SW       = 2'b00;                            //同步信号宽度
localparam BP       = 2'b01;                            //"同步信号结束"到"有效数据开始"
localparam EN       = 2'b10;                            //显示有效区域
localparam FP       = 2'b11;                            //"有效数据结束"到"下一个同步信号开始"

reg     [ 0 : 0]    ce_v;                               //垂直计数使能信号，高电平时计数器数值次数变化

reg     [ 1 : 0]    h_state;                            //水平方向上当前状态
reg     [ 1 : 0]    v_state;                            //垂直方向上当前状态

reg     [15 : 0]    d_h;                                //水平方向上置数，任意数大小
reg     [15 : 0]    d_v;                                //垂直方向上置数，任意数大小

wire    [15 : 0]    q_h;                                //水平方向上计数器当前数值
wire    [15 : 0]    q_v;                                //垂直方向上计数器当前数值

//每个时钟周期计数器增加1，表示扫描一个像素
CntS #(16,HSW_t) u_H_CntS(                              //计数器复位初值为119进行同步
    .clk        (clk_px),                 
    .rst_n      (rst_n),
    .d          (d_h),                                  //此时所在阶段的对应区域长度
    .ce         (1'b1),                                 //计数使能信号始终为1，计数器的值保持变化

    .q          (q_h)                                   //为0时表示当前d_h所代表的阶段执行完毕
);

//每行扫描完计数器增加1，表示扫描一行像素点
CntS #(16,VSW_t) u_V_CntS(                              //计数器复位初值为5进行同步
    .clk        (clk_px),                 
    .rst_n      (rst_n),
    .d          (d_v),                                  //此时所在阶段的对应区域长度
    .ce         (ce_v),                                 //计数使能信号为1时代表扫描完毕该行，对垂直方向上计数器执行加一操作

    .q          (q_v)                                   //为0时表示当前d_v所代表的阶段执行完毕
);

always @(*) begin
    case (h_state)
        SW: begin
            d_h = HBP_t;  hs = 1; hen = 0;              //此时位于同步阶段，同步信号有效
        end
        BP: begin
            d_h = HEN_t;  hs = 0; hen = 0;
        end
        EN: begin
            d_h = HFP_t;  hs = 0; hen = 1;              //此时位于显示阶段，显示信号有效
        end
        FP: begin
            d_h = HSW_t;  hs = 0; hen = 0;
        end
    endcase
    case (v_state)
        SW: begin
            d_v = VBP_t;  vs = 1; ven = 0;              //此时位于同步阶段，同步信号有效
        end
        BP: begin
            d_v = VEN_t;  vs = 0; ven = 0;
        end
        EN: begin
            d_v = VFP_t;  vs = 0; ven = 1;              //此时位于显示阶段，显示信号有效
        end
        FP: begin
            d_v = VSW_t;  vs = 0; ven = 0;
        end
    endcase
end

always @(posedge clk_px) begin
    if (!rst_n) begin
        h_state <= SW; v_state <= SW; ce_v <= 1'b0;     //复位置从复位阶段开始，垂直计数使能信号默认为0
    end
    else begin
        if(q_h == 0) begin                              //当前阶段执行完毕，垂直方向上计数器不再变化
            h_state <= h_state + 2'b01;                 //水平方向上进入下一阶段
            if (h_state == FP) begin
                ce_v <= 0;                              //上一周期已经进行了垂直方向上的计数器增加的操作，每扫描一行只进行一次该操作
                if (q_v == 0)                           //在且仅在FP阶段进行垂直方向上的状态转移操作
                    v_state <= v_state + 2'b01;         //状态变量的位宽为2，2'b11之后再加一直接溢出变为2'b00
            end
            else
                ce_v <= 0;                              
        end
        else if (q_h == 1) begin                        //当前阶段执行完毕的前一周期，相差的这一周期用于让垂直方向上的计数器变化
            if(h_state == FP)
                ce_v <= 1;                              //在且仅在FP阶段进行计数增加操作
            else
                ce_v <= 0;
        end
        else begin
            ce_v <= 0;
        end
    end
end
endmodule