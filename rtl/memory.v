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
    output wire [31:0]  o_dmem_out
);
    // Generate the mask Signal
    wire [3:0] mask;
    memCntr memoryControl(
        .i_funct3(i_funct3),
        .i_pos(i_alu_result[1:0]),
        .is_store(i_dmem_wr_en),

        .o_dmem_mask(mask)
    );
    assign o_dmem_mask =    mask;

    // Shift Write Data
    shifter memoryWriteShifter(
        .val(i_reg_rs2_data),
        .shamt({i_alu_result[1:0], 3'b000}),
        .shift_right(1'b0),
        .shift_arith(1'b0),
        .shifted_val(o_dmem_wdata)
    );

    // Connect Memory Module Pass Through
    assign o_dmem_ren =     i_dmem_rd_en;
    assign o_dmem_wen =     i_dmem_wr_en;
    assign o_dmem_addr =    {i_alu_result[31:2], 2'b00};
    
    // Load Shifter
    wire [31:0] dmem_shifted_data;
    shifter memoryLoadShifter(
        .val(i_dmem_rdata),
        .shamt({i_alu_result[1:0], 3'b000}),
        .shift_right(1'b1),
        .shift_arith(i_funct3[2]),
        .shifted_val(dmem_shifted_data)
    );

    // Determine Load Type
    wire sign_byte, sign_half, word, zero_byte, zero_half;
    assign sign_byte =  i_dmem_rd_en & i_funct3 == 3'b000;
    assign sign_half =  i_dmem_rd_en & i_funct3 == 3'b001;
    assign word =       i_dmem_rd_en & i_funct3 == 3'b010;
    assign zero_byte =  i_dmem_rd_en & i_funct3 == 3'b100;
    assign zero_half =  i_dmem_rd_en & i_funct3 == 3'b101;

    // Output Memory Shifted and extended
    assign o_dmem_out   =   sign_byte ? {{24{dmem_shifted_data[7]}}, dmem_shifted_data[7:0]} :
                            sign_half ? {{16{dmem_shifted_data[15]}}, dmem_shifted_data[15:0]} :
                            word      ? i_dmem_rdata :
                            zero_byte ? {{24{1'b0}}, dmem_shifted_data[7:0]} :
                            zero_half ? {{16{1'b0}}, dmem_shifted_data[15:0]} :
                                        32'h0000_0000;
    
endmodule

`default_nettype wire