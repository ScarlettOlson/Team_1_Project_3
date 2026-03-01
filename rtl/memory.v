`default_nettype none

module mem(
    input wire          i_clk,
    input wire          i_rst,

    // Memory Connection Pass Through
    output wire [31:0]  o_dmem_addr,
    output wire         o_dmem_ren,
    output wire         o_dmem_wen,
    output wire [31:0]  o_dmem_wdata,
    output wire [3:0]   o_dmem_mask,
    input wire [31:0]   i_dmem_rdata,

    // Control Signals
    input wire          i_dmem_rd_en,
    input wire          i_dmem_wr_en,
    input wire [2:0]    i_funct3,

    // Input Data
    input wire [31:0]   i_alu_result,
    input wire [31:0]   i_reg_rs2_data,
    
    
    // Output Data
    output wire [31:0]  o_dmem_shifted_data
);
    // Create shift values
    wire [4:0] shift_amt;
    assign shift_amt = {i_reg_rs2_data[1:0], 3'b000};

    // Connect Input Shifter
    wire [31:0] dmem_input_data;
    shifter memInputShifter(
        .val(i_reg_rs2_data),
        .shamt(shift_amt),
        .shift_right(1'b1),
        .shift_arith(1'b0),
        .shifted_val(dmem_input_data)
    );

    // Connect Mask Generator
    wire [3:0] mask;
    memCntr memoryControl(
        .i_funct3(i_funct3),
        .i_pos(i_alu_result[1:0]),
        .is_store(i_dmem_wr_en),

        .o_dmem_mask(mask)
    );

    // Connect Memory Module Pass Through
    assign o_dmem_addr =    {i_alu_result[31:2], 2'b00};
    assign o_dmem_ren =     i_dmem_rd_en;
    assign o_dmem_wen =     i_dmem_wr_en;
    assign o_dmem_wdata =   dmem_input_data;
    assign o_dmem_mask =    mask;
    wire [31:0] dmem_data_out;
    assign dmem_data_out =  i_dmem_rdata;

    

    wire [31:0] dmem_shifted_data;
    shifter memoryOutputShifter(
        .val(dmem_data_out),
        .shamt(shift_amt),
        .shift_right(1'b1),
        .shift_arith(i_funct3[2]),
        .shifted_val(dmem_shifted_data)
    );
    assign o_dmem_shifted_data = mask[3]                 ? dmem_shifted_data :
                                 mask[1] & !i_funct3[2]  ? {{16{dmem_shifted_data[15]}}, dmem_shifted_data[15:0]} :
                                 mask[1] & i_funct3[2]   ? {{16{1'b0}}, dmem_shifted_data[15:0]} :
                                 !i_funct3[2]            ? {{24{dmem_shifted_data[7]}}, dmem_shifted_data[7:0]}   :
                                                           {{24{1'b0}}, dmem_shifted_data[7:0]};
    
endmodule

`default_nettype wire