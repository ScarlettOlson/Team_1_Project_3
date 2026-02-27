`default_nettype none

module cntrUnit(
    input wire          i_clk,
    input wire          i_rst,


    input wire [6:0]    i_opcode,
    input wire [2:0]    i_funct3,
    input wire [6:0]    i_funct7,

    // CONTROL SIGNALS
    // Instruction Format
    output wire [5:0]   o_format,
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
    output wire [2:0]   o_reg_wr_sel
    output wire         o_reg_wr_en,

    // HALT SIGNAL STOPS EXE
    output wire         o_halt,

);
    // Gernerate Instruction Format
    assign o_format[0] =        !opcode[2] & !opcode[3] & opcode[4] & opcode[5] & opcode[6];
    assign o_format[1] =        !opcode[2] & opcode[4] & !opcode[5];
    assign o_format[2] =        !opcode[2] & !opcode[3] & !opcode[4] & opcode[5];
    assign o_format[3] =        !opcode[2] & !opcode[3] & !opcode[4] & opcode[5] & opcode[6];
    assign o_format[4] =        opcode[2] & opcode[4];
    assign o_format[5] =        opcode[3] &  opcode[6];

    // ALU Control Signals
    assign o_alu_input_sel =    (!opcode[2] & opcode[4] & !opcode[5]) | (opcode[2] & !opcode[3] & opcode[6]) | (!opcode[6] & opcode[5] & !opcode[4]);
    assign o_alu_op_sel[0] =    (funct3[0] | (funct3[1] & !funct3[2])) & opcode[4] & !opcode[2];
    assign o_alu_op_sel[1] =    funct3[1] & opcode[4] & opcode[5] & !opcode[2];
    assign o_alu_op_sel[2] =    funct3[2] & opcode[4] & opcode[5] & !opcode[2];
    assign o_alu_sub_sel =      opcode[4] & opcode[5] & funct7[5];
    assign o_alu_sign_sel =     opcode[4] & funct3[0];
    assign o_alu_arith_sel =    opcode[4] & funct7[5];

    // PC Select Control
    assign o_jump_type_sel =    opcode[6] & opcode[5] & !opcode[3] & opcode[2];
    assign o_jump_sel =         opcode[6] & opcode[5] & opcode[2];

    // Data Memory Control
    assign o_dmem_wr_en =       o_format[2];
    assign o_dmem_rd_en =       !opcode[4] & !opcode[5];

    // Write Back Control
    assign o_reg_wr_sel[0] =    opcode[5] & !opcode[6];
    assign o_reg_wr_sel[1] =    opcode[3] & !opcode[6];
    assign o_reg_wr_sel[2] =    opcode[6];
    assign o_reg_wr_en =        o_format[1] | o_format[4] | o_format[5];


    // Determine if the instruction is a halt 
    assign o_halt = opcode[6] & opcode[5] & opcode[4];
   

endmodule

`default_nettype wire