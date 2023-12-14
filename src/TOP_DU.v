module Top_DU(
    input                   [ 0 : 0]            rstn,  //复位使能低电平有效
    input                   [ 0 : 0]            clk_px, //pixel clk,于 800x600@72Hz 的规格，应当选用 50MHz
    input                   [11 : 0]            rdata,

    output                  [14 : 0]            raddr,
    output                  [11 : 0]            rgb,
    output                  [ 0 : 0]            hs,     //行同步
    output                  [ 0 : 0]            vs      //场同步,传递给 VGA 显示器用于同步
);
    wire        temp_hen,temp_ven;
DST u_DST(
    .rst_n(rstn),
    .clk_px(clk_px),

    .hen(temp_hen),
    .ven(temp_ven),
    .hs(hs),
    .vs(vs)
);

DDP u_DDP(
    .hen(temp_hen),
    .ven(temp_ven),
    .rstn(rstn),
    .pclk(clk_px),
    .rdata(.rdata),

    .rgb(rgb),
    .raddr(raddr)
);

endmodule