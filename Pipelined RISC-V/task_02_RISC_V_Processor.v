module RISC_V_Processor_2
(
    input clk, reset
);

wire [63:0] PC_to_IM;
wire [31:0] IM_to_IFID;
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
wire [63:0] ReadData1_out, ReadData2_out;
wire [63:0] imm_data_out;



wire [63:0] fixed_4 = 64'd4;
wire [63:0] PC_plus_4_to_mux;

wire [63:0] alu_mux_out;

wire [63:0] alu_result_out;
wire zero_out;

wire [63:0] imm_to_adder;
wire [63:0] imm_adder_to_mux;

wire [63:0] DM_Read_Data_out;

wire pc_mux_sel_wire;

wire IDEX_Branch_out, IDEX_MemRead_out, IDEX_MemtoReg_out,
IDEX_MemWrite_out, IDEX_ALUSrc_out, IDEX_RegWrite_out;

//IDEX WIRES
wire [63:0] IDEX_PC_addr, IDEX_ReadData1_out, IDEX_ReadData2_out,
            IDEX_imm_data_out;
wire [3:0] IDEX_funct_in;
wire [4:0] IDEX_rd_out;
wire [1:0] IDEX_ALUOp_out;

assign imm_to_adder = IDEX_imm_data_out<< 1;


//EXMEM WIRES
wire EXMEM_Branch_out, EXMEM_MemRead_out, EXMEM_MemtoReg_out,
EXMEM_MemWrite_out, EXMEM_RegWrite_out; 
wire EXMEM_zero_out, EXMEM_Is_Greater_out;
wire [63:0] EXMEM_PC_plus_imm, EXMEM_alu_result_out,
    EXMEM_ReadData2_out;
wire [3:0] EXMEM_funct_in;
wire [4:0] EXMEM_rd_out;

//MEMWB WIRES
wire MEMWB_MemtoReg_out, MEMWB_RegWrite_out;
wire [63:0] MEMWB_DM_Read_Data_out, MEMWB_alu_result_out;
wire [4:0] MEMWB_rd_out;


mux_2 pc_mux
(
    .a(EXMEM_PC_plus_imm),   //value when sel is 1
    .b(PC_plus_4_to_mux),
    .sel(pc_mux_sel_wire),
    .data_out(mux_to_pc_in)
);

Program_Counter_2 PC (
    .clk(clk), 
    .reset(reset),
    .PC_In(mux_to_pc_in),
    .PC_Out(PC_to_IM)
);

Adder_2 PC_plus_4
(
    .A(PC_to_IM),
    .B(fixed_4),
    .out(PC_plus_4_to_mux)
);

Instruction_Memory_2 IM
(
    .Inst_Address(PC_to_IM),
    .Instruction(IM_to_IFID)
);

wire [63:0] IFID_PC_addr;
wire [31:0] IFID_IM_to_parse;

IF_ID_2 IF_ID1
(
    .clk(clk),
    .PC_addr(PC_to_IM),
    .Instruc(IM_to_IFID),
    .PC_store(IFID_PC_addr),
    .Instr_store(IFID_IM_to_parse)
);
//IF_ID HERE


instruc_parse_2 instruc_parse1
(
    .instruc(IFID_IM_to_parse),
    .opcode(opcode_out),
    .rd(rd_out),
    .funct3(funct3_out),
    .rs1(rs1_out),
    .rs2(rs2_out),
    .funct7(funct7_out)
);

wire [3:0] funct_in;
assign funct_in = {IFID_IM_to_parse[30],IFID_IM_to_parse[14:12]};

Control_Unit_2 control_unit1
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


registerFile_2 reg_file
(
    .clk(clk),
    .reset(reset),
    .RegWrite(MEMWB_RegWrite_out), //change
    .WriteData(mux_to_reg),//??
    .RS1(rs1_out),
    .RS2(rs2_out),
    .RD(MEMWB_rd_out),    //??
    .ReadData1(ReadData1_out),
    .ReadData2(ReadData2_out) 
);


imm_data_ext_2 immediate_ext
(
    .instruc(IFID_IM_to_parse),
    .imm_data(imm_data_out)
);



ID_EX_2 ID_EX1
(
    .clk(clk),
    .PC_addr(IFID_PC_addr),
    .read_data1(ReadData1_out),
    .read_data2(ReadData2_out),
    .imm_val(imm_data_out),
    .funct_in(funct_in),
    .rd_in(rd_out),
    .RegWrite(RegWrite_out),
    .MemtoReg(MemtoReg_out),
    .Branch(Branch_out),
    .MemWrite(MemWrite_out),
    .MemRead(MemRead_out),
    .ALUSrc(ALUSrc_out),
    .ALU_op(ALUOp_out),

    .PC_addr_store(IDEX_PC_addr),
    .read_data1_store(IDEX_ReadData1_out),
    .read_data2_store(IDEX_ReadData2_out),
    .imm_val_store(IDEX_imm_data_out),
    .funct_in_store(IDEX_funct_in),
    .rd_in_store(IDEX_rd_out),
    .RegWrite_store(IDEX_RegWrite_out),
    .MemtoReg_store(IDEX_MemtoReg_out),
    .Branch_store(IDEX_Branch_out),
    .MemWrite_store(IDEX_MemWrite_out),
    .MemRead_store(IDEX_MemRead_out),
    .ALUSrc_store(IDEX_ALUSrc_out),
    .ALU_op_store(IDEX_ALUOp_out)

);
// ID/EX HERE

