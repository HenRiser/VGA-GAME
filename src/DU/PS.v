module PS#(
        parameter  WIDTH = 1
)
(
        input             s,
        input             clk,
        output     wire   p
);

reg     [WIDTH-1:0]        grabd;//用来获取S
reg     [WIDTH-1:0]        neggrab;//用来取反

always @(posedge clk) begin
        grabd <= s;
end
always @(posedge clk) begin //时钟同步
        neggrab <= grabd;    
end

assign p = grabd&(~neggrab); //在上升沿抓捕


endmodule