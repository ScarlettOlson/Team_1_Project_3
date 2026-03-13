`default_nettype none

module id_exe_reg (
    input wire          i_clk,

    // From IF Stage
    input wire [31:0]   i_instr,
    input wire [31:0]   i_imem_raddr,
    input wire [31:0]   i_pc,
    input wire [31:0]   i_pc_plus_4,

    // From ID Stage
    input wire [4:0]    i_reg_rd_addr,
    input wire [4:0]    i_reg_rs1_addr,
    input wire [4:0]    i_reg_rs2_addr,
    input wire [31:0]   i_reg_rs1_data,
    input wire [31:0]   i_reg_rs2_data,
    input wire [31:0]   i_immed,
    input wire [2:0]    i_alu_op_sel,
    input wire          i_alu_input_sel,
    input wire          i_alu_sub_sel,
    input wire          i_alu_sign_sel,
    input wire          i_alu_arith_sel,
    input wire          i_jump_type_sel,
    input wire          i_jump_sel,
    input wire          i_dmem_wr_en,
    input wire          i_dmem_rd_en,
    input wire [2:0]    i_reg_wr_sel,
    input wire          i_reg_wr_en,
    input wire          i_halt_signal,
    input wire          i_trap_signal,
    input wire          i_stall,
    input wire [2:0]    i_funct3,
    input wire [6:0]    i_funct7,
    input wire [5:0]    i_instr_format,

    // Outputs
    output wire [31:0]  o_instr,
    output wire [31:0]  o_imem_raddr,
    output wire [31:0]  o_pc,
    output wire [31:0]  o_pc_plus_4,

    output wire [4:0]   o_reg_rd_addr,
    output wire [4:0]   o_reg_rs1_addr,
    output wire [4:0]   o_reg_rs2_addr,
    output wire [31:0]  o_reg_rs1_data,
    output wire [31:0]  o_reg_rs2_data,
    output wire [31:0]  o_immed,
    output wire [2:0]   o_alu_op_sel,
    output wire         o_alu_input_sel,
    output wire         o_alu_sub_sel,
    output wire         o_alu_sign_sel,
    output wire         o_alu_arith_sel,
    output wire         o_jump_type_sel,
    output wire         o_jump_sel,
    output wire         o_dmem_wr_en,
    output wire         o_dmem_rd_en,
    output wire [2:0]   o_reg_wr_sel,
    output wire         o_reg_wr_en,
    output wire         o_halt_signal,
    output wire         o_trap_signal,
    output wire         o_stall,
    output wire [2:0]   o_funct3,
    output wire [6:0]   o_funct7,
    output wire [5:0]   o_instr_format
);

    // IF stage registers
    reg [31:0]   instr;
    reg [31:0]  imem_raddr;
    reg [31:0]  pc;
    reg [31:0]  pc_plus_4;

    // ID stage registers
    reg [4:0]   reg_rd_addr;
    reg [4:0]   reg_rs1_addr;
    reg [4:0]   reg_rs2_addr;
    reg [31:0]  reg_rs1_data;
    reg [31:0]  reg_rs2_data;
    reg [31:0]  immed;
    reg [2:0]   alu_op_sel;
    reg         alu_input_sel;
    reg         alu_sub_sel;
    reg         alu_sign_sel;
    reg         alu_arith_sel;
    reg         jump_type_sel;
    reg         jump_sel;
    reg         dmem_wr_en;
    reg         dmem_rd_en;
    reg [2:0]   reg_wr_sel;
    reg         reg_wr_en;
    reg         halt_signal;
    reg         trap_signal;
    reg         stall;
    reg [2:0]   funct3;
    reg [6:0]   funct7;
    reg [5:0]   instr_format;

    always @(posedge i_clk) begin
        // IF stage
        instr           <= i_instr;
        imem_raddr      <= i_imem_raddr;
        pc              <= i_pc;
        pc_plus_4       <= i_pc_plus_4;

        // ID stage
        reg_rd_addr     <= i_reg_rd_addr;
        reg_rs1_addr    <= i_reg_rs1_addr;
        reg_rs2_addr    <= i_reg_rs2_addr;
        reg_rs1_data    <= i_reg_rs1_data;
        reg_rs2_data    <= i_reg_rs2_data;
        immed           <= i_immed;
        alu_op_sel      <= i_alu_op_sel;
        alu_input_sel   <= i_alu_input_sel;
        alu_sub_sel     <= i_alu_sub_sel;
        alu_sign_sel    <= i_alu_sign_sel;
        alu_arith_sel   <= i_alu_arith_sel;
        jump_type_sel   <= i_jump_type_sel;
        jump_sel        <= i_jump_sel;
        dmem_wr_en      <= i_dmem_wr_en;
        dmem_rd_en      <= i_dmem_rd_en;
        reg_wr_sel      <= i_reg_wr_sel;
        reg_wr_en       <= i_reg_wr_en;
        halt_signal     <= i_halt_signal;
        trap_signal     <= i_trap_signal;
        stall           <= i_stall;
        funct3          <= i_funct3;
        funct7          <= i_funct7;
        instr_format    <= i_instr_format;
    end

    // Outputs
    assign o_instr        = instr;
    assign o_imem_raddr   = imem_raddr;
    assign o_pc           = pc;
    assign o_pc_plus_4    = pc_plus_4;

    assign o_reg_rd_addr  = reg_rd_addr;
    assign o_reg_rs1_addr = reg_rs1_addr;
    assign o_reg_rs2_addr = reg_rs2_addr;
    assign o_reg_rs1_data = reg_rs1_data;
    assign o_reg_rs2_data = reg_rs2_data;
    assign o_immed        = immed;
    assign o_alu_op_sel   = alu_op_sel;
    assign o_alu_input_sel = alu_input_sel;
    assign o_alu_sub_sel  = alu_sub_sel;
    assign o_alu_sign_sel = alu_sign_sel;
    assign o_alu_arith_sel = alu_arith_sel;
    assign o_jump_type_sel = jump_type_sel;
    assign o_jump_sel      = jump_sel;
    assign o_dmem_wr_en    = dmem_wr_en;
    assign o_dmem_rd_en    = dmem_rd_en;
    assign o_reg_wr_sel    = reg_wr_sel;
    assign o_reg_wr_en     = reg_wr_en;
    assign o_halt_signal   = halt_signal;
    assign o_trap_signal   = trap_signal;
    assign o_stall         = stall;
    assign o_funct3        = funct3;
    assign o_funct7        = funct7;
    assign o_instr_format  = instr_format;

endmodule

`default_nettype wire
