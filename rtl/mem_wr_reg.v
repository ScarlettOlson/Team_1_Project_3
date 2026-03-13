`default_nettype none

module mem_wr_reg (
    input wire        i_clk,

    // From IF Stage
    input wire [31:0]   i_instr,
    input wire [31:0]   i_imem_raddr,
    input wire [31:0]   i_pc,

    // From ID Stage
    input wire [4:0]    i_reg_rd_addr,
    input wire [4:0]    i_reg_rs1_addr,
    input wire [4:0]    i_reg_rs2_addr,
    input wire [31:0]   i_reg_rs1_data,
    input wire [31:0]   i_reg_rs2_data,
    input wire [31:0]   i_immed,
    input wire [2:0]    i_reg_wr_sel,
    input wire          i_reg_wr_en,
    input wire          i_halt_signal,
    input wire          i_trap_signal,
    input wire          i_stall,
    input wire [5:0]    i_instr_format,

    // From EXE Stage
    input wire [31:0]   i_alu_result,
    input wire [31:0]   i_pc_immed,
    input wire [31:0]   i_next_instr_addr,

    // From Mem Stage
    input wire [31:0]   i_dmem_addr,
    input wire          i_dmem_ren,
    input wire          i_dmem_wen,
    input wire [3:0]    i_dmem_mask,
    input wire [31:0]   i_dmem_wdata,
    input wire [31:0]   i_dmem_rdata,
    input wire [31:0]   i_dmem_out,

    // Outputs
    output wire [31:0]  o_instr,
    output wire [31:0]  o_imem_raddr,
    output wire [31:0]  o_pc,

    output wire [4:0]   o_reg_rd_addr,
    output wire [4:0]   o_reg_rs1_addr,
    output wire [4:0]   o_reg_rs2_addr,
    output wire [31:0]  o_reg_rs1_data,
    output wire [31:0]  o_reg_rs2_data,
    output wire [31:0]  o_immed,
    output wire [2:0]   o_reg_wr_sel,
    output wire         o_reg_wr_en,
    output wire         o_halt_signal,
    output wire         o_trap_signal,
    output wire         o_stall,
    output wire [5:0]   o_instr_format,

    output wire [31:0]  o_alu_result,
    output wire [31:0]  o_pc_immed,
    output wire [31:0]  o_next_instr_addr,

    // From Mem Stage
    output wire [31:0]  o_dmem_addr,
    output wire         o_dmem_ren,
    output wire         o_dmem_wen,
    output wire [3:0]   o_dmem_mask,
    output wire [31:0]  o_dmem_wdata,
    output wire [31:0]  o_dmem_rdata,
    output wire [31:0]  o_dmem_out
);

    reg [31:0] instr, imem_raddr, pc;

    reg [4:0]  reg_rd_addr, reg_rs1_addr, reg_rs2_addr;
    reg [31:0] reg_rs1_data, reg_rs2_data, immed;
    reg [2:0]  reg_wr_sel;
    reg        reg_wr_en;
    reg        halt_signal, trap_signal, stall;
    reg [5:0]  instr_format;

    reg [31:0] alu_result, pc_immed, next_instr_addr;

    reg [31:0] dmem_addr;
    reg        dmem_ren, dmem_wen;
    reg [3:0]  dmem_mask;
    reg [31:0] dmem_wdata;
    reg [31:0] dmem_rdata;
    reg [31:0] dmem_out;

    always @(posedge i_clk) begin
        instr           <=  i_instr;
        imem_raddr      <=  i_imem_raddr;
        pc              <=  i_pc;

        reg_rd_addr     <=  i_reg_rd_addr;
        reg_rs1_addr    <=  i_reg_rs1_addr;
        reg_rs2_addr    <=  i_reg_rs2_addr;
        reg_rs1_data    <=  i_reg_rs1_data;
        reg_rs2_data    <=  i_reg_rs2_data;
        immed           <=  i_immed;
        reg_wr_sel      <=  i_reg_wr_sel;
        reg_wr_en       <=  i_reg_wr_en;
        halt_signal     <=  i_halt_signal;
        trap_signal     <=  i_trap_signal;
        stall           <=  i_stall;
        instr_format    <=  i_instr_format;

        alu_result      <=  i_alu_result;
        pc_immed        <=  i_pc_immed;
        next_instr_addr <=  i_next_instr_addr;

        dmem_addr       <=  i_dmem_addr;
        dmem_ren        <=  i_dmem_ren;
        dmem_wen        <=  i_dmem_wen;
        dmem_mask       <=  i_dmem_mask;
        dmem_wdata      <=  i_dmem_wdata;
        dmem_rdata      <=  i_dmem_rdata;
        dmem_out        <=  i_dmem_out;
    end

    // Outputs
    assign o_instr              = instr;
    assign o_imem_raddr         = imem_raddr;
    assign o_pc                 = pc;

    assign o_reg_rd_addr        = reg_rd_addr;
    assign o_reg_rs1_addr       = reg_rs1_addr;
    assign o_reg_rs2_addr       = reg_rs2_addr;
    assign o_reg_rs1_data       = reg_rs1_data;
    assign o_reg_rs2_data       = reg_rs2_data;
    assign o_immed              = immed;
    assign o_reg_wr_sel         = reg_wr_sel;
    assign o_reg_wr_en          = reg_wr_en;
    assign o_halt_signal        = halt_signal;
    assign o_trap_signal        = trap_signal;
    assign o_stall              = stall;
    assign o_instr_format       = instr_format;
    
    assign o_alu_result         = alu_result;
    assign o_pc_immed           = pc_immed;
    assign o_next_instr_addr    = next_instr_addr;

    assign o_dmem_addr          = dmem_addr;
    assign o_dmem_ren           = dmem_ren;
    assign o_dmem_wen           = dmem_wen;
    assign o_dmem_mask          = dmem_mask;
    assign o_dmem_wdata         = dmem_wdata;
    assign o_dmem_rdata         = dmem_rdata;
    assign o_dmem_out           = dmem_out;
endmodule

`default_nettype wire
