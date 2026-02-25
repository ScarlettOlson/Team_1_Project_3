module control_unit(
    input wire [6:0] opcode
    input wire [2:0] funct3
    input wire [6:0] funct7

    output wire jump_mux,
    output wire branch_mux,
    output wire alu_mux_1,
    output wire alu2_mux,
    output wire [2:0] reg_write_mux,
    output wire branch_type_mux,
    output wire reg_write_enable,
    output wire dmem_write_enable,
    output wire dmem_read_enable,
    output wire [5:0] i_format
);
    // PC Control Mux Ouputs
    assign jump_mux = opcode[2] & opcode[3] & opcode[5] & opcode[6];
    assign branch_mux = opcode[5] & opcode[6];

    // ALU Input Mux
    assign alu_mux_1 = (!opcode[5]) | (!opcode[4] | !opcode[6]) | (opcode[2]);
    assign alu_mux_2 = opcode[5] & !opcode[3];

    // Register Write Input Selection
    assign wire rg_wr_mx_cond1 = (!op[5] & op[4] & !op[3] & op[2]);
    assign wire rg_wr_mx_cond2 = (!op[5] & !op[4] & funct3[0]);
    assign wire rg_wr_mx_cond3 = (!op[5] & !op[4] & funct3[1]);
    assign reg_write_mux[0] =  rg_wr_mx_cond1 | rg_wr_mx_cond2  | rg_wr_mx_cond3;
    assign wire rg_wr_mx_cond4 = (op[2] & !op[3] & op[4] & !op[5]);
    assign wire rg_wr_mx_cond5 = (!op[2] & !op[3] & !op[4] & f3[2]);
    assign wire rg_wr_mx_cond6 = op[6];
    assign reg_write_mux[1] =  rg_wr_mx_cond4 | rg_wr_mx_cond5  | rg_wr_mx_cond6;
    assign wire rg_wr_mx_cond7 = (!opcode[4] & !funct3[1] & !funct3[2])
    assign wire rg_wr_mx_cond8 = (opcode[2] & !opcode[3] & opcode[4] & !opcode[5])
    assign reg_write_mux[2] =  rg_wr_mx_cond6 | rg_wr_mx_cond7 | rg_wr_mx_cond8

    // Gernerate Instruction Format
    assign i_format[0] = !opcode[2] & !opcode[3] & opcode[4] & opcode[5] & opcode[6]
    assign i_format[1] = !op[2] & op[4] & !op[5]
    assign i_format[2] = !op[2] & !op[]3 & !op[4] & op[5]
    assign i_format[3] = !op[2] & !op[3] & !op[4] & op[5] & op[6]
    assign i_format[4] = op[2] & op[4]
    assign i_format[5] = op[3] &  op[6]



endmodule