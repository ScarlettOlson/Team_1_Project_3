`default_nettype none

module exe(
    input wire          i_clk,
    input wire          i_rst,

    // CONTROL SIGNALS
    // Alu Control
    input wire          i_alu_input_sel,
    input wire [2:0]    i_alu_op_sel,
    input wire          i_alu_sub_sel,
    input wire          i_alu_sign_sel,
    input wire          i_alu_arith_sel,
    // PC Control
    input wire          i_jump_type_sel,
    input wire          i_jump_sel,
    input wire          i_funct3,

    // Input Data
    input wire [31:0]   i_reg_rs1_data,
    input wire [31:0]   i_reg_rs2_data,
    input wire [31:0]   i_immed,
    input wire [31:0]   i_instr(addr),

    // OutPut Data
    output wire [31:0]  o_alu_result,
    output wire [31:0]  o_pc_immed,

    // PC Ouput
    output wire [31:0]  o_jump_addr,
    output wire         o_jump_sel
);
    // Select Alu Input
    wire [31:0] alu_input_1 =   i_reg_rs1_data;
    wire [31:0] alu_input_2 =   i_alu_op_sel ? immed : i_reg_rs2_data;

    // Connect ALU
    wire eqaul;
    wire less_than
    alu ALU (
        .i_opsel(i_alu_op_sel),

        .i_sub(i_alu_sub_sel),
        .i_unsigned(i_alu_sign_sel),
        .i_arith(i_alu_arith_sel),

        .i_op1(alu_input_1),
        .i_op2(alu_input_2),

        .o_result(o_alu_result),
        .o_eq(equal),
        .o_slt(less_than)
    );

    // Connect PC/Immediate Adder
    add_pg_32 pcAdder(
        .val1(i_instr_addr),
        .val2(i_immed),
        .carry_in(1'b0),
        .val_out(o_pc_immed),
        .carry_out(),
        .prop_out(),
        .gen_out()
    );

    // Connect Branch Control
    b_cntr branchControl(
        .i_jump(i_jump_sel),
        .i_funct3(i_funct3),

        .i_eq(equal),
        .i_slt(less_than),

        .o_jump_cntr(.o_jump_sel)
    );

    // Connect PC Jump Address
    assign o_jump_addr =        i_jump_type_sel ? {o_alu_result[31:1], 1'b0} : pc_immed;
endmodule

`default_nettype wire