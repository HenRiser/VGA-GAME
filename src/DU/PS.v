module PS#(
        parameter  WIDTH = 1
)
(
        input             s[WIDTH-1:0],
        input             clk,
        output     wire   p
);

reg     [WIDTH-1:0]        grabd;//用来获取S
reg     [WIDTH-1:0]        neggrab;//用来取反

always @(posedge clk) begin //时钟同步
    grabd <= s;
    neggrab <= grabd;    
end

assign p = (~grabd)&neggrab; //在下降沿抓捕


endmodule