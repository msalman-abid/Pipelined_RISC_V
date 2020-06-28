module RISC_V_Processor_1(
    input clk, reset
);

wire [63:0] PC_to_IM;
wire [31:0] IM_to_parse;
wire [6:0] opcode_out; 
wire[4:0] rd_out;
wire [2:0] funct3_out;
wire [6:0] funct7_out;
wire [4:0] rs1_out, rs2_out;
wire Branch_out, MemRead_out, MemtoReg_out, MemWrite_out, ALUSrc_out, RegWrite_out;
wire Is_Greater_out;
wire [1:0] ALUOp_out;
wire [63:0] mux_to_reg;
wire [63:0] mux_to_pc_in;
wire [3:0] ALU_C_Operation;



Program_Counter_1 PC (
    .clk(clk), 
    .reset(reset),
    .PC_In(mux_to_pc_in),
    .PC_Out(PC_to_IM)
);

Instruction_Memory_1 IM
(
    .Inst_Address(PC_to_IM),
    .Instruction(IM_to_parse)
);

instruc_parse_1 instruc_parse1
(
    .instruc(IM_to_parse),
    .opcode(opcode_out),
    .rd(rd_out),
    .funct3(funct3_out),
    .rs1(rs1_out),
    .rs2(rs2_out),
    .funct7(funct7_out)
);

Control_Unit_1 control_unit1
(
    .Opcode(opcode_out),
    .Branch(Branch_out), 
    .MemRead(MemRead_out), 
    .MemtoReg(MemtoReg_out), 
    .MemWrite(MemWrite_out), 
    .ALUSrc(ALUSrc_out),
    .RegWrite(RegWrite_out),
    .ALUOp(ALUOp_out)
);

wire [63:0] ReadData1_out, ReadData2_out;

registerFile_1 reg_file
(
    .clk(clk),
    .reset(reset),
    .RegWrite(RegWrite_out),
    .WriteData(mux_to_reg),
    .RS1(rs1_out),
    .RS2(rs2_out),
    .RD(rd_out),
    .ReadData1(ReadData1_out),
    .ReadData2(ReadData2_out) 
);

wire [63:0] imm_data_out;

imm_data_ext_1 immediate_ext
(
    .instruc(IM_to_parse),
    .imm_data(imm_data_out)
);

wire [3:0] funct_in;
assign funct_in = {IM_to_parse[30],IM_to_parse[14:12]};

ALU_Control_1 ALU_Control1
(
    .ALUOp(ALUOp_out),
    .Funct(funct_in),
    .Operation(ALU_C_Operation)
);

wire [63:0] alu_mux_out;

mux_1 ALU_mux
(
    .a(imm_data_out), //value when sel is 1
    .b(ReadData2_out),
    .sel(ALUSrc_out),
    .data_out(alu_mux_out)
);

wire [63:0] alu_result_out;
wire zero_out;

ALU_64_bit_1 ALU64
(
    .a(ReadData1_out),
    .b(alu_mux_out), 
    .ALUOp(ALU_C_Operation),
    .Result(alu_result_out),
    .Zero(zero_out),
    .Is_Greater(Is_Greater_out)
);

wire [63:0] DM_Read_Data_out;

Data_Memory_1 Data_Memory
(
    .Mem_Addr(alu_result_out),
    .Write_Data(ReadData2_out),
    .clk(clk),
    .MemWrite(MemWrite_out),
    .MemRead(MemRead_out),
    .Read_Data(DM_Read_Data_out) 
);


mux_1 mux2
(
    .a(DM_Read_Data_out), //value when sel is 1
    .b(alu_result_out),
    .sel(MemtoReg_out),
    .data_out(mux_to_reg)
);

wire [63:0] fixed_4 = 64'd4;
wire [63:0] PC_plus_4_to_mux;

Adder_1 PC_plus_4
(
    .A(PC_to_IM),
    .B(fixed_4),
    .out(PC_plus_4_to_mux)
);

wire [63:0] imm_to_adder;
assign imm_to_adder = imm_data_out << 1;
wire [63:0] imm_adder_to_mux;

Adder_1 PC_plus_imm
(
    .A(PC_to_IM),
    .B(imm_to_adder),
    .out(imm_adder_to_mux)
);

wire pc_mux_sel_wire;

Branch_Control_1 Branch_Control
(
    .Branch(Branch_out),
    .Zero(zero_out),
    .Is_Greater(Is_Greater_out),
    .funct(funct_in),
    .switch_branch(pc_mux_sel_wire)
);


mux_1 pc_mux
(
    .a(imm_adder_to_mux),   //value when sel is 1
    .b(PC_plus_4_to_mux),
    .sel(pc_mux_sel_wire),
    .data_out(mux_to_pc_in)
);

always @(posedge clk) 
    begin
        $monitor("PC_In = ", mux_to_pc_in, ", PC_Out = ", PC_to_IM, 
        ", Instruction = %b", IM_to_parse,", Opcode = %b", opcode_out, 
        ", Funct3 = %b", funct3_out, ", rs1 = %d", rs1_out,
        ", rs2 = %d", rs2_out, ", rd = %d", rd_out, ", funct7 = %b", funct7_out,
        ", ALUOp = %b", ALUOp_out, ", imm_value = %d", imm_data_out,
         ", Operation = %b", ALU_C_Operation);
    end

endmodule // RISC_V_Processor