`default_nettype none

module instrDecode(
    input wire          i_clk,
    input wire          i_rst,

    input wire [31:0]   i_instr,
    input wire [31:0]   i_reg_wr_data,
    
    // Data Signals
    output wire [4:0]   o_reg_addr_wr,
    output wire [4:0]   o_reg_addr_1,
    output wire [4:0]   o_reg_addr_2,
    output wire [31:0]  o_reg_data_1,
    output wire [31:0]  o_reg_data_2,
    output wire [31:0]  o_immed,

    // CONTROL SIGNALS
    // Alu Control
    output wire         o_alu_input_sel,
    output wire [2:0]   o_alu_op_sel,
    output wire         o_alu_sub_sel,
    output wire         o_alu_sign_sel,
    output wire         o_alu_arith_sel,
    // PC Select Control
    output wire         o_jump_type_sel, // Selects between pc+=signextend(immed) and pc = target
    output wire         o_jump_sel,      // Informs branch controller if the instruction is a jump or branch type
    // Data Memory Control
    output wire         o_dmem_wr_en,
    output wire         o_dmem_rd_en,
    // Write Back Control
    output wire [2:0]   o_reg_wr_sel,
    // HALT CONTROL SIGNAL
    output wire         o_halt,
    
    // Output function signals
    output wire [2:0]   o_funct3,
    output wire [6:0]   o_funct7,

    // Output Instruction format
    output wire [5:0]   o_format
);

    // Assign operation and function codes
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    assign opcode =         i_instr[6:0];
    assign o_funct3 =       i_instr[14:12];
    assign o_funct7 =       i_instr[31:25];

    // Connect control Unit
    wire [5:0] instr_format;
    wire reg_wr_en;
    cntrUnit controlUnit(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_opcode(opcode),
        .i_funct3(o_funct3),
        .i_funct7(o_funct7),

        .o_format(instr_format),
        .o_alu_input_sel(o_alu_input_sel),
        .o_alu_op_sel(o_alu_op_sel),
        .o_alu_sub_sel(o_alu_sub_sel),
        .o_alu_sign_sel(o_alu_sign_sel),
        .o_alu_arith_sel(o_alu_arith_sel),

        .o_jump_type_sel(o_jump_type_sel), 
        .o_jump_sel(o_jump_sel),        
    
        .o_dmem_wr_en(o_dmem_wr_en),
        .o_dmem_rd_en(o_dmem_rd_en),
        
        .o_reg_wr_sel(o_reg_wr_sel),
        .o_reg_wr_en(reg_wr_en),

        .o_halt(o_halt)
    );

    // Connect Register File
    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [4:0] rd_addr;
    assign rs1_addr =       i_instr[19:15];
    assign rs2_addr =       i_instr[24:20];
    assign rd_addr =        i_instr[11:7];
    assign o_reg_addr_1 =   rs1_addr;
    assign o_reg_addr_2 =   rs2_addr;
    assign o_reg_addr_wr =  rd_addr;
    rf registerFile(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_rs1_raddr(rs1_addr),
        .o_rs1_rdata(o_reg_data_1),

        .i_rs2_raddr(rs2_addr),
        .o_rs2_rdata(o_reg_data_2),

        .i_rd_wen(reg_wr_en),
        .i_rd_waddr(rd_addr),
        .i_rd_wdata(i_reg_wr_data)
    );

    // Connect Immediate Generator
    imm immediateGenerator(
        .i_inst(i_instr),
        .i_format(instr_format),
        .o_immediate(o_immed)
    );

    // Output the instruction format code
    assign o_format = instr_format;
endmodule

`default_nettype wire