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
    // Data Memory Contro
    output wire         o_dmem_wr_en,
    output wire         o_dmem_rd_en,
    // Write Back Control
    output wire [2:0]   o_reg_wr_sel,
    output wire         o_reg_wr_en,

    // HALT SIGNAL STOPS EXE
    output wire         o_halt

);
    // Gernerate Instruction Format
    assign o_format[0] =        !i_opcode[2] & !i_opcode[3] & i_opcode[4] & i_opcode[5] & i_opcode[6];
    assign o_format[1] =        !i_opcode[2] & i_opcode[4] & !i_opcode[5];
    assign o_format[2] =        !i_opcode[2] & !i_opcode[3] & !i_opcode[4] & i_opcode[5];
    assign o_format[3] =        !i_opcode[2] & !i_opcode[3] & !i_opcode[4] & i_opcode[5] & i_opcode[6];
    assign o_format[4] =        i_opcode[2] & i_opcode[4];
    assign o_format[5] =        i_opcode[3] &  i_opcode[6];

    // ALU Control Signals
    assign o_alu_input_sel =    (!i_opcode[2] & i_opcode[4] & !i_opcode[5]) | (i_opcode[2] & !i_opcode[3] & i_opcode[6]) | (!i_opcode[6] & i_opcode[5] & !i_opcode[4]);
    assign o_alu_op_sel[0] =    (i_funct3[0] | (i_funct3[1] & !i_funct3[2])) & i_opcode[4] & !i_opcode[2];
    assign o_alu_op_sel[1] =    i_funct3[1] & i_opcode[4] & i_opcode[5] & !i_opcode[2];
    assign o_alu_op_sel[2] =    i_funct3[2] & i_opcode[4] & i_opcode[5] & !i_opcode[2];
    assign o_alu_sub_sel =      i_opcode[4] & i_opcode[5] & i_funct7[5];
    assign o_alu_sign_sel =     i_opcode[4] & i_funct3[0];
    assign o_alu_arith_sel =    i_opcode[4] & i_funct7[5];

    // PC Select Control
    assign o_jump_type_sel =    i_opcode[6] & i_opcode[5] & !i_opcode[3] & i_opcode[2];
    assign o_jump_sel =         i_opcode[6] & i_opcode[5] & i_opcode[2];

    // Data Memory Control
    assign o_dmem_wr_en =       o_format[2];
    assign o_dmem_rd_en =       !i_opcode[4] & !i_opcode[5];

    // Write Back Control
    assign o_reg_wr_sel[0] =    i_opcode[5] & !i_opcode[6];
    assign o_reg_wr_sel[1] =    i_opcode[3] & !i_opcode[6];
    assign o_reg_wr_sel[2] =    i_opcode[6];
    assign o_reg_wr_en =        o_format[1] | o_format[4] | o_format[5];


    // Determine if the instruction is a halt 
    assign o_halt = i_opcode[6] & i_opcode[5] & i_opcode[4];
   

endmodule

`default_nettype wire