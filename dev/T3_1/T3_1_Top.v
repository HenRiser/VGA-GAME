module Top_DU(
    input                   [ 0 : 0]            rstn,  //复位使能低电平有效
    input                   [ 0 : 0]            CLK100MHZ, //pixel clk,于 800x600@72Hz 的规格，应当选用 50MHz

    // output      reg         [ 0 : 0]            hen,    //水平显示有效
    // output      reg         [ 0 : 0]            ven,    //垂直显示有效,传递给 DDP 用于产生坐标
    output      reg         [ 0 : 0]            hs,     //行同步
    output      reg         [ 0 : 0]            vs      //场同步,传递给 VGA 显示器用于同步
);
    wire        clk_px,locked;
myclock u_50m_myclock(
    .clk_in1(CLK100MHZ)      // input clk_in1
    .reset(!rstn), // input reset

    .locked(locked),       // output locked
    .clk_out50m(clk_px),     // output clk_out50m
);
DST u_DST(
    .rst_n(rstn),
    .clk_px(clk_px),

    .hen(),
    .ven(),
    .hs(hs),
    .vs(vs),
);
endmodule