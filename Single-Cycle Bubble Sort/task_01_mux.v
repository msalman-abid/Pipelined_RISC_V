module mux_1
(
    input [63:0] a, b,
    input sel,
    output [63:0] data_out   
);

assign data_out = sel ? a : b;


endmodule // 