`default_nettype none

module control_unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output wire alu_mux,
    output wire [2:0] reg_write_mux,
    output wire reg_write_enable,
    output wire dmem_write_enable,
    output wire dmem_read_enable,
    output wire [5:0] o_format,

    output wire [2:0] o_opsel,
    output wire o_sub,
    output wire o_arith,
    output wire o_unsigned,

    output wire o_halt
);
    // Determine if the instruction is a halt 
    assign o_halt = opcode[6] & opcode[5] & opcode[4];

    // ALU Input Mux
    assign alu_mux = (!opcode[2] & opcode[4] & !opcode[5]) | (opcode[2] & !opcode[3] & opcode[6]) | (!opcode[6] & opcode[5] & !opcode[4]);

    // Register Write Input Selection
    assign reg_write_mux[0] =  opcode[5] & !opcode[6];
    assign reg_write_mux[1] =  opcode[3] & !opcode[6];
    assign reg_write_mux[2] =  opcode[6];

    // Gernerate Instruction Format
    assign o_format[0] = !opcode[2] & !opcode[3] & opcode[4] & opcode[5] & opcode[6];
    assign o_format[1] = !opcode[2] & opcode[4] & !opcode[5];
    assign o_format[2] = !opcode[2] & !opcode[3] & !opcode[4] & opcode[5];
    assign o_format[3] = !opcode[2] & !opcode[3] & !opcode[4] & opcode[5] & opcode[6];
    assign o_format[4] = opcode[2] & opcode[4];
    assign o_format[5] = opcode[3] &  opcode[6];

    assign reg_write_enable = o_format[1] | o_format[4] | o_format[5];

    assign dmem_write_enable = o_format[2];
    assign dmem_read_enable  = !opcode[4] & !opcode[5];

    assign o_sub = opcode[4] & opcode[5] & funct7[5];
    assign o_arith = opcode[4] & funct7[5];
    assign o_unsigned = opcode[4] & funct3[0];
    assign o_opsel[0] = (funct3[0] | (funct3[1] & !funct3[2])) & opcode[4] & !opcode[2];
    assign o_opsel[1] = funct3[1] & opcode[4] & opcode[5] & !opcode[2];
    assign o_opsel[2] = funct3[2] & opcode[4] & opcode[5] & !opcode[2];
   

endmodule

`default_nettype wire