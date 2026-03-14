`default_nettype none

module hart #(
    // After reset, the program counter (PC) should be initialized to this
    // address and start executing instructions from there.
    parameter RESET_ADDR = 32'h00000000
) (
    input  wire        i_clk,
    input  wire        i_rst,

    output wire [31:0] o_imem_raddr,
    input  wire [31:0] i_imem_rdata,

    output wire [31:0] o_dmem_addr,
    output wire        o_dmem_ren,
    output wire        o_dmem_wen,
    output wire [31:0] o_dmem_wdata,
    output wire [ 3:0] o_dmem_mask,
    input  wire [31:0] i_dmem_rdata,

    output wire        o_retire_valid,
    output wire [31:0] o_retire_inst,
    output wire        o_retire_trap,
    output wire        o_retire_halt,
    output wire [ 4:0] o_retire_rs1_raddr,
    output wire [ 4:0] o_retire_rs2_raddr,
    output wire [31:0] o_retire_rs1_rdata,
    output wire [31:0] o_retire_rs2_rdata,
    output wire [ 4:0] o_retire_rd_waddr,
    output wire [31:0] o_retire_rd_wdata,
    output wire [31:0] o_retire_dmem_addr,
    output wire        o_retire_dmem_ren,
    output wire        o_retire_dmem_wen,
    output wire [3:0]  o_retire_dmem_mask,
    output wire [31:0] o_retire_dmem_wdata,
    output wire [31:0] o_retire_dmem_rdata,
    output wire [31:0] o_retire_pc,
    output wire [31:0] o_retire_next_pc

`ifdef RISCV_FORMAL
    ,`RVFI_OUTPUTS,
`endif
);
    // Instruction Fetch Phase
    wire [31:0] if_instr;
    wire [31:0] if_pc;
    wire [31:0] if_pc_plus_4;
    wire        id_stall;
    wire [31:0] exe_jump_instr_addr;
    wire        exe_pc_sel;
    instrFetch instructionFetch(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(id_stall),

        .o_imem_raddr(o_imem_raddr),
        .i_imem_rdata(i_imem_rdata),

        .i_next_instr_addr(if_pc_plus_4),
        .i_jump_instr_addr(exe_jump_instr_addr),
        .i_jump_sel(exe_pc_sel),

        .o_instr(if_instr),
        .o_instr_addr(if_pc),
        .o_incr_instr_addr(if_pc_plus_4)
    );
    
    // IF/ID Pipeline Register
    wire [31:0] id_instr;
    wire [31:0] id_imem_raddr;
    wire [31:0] id_pc;
    wire [31:0] id_pc_plus_4;      // The Address of the subsequent instruction
    if_id_reg if_id_register(
        .i_clk(i_clk),
        .i_rst(i_rst),
        
        .i_instr(if_instr),
        .i_imem_raddr(o_imem_raddr),
        .i_pc(if_pc),
        .i_pc_plus_4(if_pc_plus_4),

        .o_instr(id_instr),
        .o_imem_raddr(id_imem_raddr),
        .o_pc(id_pc),
        .o_pc_plus_4(id_pc_plus_4)
    );

    // Instruction Decode Phase
    wire [4:0]  id_reg_rd_addr,  id_reg_rs1_addr, id_reg_rs2_addr;  // Addresses
    wire [31:0] id_reg_rs1_data, id_reg_rs2_data, id_immed;         // Values
    wire [2:0]  id_alu_op_sel;                  // ALU Control Signals                                
    wire        id_alu_input_sel, id_alu_sub_sel, id_alu_sign_sel, id_alu_arith_sel;
    wire        id_jump_addr_sel, id_jump_sel, id_branch_sel;  // Jump Control Signal
    wire        id_dmem_wr_en, id_dmem_rd_en;   // Dmem Control Signals
    wire [2:0]  id_reg_wr_sel;                  // Write Back Control Signal
    wire        id_reg_wr_en;
    wire        exe_reg_wr_en;
    wire [4:0]  exe_reg_rd_addr;
    wire        mem_reg_wr_en;
    wire [4:0]  mem_reg_rd_addr;
    wire        wr_reg_wr_en;
    wire        id_halt_signal, id_trap_signal; // Instruction Control Signals
    wire [2:0]  id_funct3;                      // Function Codes and Format
    wire [6:0]  id_funct7;
    wire [5:0]  id_instr_format;
    wire [31:0] wr_reg_wr_data;
    instrDecode instructionDecode(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_instr(id_instr),
        .i_reg_wr_data(wr_reg_wr_data),
        .i_reg_wr_en(wr_reg_wr_en),

        .i_exe_wr_en(exe_reg_wr_en),
        .i_exe_wr_addr(exe_reg_rd_addr),
        .i_mem_wr_en(mem_reg_wr_en),
        .i_mem_wr_addr(mem_reg_rd_addr),

        .o_reg_addr_wr(id_reg_rd_addr),
        .o_reg_addr_1(id_reg_rs1_addr),
        .o_reg_addr_2(id_reg_rs2_addr),
        .o_reg_data_1(id_reg_rs1_data),
        .o_reg_data_2(id_reg_rs2_data),
        .o_immed(id_immed),

        .o_alu_input_sel(id_alu_input_sel),
        .o_alu_op_sel(id_alu_op_sel),
        .o_alu_sub_sel(id_alu_sub_sel),
        .o_alu_sign_sel(id_alu_sign_sel),
        .o_alu_arith_sel(id_alu_arith_sel),

        .o_jump_addr_sel(id_jump_addr_sel),
        .o_jump_sel(id_jump_sel),
        .o_branch_sel(id_branch_sel),

        .o_dmem_wr_en(id_dmem_wr_en),
        .o_dmem_rd_en(id_dmem_rd_en),

        .o_reg_wr_sel(id_reg_wr_sel),
        .o_reg_wr_en(id_reg_wr_en),
        .o_halt(id_halt_signal),
        .o_trap(id_trap_signal),
        .o_stall(id_stall),

        .o_funct3(id_funct3),
        .o_funct7(id_funct7),

        .o_format(id_instr_format)
    );

    // ID/EXE Pipeline Register
    // IF Stage Items
    wire [31:0] exe_instr, exe_imem_raddr, exe_pc, exe_pc_plus_4;

    // ID Stage Items
    wire [4:0]    exe_reg_rs1_addr, exe_reg_rs2_addr;  // Addresses
    wire [31:0] exe_reg_rs1_data, exe_reg_rs2_data, exe_immed;         // Values
    wire [2:0]  exe_alu_op_sel;                  // ALU Control Signals                                
    wire        exe_alu_input_sel, exe_alu_sub_sel, exe_alu_sign_sel, exe_alu_arith_sel;
    wire        exe_jump_sel, exe_jump_addr_sel, exe_branch_sel;  // Jump Control Signal
    wire        exe_dmem_wr_en, exe_dmem_rd_en;   // Dmem Control Signals
    wire [2:0]  exe_reg_wr_sel;                  // Write Back Control Signal
    wire        exe_halt_signal, exe_trap_signal, exe_stall; // Instruction Control Signals
    wire [2:0]  exe_funct3;                      // Function Codes and Format
    wire [6:0]  exe_funct7;
    wire [5:0]  exe_instr_format;
    wire [31:0] exe_next_instr_addr;
    id_exe_reg id_exe_register(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_instr(id_instr),
        .i_imem_raddr(id_imem_raddr),
        .i_pc(id_pc),
        .i_pc_plus_4(id_pc_plus_4),

        .i_reg_rd_addr(id_reg_rd_addr),
        .i_reg_rs1_addr(id_reg_rs1_addr),
        .i_reg_rs2_addr(id_reg_rs2_addr),
        .i_reg_rs1_data(id_reg_rs1_data),
        .i_reg_rs2_data(id_reg_rs2_data),
        .i_immed(id_immed),
        .i_alu_op_sel(id_alu_op_sel),
        .i_alu_input_sel(id_alu_input_sel),
        .i_alu_sub_sel(id_alu_sub_sel),
        .i_alu_sign_sel(id_alu_sign_sel),
        .i_alu_arith_sel(id_alu_arith_sel),
        .i_jump_addr_sel(id_jump_addr_sel),
        .i_jump_sel(id_jump_sel),
        .i_branch_sel(id_branch_sel),
        .i_dmem_wr_en(id_dmem_wr_en),
        .i_dmem_rd_en(id_dmem_rd_en),
        .i_reg_wr_sel(id_reg_wr_sel),
        .i_reg_wr_en(id_reg_wr_en),
        .i_halt_signal(id_halt_signal),
        .i_trap_signal(id_trap_signal),
        .i_stall(id_stall),
        .i_funct3(id_funct3),
        .i_funct7(id_funct7),
        .i_instr_format(id_instr_format),

        .o_instr(exe_instr),
        .o_imem_raddr(exe_imem_raddr),
        .o_pc(exe_pc), 
        .o_pc_plus_4(exe_pc_plus_4),

        .o_reg_rd_addr(exe_reg_rd_addr),
        .o_reg_rs1_addr(exe_reg_rs1_addr),
        .o_reg_rs2_addr(exe_reg_rs2_addr),
        .o_reg_rs1_data(exe_reg_rs1_data),
        .o_reg_rs2_data(exe_reg_rs2_data),
        .o_immed(exe_immed),
        .o_alu_op_sel(exe_alu_op_sel),
        .o_alu_input_sel(exe_alu_input_sel),
        .o_alu_sub_sel(exe_alu_sub_sel),
        .o_alu_sign_sel(exe_alu_sign_sel),
        .o_alu_arith_sel(exe_alu_arith_sel),
        .o_jump_addr_sel(exe_jump_addr_sel),
        .o_jump_sel(exe_jump_sel),
        .o_branch_sel(exe_branch_sel),
        .o_dmem_wr_en(exe_dmem_wr_en),
        .o_dmem_rd_en(exe_dmem_rd_en),
        .o_reg_wr_sel(exe_reg_wr_sel),
        .o_reg_wr_en(exe_reg_wr_en),
        .o_halt_signal(exe_halt_signal),
        .o_trap_signal(exe_trap_signal),
        .o_stall(exe_stall),
        .o_funct3(exe_funct3),
        .o_funct7(exe_funct7),
        .o_instr_format(exe_instr_format)
    );
    
    // Execution Phase
    wire [31:0]     exe_alu_result, exe_pc_immed;
    exe execution(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(exe_stall),

        .i_alu_input_sel(exe_alu_input_sel),
        .i_alu_op_sel(exe_alu_op_sel),
        .i_alu_sub_sel(exe_alu_sub_sel),
        .i_alu_sign_sel(exe_alu_sign_sel),
        .i_alu_arith_sel(exe_alu_arith_sel),
        
        .i_jump_addr_sel(exe_jump_addr_sel),
        .i_jump_sel(exe_jump_sel),
        .i_branch_sel(exe_branch_sel),
        .i_funct3(exe_funct3),

        .i_reg_rs1_data(exe_reg_rs1_data),
        .i_reg_rs2_data(exe_reg_rs2_data),
        .i_immed(exe_immed),
        .i_instr(exe_instr),
        .i_pc(exe_pc),
        .i_pc_plus_4(exe_pc_plus_4),

        .o_alu_result(exe_alu_result),
        .o_jump_addr(exe_jump_instr_addr),
        .o_pc_immed(exe_pc_immed),
        .o_pc_sel(exe_pc_sel),
        .o_next_instr_addr(exe_next_instr_addr)
    );

    // EXE/MEM Pipeline Register
    // IF Stage Items
    wire [31:0] mem_instr, mem_imem_raddr, mem_pc, mem_pc_plus_4;

    // ID Stage Items
    wire [4:0]  mem_reg_rs1_addr, mem_reg_rs2_addr;  // Addresses
    wire [31:0] mem_reg_rs1_data, mem_reg_rs2_data, mem_immed;         // Values
    wire [2:0]  mem_alu_op_sel;                  // ALU Control Signals                                
    wire        mem_alu_input_sel, mem_alu_sub_sel, mem_alu_sign_sel, mem_alu_arith_sel;
    wire        mem_jump_type_sel;  // Jump Control Signal
    wire        mem_dmem_wr_en, mem_dmem_rd_en;   // Dmem Control Signals
    wire [2:0]  mem_reg_wr_sel;                  // Write Back Control Signal
    wire        mem_halt_signal, mem_trap_signal, mem_stall; // Instruction Control Signals
    wire [2:0]  mem_funct3;                      // Function Codes and Format
    wire [6:0]  mem_funct7;
    wire [5:0]  mem_instr_format;

    // Execution Stage Items
    wire [31:0]     mem_alu_result, mem_pc_immed, mem_next_instr_addr;
    exe_mem_reg exe_mem_register(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_instr(exe_instr),
        .i_imem_raddr(exe_imem_raddr),
        .i_pc(exe_pc),

        .i_reg_rd_addr(exe_reg_rd_addr),
        .i_reg_rs1_addr(exe_reg_rs1_addr),
        .i_reg_rs2_addr(exe_reg_rs2_addr),
        .i_reg_rs1_data(exe_reg_rs1_data),
        .i_reg_rs2_data(exe_reg_rs2_data),
        .i_immed(exe_immed),
        .i_dmem_wr_en(exe_dmem_wr_en),
        .i_dmem_rd_en(exe_dmem_rd_en),
        .i_reg_wr_sel(exe_reg_wr_sel),
        .i_reg_wr_en(exe_reg_wr_en),
        .i_halt_signal(exe_halt_signal),
        .i_trap_signal(exe_trap_signal),
        .i_stall(exe_stall),
        .i_funct3(exe_funct3),
        .i_instr_format(exe_instr_format),

        .i_alu_result(exe_alu_result),
        .i_pc_immed(exe_pc_immed),
        .i_next_instr_addr(exe_next_instr_addr),

        .o_instr(mem_instr),
        .o_imem_raddr(mem_imem_raddr),
        .o_pc(mem_pc), 

        .o_reg_rd_addr(mem_reg_rd_addr),
        .o_reg_rs1_addr(mem_reg_rs1_addr),
        .o_reg_rs2_addr(mem_reg_rs2_addr),
        .o_reg_rs1_data(mem_reg_rs1_data),
        .o_reg_rs2_data(mem_reg_rs2_data),
        .o_immed(mem_immed),
        .o_dmem_wr_en(mem_dmem_wr_en),
        .o_dmem_rd_en(mem_dmem_rd_en),
        .o_reg_wr_sel(mem_reg_wr_sel),
        .o_reg_wr_en(mem_reg_wr_en),
        .o_halt_signal(mem_halt_signal),
        .o_trap_signal(mem_trap_signal),
        .o_stall(mem_stall),
        .o_funct3(mem_funct3),
        .o_instr_format(mem_instr_format),

        .o_alu_result(mem_alu_result),
        .o_pc_immed(mem_pc_immed),
        .o_next_instr_addr(mem_next_instr_addr)
    );


    // Memory Phase
    wire [31:0]  mem_dmem_out;
    mem memory(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_stall(mem_stall),

        .o_dmem_addr(o_dmem_addr),
        .o_dmem_ren(o_dmem_ren),
        .o_dmem_wen(o_dmem_wen),
        .o_dmem_wdata(o_dmem_wdata),
        .o_dmem_mask(o_dmem_mask),
        .i_dmem_rdata(i_dmem_rdata),

        .i_dmem_rd_en(mem_dmem_rd_en),
        .i_dmem_wr_en(mem_dmem_wr_en),
        .i_funct3(mem_funct3),

        .i_alu_result(mem_alu_result),
        .i_reg_rs2_data(mem_reg_rs2_data),

        .o_dmem_out(mem_dmem_out)
    );

    // MEM/WR Pipeline Register
    // IF Stage Items
    wire [31:0] wr_instr, wr_iwr_raddr, wr_pc;

    // ID Stage Items
    wire [4:0]  wr_reg_rd_addr,  wr_reg_rs1_addr, wr_reg_rs2_addr;  // Addresses
    wire [31:0] wr_reg_rs1_data, wr_reg_rs2_data, wr_immed;         // Values
    wire [2:0]  wr_reg_wr_sel;                  // Write Back Control Signal
    wire        wr_halt_signal, wr_trap_signal, wr_stall; // Instruction Control Signals
    wire [5:0]  wr_instr_format;

    // Execution Stage Items
    wire [31:0]     wr_alu_result, wr_pc_immed, wr_next_instr_addr;

    // Memory Stage Items
    wire [31:0] wr_dmem_addr;
    wire        wr_dmem_ren;
    wire        wr_dmem_wen;
    wire [3:0]  wr_dmem_mask;
    wire [31:0] wr_dmem_wdata;
    wire [31:0] wr_dmem_rdata;
    wire [31:0] wr_dmem_out;
    mem_wr_reg mem_wr_register(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_instr(mem_instr),
        .i_imem_raddr(mem_imem_raddr),
        .i_pc(mem_pc),

        .i_reg_rd_addr(mem_reg_rd_addr),
        .i_reg_rs1_addr(mem_reg_rs1_addr),
        .i_reg_rs2_addr(mem_reg_rs2_addr),
        .i_reg_rs1_data(mem_reg_rs1_data),
        .i_reg_rs2_data(mem_reg_rs2_data),
        .i_immed(mem_immed),
        .i_reg_wr_sel(mem_reg_wr_sel),
        .i_reg_wr_en(mem_reg_wr_en),
        .i_halt_signal(mem_halt_signal),
        .i_trap_signal(mem_trap_signal),
        .i_stall(mem_stall),
        .i_instr_format(mem_instr_format),

        .i_alu_result(mem_alu_result),
        .i_pc_immed(mem_pc_immed),
        .i_next_instr_addr(mem_next_instr_addr),

        .i_dmem_addr(o_dmem_addr),
        .i_dmem_ren(o_dmem_ren),
        .i_dmem_wen(o_dmem_wen),
        .i_dmem_mask(o_dmem_mask),
        .i_dmem_wdata(o_dmem_wdata),
        .i_dmem_rdata(i_dmem_rdata),
        .i_dmem_out(mem_dmem_out),

        .o_instr(wr_instr),
        .o_imem_raddr(wr_pc),
        .o_pc(wr_pc), 

        .o_reg_rd_addr(wr_reg_rd_addr),
        .o_reg_rs1_addr(wr_reg_rs1_addr),
        .o_reg_rs2_addr(wr_reg_rs2_addr),
        .o_reg_rs1_data(wr_reg_rs1_data),
        .o_reg_rs2_data(wr_reg_rs2_data),
        .o_immed(wr_immed),
        .o_reg_wr_sel(wr_reg_wr_sel),
        .o_reg_wr_en(wr_reg_wr_en),
        .o_halt_signal(wr_halt_signal),
        .o_trap_signal(wr_trap_signal),
        .o_stall(wr_stall),
        .o_instr_format(wr_instr_format),

        .o_alu_result(wr_alu_result),
        .o_pc_immed(wr_pc_immed),
        .o_next_instr_addr(wr_next_instr_addr),

        .o_dmem_addr(wr_dmem_addr),
        .o_dmem_ren(wr_dmem_ren),
        .o_dmem_wen(wr_dmem_wen),
        .o_dmem_mask(wr_dmem_mask),
        .o_dmem_wdata(wr_dmem_wdata),
        .o_dmem_rdata(wr_dmem_rdata),

        .o_dmem_out(wr_dmem_out)
    );
    

    // Write Back Phase
    wrBack writeBack(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_reg_wr_sel(wr_reg_wr_sel),

        .i_alu_result(wr_alu_result),
        .i_shifted_mem_data(wr_dmem_out),
        .i_pc_immed(wr_pc_immed),
        .i_immed(wr_immed),
        .i_next_pc_addr(wr_next_instr_addr),

        .o_wr_back_data(wr_reg_wr_data)
    );

    // Set all Retire signals at the end of the cycle.
    wire rd_wr;
    assign rd_wr = wr_instr_format[0] | wr_instr_format[1] | wr_instr_format[4] | wr_instr_format[5];
    
    assign o_retire_valid       = !wr_stall             ? 1'b1                  : 1'b0;
    assign o_retire_inst        = !wr_stall             ? wr_instr              : 32'h0000_0000;
    assign o_retire_trap        = !wr_stall             ? wr_trap_signal        : 1'b0;
    assign o_retire_halt        = !wr_stall             ? wr_halt_signal        : 1'b0;
    assign o_retire_pc          = !wr_stall             ? wr_pc                 : 32'h0000_0000;
    assign o_retire_next_pc     = !wr_stall             ? wr_next_instr_addr    : 32'h0000_0000;
    assign o_retire_rd_waddr    = (!wr_stall & rd_wr)   ? wr_reg_rd_addr        : 5'b00000;        
    assign o_retire_rd_wdata    = (!wr_stall & rd_wr)   ? wr_reg_wr_data        : 32'h0000_0000;
    assign o_retire_rs1_raddr   = !wr_stall             ? wr_reg_rs1_addr       : 5'b00000;
    assign o_retire_rs2_raddr   = !wr_stall             ? wr_reg_rs2_addr       : 5'b00000;
    assign o_retire_rs1_rdata   = !wr_stall             ? wr_reg_rs1_data       : 32'h0000_0000;
    assign o_retire_rs2_rdata   = !wr_stall             ? wr_reg_rs2_data       : 32'h0000_0000;

    assign o_retire_dmem_addr   = !wr_stall             ? wr_dmem_addr          : 32'h0000_0000;
    assign o_retire_dmem_ren    = !wr_stall             ? wr_dmem_ren           : 1'b0;
    assign o_retire_dmem_wen    = !wr_stall             ? wr_dmem_wen           : 1'b0;
    assign o_retire_dmem_mask   = !wr_stall             ? wr_dmem_mask          : 2'b00;
    assign o_retire_dmem_wdata  = !wr_stall             ? wr_dmem_wdata         : 32'h0000_0000;
    assign o_retire_dmem_rdata  = !wr_stall             ? wr_dmem_rdata         : 32'h0000_0000;


endmodule

`default_nettype wire