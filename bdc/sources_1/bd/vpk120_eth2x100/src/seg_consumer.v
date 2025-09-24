module seg_consumer
(
    input        clk,
    input[127:0] seg_tdata,
    input[ 15:0] seg_tkeep,
    input[  1:0] seg_tuser,
    input        seg_tvalid,
    output reg   seg_tready
);

always @(posedge clk) begin
    seg_tready <= 1;
end

endmodule
