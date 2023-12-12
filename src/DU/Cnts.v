module CntS #(
    parameter               WIDTH               = 16,   //2^16 = 32768
    parameter               RST_VLU             = 0     //计数器复位初值
)(
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst_n,  //复位使能低电平有效
    input                   [WIDTH-1:0]         d,      //置数，任意数大小
    input                   [ 0 : 0]            ce,     //计数使能信号，高电平时计数器数值次数变化

    output      reg         [WIDTH-1:0]         q       //计数器当前数值
);

always @(posedge clk) begin
    if (!rst_n)  //复位使能低电平有效，把q置于设定的初始值
        q <= RST_VLU;
    else if (ce) begin
        if (q == 0)    
            q <= d;
        else
            q <= q - 1;
    end
    else
        q <= q;
end
endmodule