ALU_Control_2 ALU_Control1
(
    .ALUOp(IDEX_ALUOp_out),
    .Funct(IDEX_funct_in),
    .Operation(ALU_C_Operation)
);


mux_2 ALU_mux
(
    .a(IDEX_imm_data_out), //value when sel is 1
    .b(IDEX_ReadData2_out),
    .sel(IDEX_ALUSrc_out),
    .data_out(alu_mux_out)
);


ALU_64_bit_2 ALU64
(
    .a(IDEX_ReadData1_out),
    .b(alu_mux_out), 
    .ALUOp(ALU_C_Operation),
    .Result(alu_result_out),
    .Zero(zero_out),
    .Is_Greater(Is_Greater_out)
);

wire [63:0] pcplusimm_to_EXMEM;

Adder_2 PC_plus_imm
(
    .A(IDEX_PC_addr),
    .B(imm_to_adder),
    .out(pcplusimm_to_EXMEM) //
);



EX_MEM_2 EX_MEM1
(
    .clk(clk),
    .RegWrite(IDEX_RegWrite_out),
    .MemtoReg(IDEX_MemtoReg_out),
    .Branch(IDEX_Branch_out),
    .Zero(zero_out),
    .Is_Greater(Is_Greater_out),
    .MemWrite(IDEX_MemWrite_out),
    .MemRead(IDEX_MemRead_out),
    .PCplusimm(pcplusimm_to_EXMEM),
    .ALU_result(alu_result_out),
    .WriteData(IDEX_ReadData2_out),
    .funct_in(IDEX_funct_in),
    .rd(IDEX_rd_out),

    .RegWrite_store(EXMEM_RegWrite_out),
    .MemtoReg_store(EXMEM_MemtoReg_out),
    .Branch_store(EXMEM_Branch_out),
    .Zero_store(EXMEM_zero_out),
    .Is_Greater_store(EXMEM_Is_Greater_out),
    .MemWrite_store(EXMEM_MemWrite_out),
    .MemRead_store(EXMEM_MemRead_out),
    .PCplusimm_store(EXMEM_PC_plus_imm),
    .ALU_result_store(EXMEM_alu_result_out),
    .WriteData_store(EXMEM_ReadData2_out),
    .funct_in_store(EXMEM_funct_in),
    .rd_store(EXMEM_rd_out)
);

// EX/MEM HERE

Branch_Control_2 Branch_Control
(
    .Branch(EXMEM_Branch_out),
    .Zero(EXMEM_zero_out),
    .Is_Greater(EXMEM_Is_Greater_out),
    .funct(EXMEM_funct_in),
    .switch_branch(pc_mux_sel_wire)
);

Data_Memory_2 Data_Memory
(
    .Mem_Addr(EXMEM_alu_result_out),
    .Write_Data(EXMEM_ReadData2_out),
    .clk(clk),
    .MemWrite(EXMEM_MemWrite_out),
    .MemRead(EXMEM_MemRead_out),
    .Read_Data(DM_Read_Data_out) 
);



MEM_WB_2 MEM_WB1
(
    .clk(clk),
    .RegWrite(EXMEM_RegWrite_out),
    .MemtoReg(EXMEM_MemtoReg_out),
    .ReadData(DM_Read_Data_out),
    .ALU_result(EXMEM_alu_result_out),
    .rd(EXMEM_rd_out),

    .RegWrite_store(MEMWB_RegWrite_out),
    .MemtoReg_store(MEMWB_MemtoReg_out),
    .ReadData_store(MEMWB_DM_Read_Data_out),
    .ALU_result_store(MEMWB_alu_result_out),
    .rd_store(MEMWB_rd_out)
);

// MEM/WB HERE

mux_2 mux2
(
    .a(MEMWB_DM_Read_Data_out), //value when sel is 1
    .b(MEMWB_alu_result_out),
    .sel(MEMWB_MemtoReg_out),
    .data_out(mux_to_reg)
);




// always @(posedge clk) 
//     begin
//         $monitor("PC_In = ", mux_to_pc_in, ", PC_Out = ", PC_to_IM, 
//         ", Instruction = %b", IM_to_parse,", Opcode = %b", opcode_out, 
//         ", Funct3 = %b", funct3_out, ", rs1 = %d", rs1_out,
//         ", rs2 = %d", rs2_out, ", rd = %d", rd_out, ", funct7 = %b", funct7_out,
//         ", ALUOp = %b", ALUOp_out, ", imm_value = %d", imm_data_out,
//          ", Operation = %b", ALU_C_Operation);
//     end

endmodule // RISC_V_Processor