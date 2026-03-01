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
    assign o_alu_input_sel =    is_immed_arith_instr | is_mem_load_instr | is_mem_store_instr | is_jump_link_instr;                 // Set when an immed is used
    assign o_alu_op_sel[0] =    (is_reg_arith_instr | is_immed_arith_instr) ? (i_funct3[0] | (i_funct3 == 3'b010))  : 1'b0;        
    assign o_alu_op_sel[1] =    (is_reg_arith_instr | is_immed_arith_instr) ? i_funct3[1]                           : 1'b0;
    assign o_alu_op_sel[2] =    (is_reg_arith_instr | is_immed_arith_instr) ? i_funct3[2]                           : 1'b0;
    assign o_alu_sub_sel =      ((is_reg_arith_instr) & (i_funct3 == 3'b000)) ? i_funct7[5]    : 1'b0;
    assign o_alu_sign_sel =     ((is_reg_arith_instr | is_immed_arith_instr) & (i_funct3 == 3'b011)) ? 1'b1           : (is_branch_instr) ? i_funct3[1]   : 1'b0;
    assign o_alu_arith_sel =    ((is_reg_arith_instr | is_immed_arith_instr) & (i_funct3 == 3'b101)) ? i_funct7[5]    : 1'b0;

    // PC Select Control
    assign o_jump_type_sel =    is_jump_link_instr;
    assign o_jump_sel =         is_jump_link_instr | is_jump_instr;

    // Data Memory Control
    assign o_dmem_wr_en =       is_mem_store_instr;
    assign o_dmem_rd_en =       is_mem_load_instr;

    // Write Back Control
    wire is_auipc_instr = (i_opcode == 7'b001_0111);
    assign o_reg_wr_sel[0] =    is_auipc_instr | is_mem_load_instr; // Set then selector is 1 or 3
    assign o_reg_wr_sel[1] =    is_upper_immed_instr;               // Set when the selector is 2 or 3
    assign o_reg_wr_sel[2] =    is_jump_instr | is_jump_link_instr; // Set when the selector is 4
    assign o_reg_wr_en =        is_reg_arith_instr | is_immed_arith_instr | is_upper_immed_instr | is_mem_load_instr | is_jump_instr | is_jump_link_instr;
   

endmodule

`default_nettype wire