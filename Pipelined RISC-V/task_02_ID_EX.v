module ID_EX_2
(
    input clk,
    input [63:0] PC_addr,
    input [63:0] read_data1, read_data2,
    input [63:0] imm_val,
    input [3:0] funct_in,
    input [4:0] rd_in,
    input MemtoReg, RegWrite,
    input Branch, MemWrite, MemRead,
    input ALUSrc,
    input [1:0] ALU_op,

    output reg [63:0] PC_addr_store,
    output reg [63:0] read_data1_store, read_data2_store,
    output reg [63:0] imm_val_store,
    output reg [3:0] funct_in_store,
    output reg [4:0] rd_in_store,
    output reg MemtoReg_store, RegWrite_store,
    output reg Branch_store, MemWrite_store, MemRead_store,
    output reg ALUSrc_store,
    output reg [1:0] ALU_op_store

);

always @(negedge clk) begin
    PC_addr_store = PC_addr;
    read_data1_store = read_data1;
    read_data2_store = read_data2;
    imm_val_store = imm_val;
    funct_in_store = funct_in;
    rd_in_store = rd_in;
    RegWrite_store = RegWrite;
    MemtoReg_store = MemtoReg;
    Branch_store = Branch;
    MemWrite_store = MemWrite;
    MemRead_store = MemRead;
    ALUSrc_store = ALUSrc;
    ALU_op_store = ALU_op;

end



endmodule // ID_EX