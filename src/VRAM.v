module VGA(
    input                  [14 : 0]            waddr,
    input                  [11 : 0]            wdata,
    input                                      CLK100MHZ,
    input                                      we,
    input                                      rstn,
    output                  [0 : 0]            hs,
    output                  [0 : 0]            vs,
    output                  [11: 0]            rgb    
    );
    wire        clk_px;
clk_wiz_generate5omhzpclk u_50m_myclock(
    .clk_out50m(clk_px),     // output clk_out50m
    .reset(!rstn), // input reset
    .clk_in1(CLK100MHZ)     // input clk_in1
);

wire  [14:0]   temp_raddr;
wire  [11:0]   temp_data;
Top_DU u_DU(
    .rstn(rstn),
    .clk_px(clk_px),
    .rdata(temp_data),
    .raddr(temp_raddr),
    .rgb(rgb),
    .hs(hs),
    .vs(vs)
);


blk_mem_gen_0 u_picture(
    .clka(clk_px),
    .addra(temp_raddr),
    .douta(temp_data)
);


endmodule
