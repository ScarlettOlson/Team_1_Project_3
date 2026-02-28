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
    output wire [2:0]   o_reg_wr_sel,
    output wire         o_reg_wr_en,

    // HALT SIGNAL STOPS EXE
    output wire         o_halt,
    output wire         o_trap

);
    // Gernerate Instruction Format
    wire is_reg_arith_instr =   (i_opcode == 7'b011_0011);
    wire is_immed_arith_instr = (i_opcode == 7'b001_0011);
    wire is_upper_immed_instr = (i_opcode == 7'b011_0111) | (i_opcode == 7'b001_0111);    
    wire is_mem_load_instr =    (i_opcode == 7'b000_0011);
    wire is_mem_store_instr =   (i_opcode == 7'b010_0011);
    wire is_branch_instr =      (i_opcode == 7'b110_0011);
    wire is_jump_instr =        (i_opcode == 7'b110_1111);
    wire is_jump_link_instr =   (i_opcode == 7'b110_0111);

    assign o_format = is_reg_arith_instr ?      6'b00_0001 :
                      is_immed_arith_instr ?    6'b00_0010 :
                      is_upper_immed_instr ?    6'b01_0000 :
                      is_mem_load_instr ?       6'b00_0010 :

                      is_mem_store_instr ?      6'b00_0100 :
                      is_branch_instr ?         6'b00_1000 :
                      is_jump_instr ?           6'b10_0000 :
                      is_jump_link_instr ?      6'b00_0010 : 7'b000_0000;
    assign o_halt = (i_opcode == 7'b111_0011);
    assign o_trap = !(o_halt | |i_opcode);


    // ALU Control Signals
    assign o_alu_input_sel =    (!i_opcode[2] & i_opcode[4] & !i_opcode[5]) | (i_opcode[2] & !i_opcode[3] & i_opcode[6]) | (!i_opcode[6] & i_opcode[5] & !i_opcode[4]);
    assign o_alu_op_sel[0] =    (i_funct3[0] | (i_funct3[1] & !i_funct3[2])) & i_opcode[4] & !i_opcode[2];
    assign o_alu_op_sel[1] =    i_funct3[1] & i_opcode[4] & i_opcode[5] & !i_opcode[2];
    assign o_alu_op_sel[2] =    i_funct3[2] & i_opcode[4] & i_opcode[5] & !i_opcode[2];
    assign o_alu_sub_sel =      i_opcode[4] & i_opcode[5] & i_funct7[5];
    assign o_alu_sign_sel =     i_opcode[4] & i_funct3[0];
    assign o_alu_arith_sel =    i_opcode[4] & i_funct7[5];

    // PC Select Control
    assign o_jump_type_sel =    (i_opcode == 7'b110_0111);
    assign o_jump_sel =         (i_opcode == 7'b110_0111) | (i_opcode == 7'b110_1111);

    // Data Memory Control
    assign o_dmem_wr_en =       o_format[2];
    assign o_dmem_rd_en =       (i_opcode == 7'b000_0011);

    // Write Back Control
    assign o_reg_wr_sel[0] =    
    assign o_reg_wr_sel[1] =    
    assign o_reg_wr_sel[2] =    
    assign o_reg_wr_en =        
   

endmodule

`default_nettype wire