`default_nettype none

module exe_mem_reg (
    input wire        i_clk,

    // From IF Stage
    input wire [31:0] i_instr,
    input wire [31:0] i_imem_raddr,
    input wire [31:0] i_pc,

    // From ID Stage
    input wire [4:0]  i_reg_rd_addr,
    input wire [4:0]  i_reg_rs1_addr,
    input wire [4:0]  i_reg_rs2_addr,
    input wire [31:0] i_reg_rs1_data,
    input wire [31:0] i_reg_rs2_data,
    input wire [31:0] i_immed,
    input wire        i_dmem_wr_en,
    input wire        i_dmem_rd_en,
    input wire [2:0]  i_reg_wr_sel,
    input wire        i_halt_signal,
    input wire        i_trap_signal,
    input wire [2:0]  i_funct3,
    input wire [5:0]  i_instr_format,

    // From EXE Stage
    input wire [31:0] i_alu_result,
    input wire [31:0] i_jump_instr_addr,
    input wire [31:0] i_pc_immed,
    input wire        i_branch_sel,

    // Outputs
    output wire [31:0] o_instr,
    output wire [31:0] o_imem_raddr,
    output wire [31:0] o_pc,

    output wire [4:0]  o_reg_rd_addr,
    output wire [4:0]  o_reg_rs1_addr,
    output wire [4:0]  o_reg_rs2_addr,
    output wire [31:0] o_reg_rs1_data,
    output wire [31:0] o_reg_rs2_data,
    output wire [31:0] o_immed,
    output wire        o_dmem_wr_en,
    output wire        o_dmem_rd_en,
    output wire [2:0]  o_reg_wr_sel,
    output wire        o_halt_signal,
    output wire        o_trap_signal,
    output wire [2:0]  o_funct3,
    output wire [5:0]  o_instr_format,

    output wire [31:0] o_alu_result,
    output wire [31:0] o_jump_instr_addr,
    output wire [31:0] o_pc_immed,
    output wire        o_branch_sel
);

    reg [31:0] instr, imem_raddr, pc;

    reg [4:0]  reg_rd_addr, reg_rs1_addr, reg_rs2_addr;
    reg [31:0] reg_rs1_data, reg_rs2_data, immed;
    reg        jump_type_sel;
    reg        dmem_wr_en, dmem_rd_en;
    reg [2:0]  reg_wr_sel;
    reg        halt_signal, trap_signal;
    reg [2:0]  funct3;
    reg [6:0]  funct7;
    reg [5:0]  instr_format;

    reg [31:0] alu_result, jump_instr_addr, pc_immed;
    reg        branch_sel;

    always @(posedge i_clk) begin
        instr         <=    i_instr;
        imem_raddr    <=    i_imem_raddr;
        pc            <=    i_pc;

        reg_rd_addr   <=    i_reg_rd_addr;
        reg_rs1_addr  <=    i_reg_rs1_addr;
        reg_rs2_addr  <=    i_reg_rs2_addr;
        reg_rs1_data  <=    i_reg_rs1_data;
        reg_rs2_data  <=    i_reg_rs2_data;
        immed         <=    i_immed;
        dmem_wr_en    <=    i_dmem_wr_en;
        dmem_rd_en    <=    i_dmem_rd_en;
        reg_wr_sel    <=    i_reg_wr_sel;
        halt_signal   <=    i_halt_signal;
        trap_signal   <=    i_trap_signal;
        funct3        <=    i_funct3;
        instr_format  <=    i_instr_format;

        alu_result    <=    i_alu_result;
        jump_instr_addr <=  i_jump_instr_addr;
        pc_immed      <=    i_pc_immed;
        branch_sel    <=    i_branch_sel;
    end

    // Outputs
    assign o_instr        = instr;
    assign o_imem_raddr   = imem_raddr;
    assign o_pc           = pc;

    assign o_reg_rd_addr  = reg_rd_addr;
    assign o_reg_rs1_addr = reg_rs1_addr;
    assign o_reg_rs2_addr = reg_rs2_addr;
    assign o_reg_rs1_data = reg_rs1_data;
    assign o_reg_rs2_data = reg_rs2_data;
    assign o_immed        = immed;
    assign o_dmem_wr_en    = dmem_wr_en;
    assign o_dmem_rd_en    = dmem_rd_en;
    assign o_reg_wr_sel    = reg_wr_sel;
    assign o_halt_signal   = halt_signal;
    assign o_trap_signal   = trap_signal;
    assign o_funct3        = funct3;
    assign o_instr_format  = instr_format;
    
    assign o_alu_result      = alu_result;
    assign o_jump_instr_addr = jump_instr_addr;
    assign o_pc_immed        = pc_immed;
    assign o_branch_sel      = branch_sel;
endmodule

`default_nettype wire
