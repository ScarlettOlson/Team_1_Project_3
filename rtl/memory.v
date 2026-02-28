`default_nettype none

module mem(
    input wire          i_clk,
    input wire          i_rst,

    // Control Signals
    input wire          i_dmem_rd_en,
    input wire          i_dmem_wr_en,
    input wire [2:0]    i_funct3,
    input wire          i_zero_extend,

    // Mmeory Pass Through
    output wire [31:0] o_dmem_wdata,
    output wire [ 3:0] o_dmem_mask,
    input  wire [31:0] i_dmem_rdata,

    // Input Data
    input wire [31:0]   i_alu_result,
    input wire [31:0]   i_reg_rs2_data,
    
    // Ouput Data
    output wire [31:0]  o_dmem_data
);
    // Create shift values
    wire [4:0] shift_amt;
    assign shift_amt = {i_reg_rs2_data[1:0], 3'b000};


    // Connect shifters
    shifter memInputShifter(
        .val(i_alu_result),
        .shamt(shift_amt),
        .shift_right(1'b1),
        .shift_arith(1'b0),
        .shifted_val(o_dmem_data)
    );
    shifter memoryOutputShifter(
        .val(i_dmem_rdata),
        .shamt(shift_amt),
        .shift_right(1'b1),
        .shift_arith(i_zero_extend),
        .shifted_val(o_dmem_wdata)
    );

    // Connect Mask Generator
    memCntr memoryControl(
        .i_funct3(i_funct3),
        .i_pos(i_reg_rs2_data[1:0]),

        .o_dmem_mask(o_dmem_mask)
    );
endmodule

`default_nettype wire