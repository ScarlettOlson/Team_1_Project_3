module control_unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output wire alu_mux,
    output wire [2:0] reg_write_mux,
    output wire reg_write_enable,
    output wire dmem_write_enable,
    output wire dmem_read_enable,
    output wire [5:0] i_format
);

    // ALU Input Mux
    assign alu_mux = (!opcode[2] & opcode[4] & !opcode[5]) | (opcode[2] & !opcode[3] & opcode[6]) | (!opcode[6] & opcode[5] & !opcode[4]);

    // Register Write Input Selection
    assign reg_write_mux[0] =  opcode[5] & !opcode[6];
    assign reg_write_mux[1] =  opcode[3] & !opcode[6];
    assign reg_write_mux[2] =  opcode[6];

    // Gernerate Instruction Format
    assign i_format[0] = !opcode[2] & !opcode[3] & opcode[4] & opcode[5] & opcode[6];
    assign i_format[1] = !opcode[2] & opcode[4] & !opcode[5];
    assign i_format[2] = !opcode[2] & !opcode[3] & !opcode[4] & opcode[5];
    assign i_format[3] = !opcode[2] & !opcode[3] & !opcode[4] & opcode[5] & opcode[6];
    assign i_format[4] = opcode[2] & opcode[4];
    assign i_format[5] = opcode[3] &  opcode[6];

    assign reg_write_enable = i_format[1] | i_format[4] | i_format[5];

    assign dmem_write_enable = i_format[2];
    assign dmem_read_enable  = !opcode[4] & !opcode[5];
   

endmodule