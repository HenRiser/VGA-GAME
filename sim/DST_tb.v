module DST_tb();
reg                 rst_n, clk;
wire                hen,ven,hs,vs;
initial begin
    clk = 0;
    rst_n=0;#5;
    rst_n=1;
end
always #1 clk=~clk;

DST myDST(
    .rst_n(rst_n),
    .clk_px(clk),
    .hen(hen),
    .ven(ven),
    .hs(hs),
    .vs(vs)
);
endmodule
