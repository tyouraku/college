`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/25 11:56:20
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
    input  reset, 
	input  clk, 
    output wire [31:0] bcd
    );

    //PC
    wire stall_PC;
    wire IF_branch;
    wire [1:0] PCSrc;
    wire [31:0] BranchAddr;
    wire [31:0] JumpAddr;
    wire [31:0] Databus1;
    wire [31:0] IF_PC;
    wire [31:0] IF_PC_4;
    wire [31:0] ID_Databus1;
    wire [31:0] ID_Databus2;   

    PC myPC(
        .clk (clk),
	    .reset (reset),
		.stall (stall_PC), 
        .Branch (IF_branch),
        .PCSrc (PCSrc),
        .Branch_target (BranchAddr),
        .Jump_target (JumpAddr),
        .ID_Databus1 (ID_Databus1),
        .PC (IF_PC),
        .PC_4 (IF_PC_4)
    );


    //Instruction Memory
    wire [31:0] IF_instr;
    
    InstMem myInstMem(
        .Address 	(IF_PC    ),
        .instr   	(IF_instr    )
    );
    

    //IF_ID
    wire [31:0] ID_instr;
    wire [31:0] ID_PC;
    wire flush_IF_ID;
    wire stall_IF_ID;
    
    IF_ID myIF_ID(
        .reset     	(reset      ),
        .clk       	(clk        ),
        .flush     	(flush_IF_ID      ),
        .stall     	(stall_IF_ID      ),
        .instr_in  	(IF_instr   ),
        .PC_4_in   	(IF_PC_4    ),
        .instr_out 	(ID_instr   ),
        .PC_4_out  	(ID_PC    )
    );
    

    //Control
    wire ID_branch;
    wire [1:0] ID_branchOp;
    wire j;
    wire jr;
    wire ID_RegWrite;
    wire [1:0] ID_RegDst;
    wire ID_MemRead;
    wire ID_MemWrite;
    wire [1:0] ID_MemtoReg;
    wire ID_ALUSrcA;
    wire ID_ALUSrcB;
    wire ID_ExtOp;
    wire ID_LuiOp;
    wire [3:0] ID_ALUOp;
    
    Control myControl(
        .OpCode   	(ID_instr[31:26]    ),
        .Funct    	(ID_instr[5:0]     ),
        .PCSrc    	(PCSrc     ),
        .Branch   	(ID_branch    ),
        .BranchOp   (ID_branchOp),
        .Jump       (j),
        .Jr         (jr),
        .RegWrite 	(ID_RegWrite  ),
        .RegDst   	(ID_RegDst    ),
        .MemRead  	(ID_MemRead   ),
        .MemWrite 	(ID_MemWrite  ),
        .MemtoReg 	(ID_MemtoReg  ),
        .ALUSrcA  	(ID_ALUSrcA   ),
        .ALUSrcB  	(ID_ALUSrcB   ),
        .ExtOp    	(ID_ExtOp     ),
        .LuiOp    	(ID_LuiOp     ),
        .ALUOp    	(ID_ALUOp     )
    );
    

    //Register File
    wire [4:0] ID_rs;
    wire [4:0] ID_rt;
    assign ID_rs = ID_instr[25:21];
    assign ID_rt = ID_instr[20:16];
    wire WB_RegWrite;
    wire [4:0] WB_Write_register;
    wire [31:0] WB_Writedata;
    
    RegisterFile myRegisterFile(
        .reset          	(reset           ),
        .clk            	(clk             ),
        .RegWrite       	(WB_RegWrite        ),
        .Read_register1 	(ID_rs  ),
        .Read_register2 	(ID_rt  ),
        .Write_register 	(WB_Write_register  ),
        .Write_data     	(WB_Writedata      ),
        .Read_data1     	(ID_Databus1      ),
        .Read_data2     	(ID_Databus2      )
    );


    //Immediate Extension
    wire [31:0] ID_Ext_out;
    wire [31:0] ID_Lui_out;
    
    ImmExt myImmExt(
        .ExtOp   	(ID_ExtOp    ),
        .LuiOp   	(ID_LuiOp    ),
        .Imm     	(ID_instr[15:0]      ),
        .Ext_out 	(ID_Ext_out  ),
        .Lui_out 	(ID_Lui_out  )
    );


    assign JumpAddr = {ID_PC[31:28], ID_instr[25:0], 2'b00};
    
    
    //ID_EX
    wire [31:0] EX_PC;
    wire [31:0] EX_instr;
    wire [31:0] EX_Imm;
    wire EX_branch;
    wire [1:0] EX_branchOp;
    wire EX_RegWrite;
    wire [1:0] EX_RegDst;
    wire EX_MemRead;
    wire EX_MemWrite;
    wire [1:0] EX_MemtoReg;
    wire EX_ALUSrcA;
    wire EX_ALUSrcB;
    wire [3:0] EX_ALUOp;
    wire [31:0] EX_Databus1;
    wire [31:0] EX_Databus2;
    wire flush_ID_EX;
    wire zero;

    ID_EX myID_EX(
        .reset        	(reset         ),
        .clk          	(clk           ),
        .flush        	(flush_ID_EX         ),
        .PC_4_in      	(ID_PC       ),
        .instr_in     	(ID_instr      ),
        .Imm_in       	(ID_Lui_out        ),
        .Branch_in    	(ID_branch     ),
        .BranchOp_in    (ID_branchOp),
        .RegWrite_in  	(ID_RegWrite   ),
        .RegDst_in    	(ID_RegDst     ),
        .MemRead_in   	(ID_MemRead    ),
        .MemWrite_in  	(ID_MemWrite   ),
        .MemtoReg_in  	(ID_MemtoReg   ),
        .ALUSrcA_in   	(ID_ALUSrcA    ),
        .ALUSrcB_in   	(ID_ALUSrcB    ),
        .ALUOp_in     	(ID_ALUOp      ),
        .DatabusA_in  	(ID_Databus1   ),
        .DatabusB_in  	(ID_Databus2   ),
        .PC_4_out     	(EX_PC      ),
        .instr_out    	(EX_instr     ),
        .Imm_out      	(EX_Imm      ),
        .Branch_out   	(EX_branch    ),
        .BranchOp_out   (EX_branchOp),
        .RegWrite_out 	(EX_RegWrite  ),
        .RegDst_out   	(EX_RegDst   ),
        .MemRead_out  	(EX_MemRead   ),
        .MemWrite_out 	(EX_MemWrite  ),
        .MemtoReg_out 	(EX_MemtoReg  ),
        .ALUSrcA_out  	(EX_ALUSrcA   ),
        .ALUSrcB_out  	(EX_ALUSrcB   ),
        .ALUOp_out    	(EX_ALUOp     ),
        .DatabusA_out 	(EX_Databus1  ),
        .DatabusB_out 	(EX_Databus2  )
    );
    
    wire branch_taken = EX_branch && zero;
    assign BranchAddr = EX_PC + {EX_Imm[29:0], 2'b00};

    //ALU
    wire [4:0] EX_ALUCtl;
    wire EX_Sign;

    ALUCtl myALUCtl(
        .ALUOp  	(EX_ALUOp   ),
        .Funct  	(EX_instr[5:0]   ),
        .ALUCtl 	(EX_ALUCtl  ),
        .Sign   	(EX_Sign    )
    );
    

    wire [31:0] EX_Regdata1;
    wire [31:0] EX_Regdata2;
    wire [1:0] EX_Forwarding_alu1;
    wire [1:0] EX_Forwarding_alu2;
    wire [31:0] MEM_ALUout;
    wire [31:0] ALU_in1;
    wire [31:0] ALU_in2;
    wire [4:0] EX_rs;
    wire [4:0] EX_rt;
    wire [4:0] EX_rd;
    wire [4:0] EX_shamt;

    //后续准备工作
    assign EX_rs = EX_instr[25:21];
    assign EX_rt = EX_instr[20:16];
    assign EX_rd = EX_instr[15:11]; 
    assign EX_shamt = EX_instr[10:6]; 
    assign EX_Regdata1 = (EX_Forwarding_alu1[0]) ? MEM_ALUout: 
                         (EX_Forwarding_alu1[1]) ? WB_Writedata: EX_Databus1;
    assign EX_Regdata2 = (EX_Forwarding_alu2[0]) ? MEM_ALUout:
                         (EX_Forwarding_alu2[1]) ? WB_Writedata: EX_Databus2;
    assign ALU_in1 = (EX_ALUSrcA)? {27'h00000, EX_shamt}: EX_Regdata1;
    assign ALU_in2 = (EX_ALUSrcB)? EX_Imm: EX_Regdata2;


    wire [31:0] EX_ALUout;
    
    ALU myALU(
        .in1    	(ALU_in1     ),
        .in2    	(ALU_in2     ),
        .ALUCtl 	(EX_ALUCtl  ),
        .Sign   	(EX_Sign    ),
        .out    	(EX_ALUout     ),
        .zero   	(zero    )
    );
    
    assign IF_branch = (EX_branch == 1'b0) ? 1'b0 :  // 不分支
                       (EX_branchOp == 2'b00) ? zero :       // beq: rs1 == rs2
                       (EX_branchOp == 2'b01) ? ~zero :      // bne: rs1 != rs2
                       1'b0;  // 其他情况默认不分支
    

    //EX_MEM
    wire MEM_RegWrite;
    wire [1:0] MEM_RegDst;
    wire MEM_MemWrite;
    wire MEM_MemRead;
    wire [1:0] MEM_MemtoReg;
    wire [4:0] MEM_rt;
    wire [4:0] MEM_rd;
    wire [31:0] MEM_Databus2;
    wire [31:0] MEM_PC;
    
    EX_MEM myEX_MEM(
        .clk          	(clk           ),
        .reset        	(reset         ),
        .RegWrite_in  	(EX_RegWrite   ),
        .RegDst_in    	(EX_RegDst     ),
        .MemWrite_in  	(EX_MemWrite   ),
        .MemRead_in   	(EX_MemRead    ),
        .MemtoReg_in  	(EX_MemtoReg   ),
        .rt_in        	(EX_rt         ),
        .rd_in        	(EX_rd         ),
        .ALUout_in    	(EX_ALUout     ),
        .Regdata_in   	(EX_Databus2    ),
        .PC_4_in      	(EX_PC       ),
        .RegWrite_out 	(MEM_RegWrite  ),
        .RegDst_out   	(MEM_RegDst    ),
        .MemWrite_out 	(MEM_MemWrite  ),
        .MemRead_out  	(MEM_MemRead   ),
        .MemtoReg_out 	(MEM_MemtoReg  ),
        .rt_out       	(MEM_rt        ),
        .rd_out       	(MEM_rd        ),
        .ALUout_out   	(MEM_ALUout    ),
        .Regdata_out  	(MEM_Databus2   ),
        .PC_4_out     	(MEM_PC      )
    );
    

    //DataMem
    wire MEM_Forwarding;
    wire [31:0] WB_ALUout;
    wire [31:0] MEM_Write_data;
    assign MEM_Write_data = (MEM_Forwarding) ? WB_ALUout : MEM_Databus2;
    wire [31:0] MEM_Read_data;
    
    DataMem #(
        .RAM_SIZE     	(512  ),
        .RAM_SIZE_BIT 	(9    ))
    myDataMem(
        .reset         	(reset          ),
        .clk           	(clk            ),
        .MemRead       	(MEM_MemRead        ),
        .MemWrite      	(MEM_MemWrite       ),
        .Address       	(MEM_ALUout        ),
        .Write_data    	(MEM_Write_data     ),
        .Read_data     	(MEM_Read_data      ),
        .BCD            (bcd)
    );
    

    //MEM_WB
    wire [4:0] MEM_Write_register;
    assign MEM_Write_register = (MEM_RegWrite==0)? 5'd0:
                                (MEM_RegDst[1]) ? 5'd31 :
                                (MEM_RegDst[0]) ? MEM_rd : MEM_rt;
    wire [1:0] WB_MemtoReg;
    wire [31:0] WB_Readdata;
    wire [31:0] WB_PC;
    
    MEM_WB myMEM_WB(
        .clk           	(clk            ),
        .reset         	(reset          ),
        .MemtoReg_in   	(MEM_MemtoReg    ),
        .RegWrite_in   	(MEM_RegWrite    ),
        .ALUout_in     	(MEM_ALUout      ),
        .Readdata_in   	(MEM_Read_data    ),
        .PC_4_in       	(MEM_PC        ),
        .Write_reg_in  	(MEM_Write_register   ),
        .MemtoReg_out  	(WB_MemtoReg   ),
        .RegWrite_out  	(WB_RegWrite   ),
        .ALUout_out    	(WB_ALUout     ),
        .Readdata_out  	(WB_Readdata   ),
        .PC_4_out      	(WB_PC       ),
        .Write_reg_out 	(WB_Write_register  )
    );
    

    wire [7:0] WB_ReadByte;
    assign WB_ReadByte = WB_ALUout[1:0] == 2'b00 ? WB_Readdata[7:0] :
                         WB_ALUout[1:0] == 2'b01 ? WB_Readdata[15:8] :
                         WB_ALUout[1:0] == 2'b10 ? WB_Readdata[23:16] : WB_Readdata[31:24];
    assign WB_Writedata = (WB_MemtoReg == 2'b11) ? {24'd0, WB_ReadByte} :
                           (WB_MemtoReg == 2'b10) ? WB_PC :
                           (WB_MemtoReg == 2'b01) ? WB_Readdata : WB_ALUout;


    //Hazard
    Hazard myHazard(
        .MemRead_ID_EX 	(EX_MemRead  ),
        .instr_ID_EX   	(EX_instr    ),
        .instr_IF_ID   	(ID_instr    ),
        .branch_taken   (branch_taken),
        .j             	(j              ),
        .jr             (jr),
        .stall_PC      	(stall_PC       ),
        .flush_IF_ID   	(flush_IF_ID    ),
        .stall_IF_ID   	(stall_IF_ID    ),
        .flush_ID_EX   	(flush_ID_EX    )
    );
    

    //Forwarding
    Forwarding myForwarding(
        .WB_target       	(WB_Write_register        ),
        .MEM_rt          	(MEM_rt           ),
        .WB_RegWrite     	(WB_RegWrite      ),
        .EX_rs           	(EX_rs            ),
        .EX_rt           	(EX_rt            ),
        .MEM_target      	(MEM_Write_register       ),
        .MEM_RegWrite    	(MEM_RegWrite     ),
        .Forwarding_MEM  	(MEM_Forwarding   ),
        .Forwarding_EX_1 	(EX_Forwarding_alu1  ),
        .Forwarding_EX_2 	(EX_Forwarding_alu2  )
    );
    

endmodule
