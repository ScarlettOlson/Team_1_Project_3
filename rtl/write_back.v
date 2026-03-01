`default_nettype none

module wrBack(
    input wire          i_clk,
    input wire          i_rst,

    // Control Signals
    input wire [2:0]    i_reg_wr_sel,

    // Input Data
    input wire [31:0]   i_alu_result,
    input wire [31:0]   i_shifted_mem_data,
    input wire [31:0]   i_pc_immed,
    input wire [31:0]   i_immed,
    input wire [31:0]   i_next_pc_addr,

    // Ouputer Data
    output wire [31:0]  o_wr_back_data

);
    assign o_wr_back_data = (i_reg_wr_sel == 3'b000) ? i_alu_result :
                            (i_reg_wr_sel == 3'b001) ? i_shifted_mem_data:
                            (i_reg_wr_sel == 3'b010) ? i_immed:
                            (i_reg_wr_sel == 3'b011) ? i_pc_immed:
                            (i_reg_wr_sel == 3'b100) ? i_next_pc_addr: 32'h00000000;

endmodule

`default_nettype wire