module IF_ID_2
(

    input clk,
    input [63:0] PC_addr,
    input [31:0] Instruc,
    output reg [63:0] PC_store,
    output reg [31:0] Instr_store
);




always @(negedge clk) begin
    PC_store = PC_addr;
    Instr_store = Instruc;
    
end



endmodule // IF_ID  