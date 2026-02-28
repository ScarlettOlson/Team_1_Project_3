`default_nettype none

module hart #(
    // After reset, the program counter (PC) should be initialized to this
    // address and start executing instructions from there.
    parameter RESET_ADDR = 32'h00000000
) (
    // Global clock.
    input  wire        i_clk,
    // Synchronous active-high reset.
    input  wire        i_rst,
    // Instruction fetch goes through a read only instruction memory (imem)
    // port. The port accepts a 32-bit address (e.g. from the program counter)
    // per cycle and combinationally returns a 32-bit instruction word. This
    // is not representative of a realistic memory interface; it has been
    // modeled as more similar to a DFF or SRAM to simplify phase 3. In
    // later phases, you will replace this with a more realistic memory.
    //
    // 32-bit read address for the instruction memory. This is expected to be
    // 4 byte aligned - that is, the two LSBs should be zero.
    output wire [31:0] o_imem_raddr,
    // Instruction word fetched from memory, available on the same cycle.
    input  wire [31:0] i_imem_rdata,
    // Data memory accesses go through a separate read/write data memory (dmem)
    // that is shared between read (load) and write (stored). The port accepts
    // a 32-bit address, read or write enable, and mask (explained below) each
    // cycle. Reads are combinational - values are available immediately after
    // updating the address and asserting read enable. Writes occur on (and
    // are visible at) the next clock edge.
    //
    // Read/write address for the data memory. This should be 32-bit aligned
    // (i.e. the two LSB should be zero). See `o_dmem_mask` for how to perform
    // half-word and byte accesses at unaligned addresses.
    output wire [31:0] o_dmem_addr,
    // When asserted, the memory will perform a read at the aligned address
    // specified by `i_addr` and return the 32-bit word at that address
    // immediately (i.e. combinationally). It is illegal to assert this and
    // `o_dmem_wen` on the same cycle.
    output wire        o_dmem_ren,
    // When asserted, the memory will perform a write to the aligned address
    // `o_dmem_addr`. When asserted, the memory will write the bytes in
    // `o_dmem_wdata` (specified by the mask) to memory at the specified
    // address on the next rising clock edge. It is illegal to assert this and
    // `o_dmem_ren` on the same cycle.
    output wire        o_dmem_wen,
    // The 32-bit word to write to memory when `o_dmem_wen` is asserted. When
    // write enable is asserted, the byte lanes specified by the mask will be
    // written to the memory word at the aligned address at the next rising
    // clock edge. The other byte lanes of the word will be unaffected.
    output wire [31:0] o_dmem_wdata,
    // The dmem interface expects word (32 bit) aligned addresses. However,
    // WISC-25 supports byte and half-word loads and stores at unaligned and
    // 16-bit aligned addresses, respectively. To support this, the access
    // mask specifies which bytes within the 32-bit word are actually read
    // from or written to memory.
    //
    // To perform a half-word read at address 0x00001002, align `o_dmem_addr`
    // to 0x00001000, assert `o_dmem_ren`, and set the mask to 0b1100 to
    // indicate that only the upper two bytes should be read. Only the upper
    // two bytes of `i_dmem_rdata` can be assumed to have valid data; to
    // calculate the final value of the `lh[u]` instruction, shift the rdata
    // word right by 16 bits and sign/zero extend as appropriate.
    //
    // To perform a byte write at address 0x00002003, align `o_dmem_addr` to
    // `0x00002000`, assert `o_dmem_wen`, and set the mask to 0b1000 to
    // indicate that only the upper byte should be written. On the next clock
    // cycle, the upper byte of `o_dmem_wdata` will be written to memory, with
    // the other three bytes of the aligned word unaffected. Remember to shift
    // the value of the `sb` instruction left by 24 bits to place it in the
    // appropriate byte lane.
    output wire [ 3:0] o_dmem_mask,
    // The 32-bit word read from data memory. When `o_dmem_ren` is asserted,
    // this will immediately reflect the contents of memory at the specified
    // address, for the bytes enabled by the mask. When read enable is not
    // asserted, or for bytes not set in the mask, the value is undefined.
    input  wire [31:0] i_dmem_rdata,
	// The output `retire` interface is used to signal to the testbench that
    // the CPU has completed and retired an instruction. A single cycle
    // implementation will assert this every cycle; however, a pipelined
    // implementation that needs to stall (due to internal hazards or waiting
    // on memory accesses) will not assert the signal on cycles where the
    // instruction in the writeback stage is not retiring.
    //
    // Asserted when an instruction is being retired this cycle. If this is
    // not asserted, the other retire signals are ignored and may be left invalid.
    output wire        o_retire_valid,
    // The 32 bit instruction word of the instrution being retired. This
    // should be the unmodified instruction word fetched from instruction
    // memory.
    output wire [31:0] o_retire_inst,
    // Asserted if the instruction produced a trap, due to an illegal
    // instruction, unaligned data memory access, or unaligned instruction
    // address on a taken branch or jump.
    output wire        o_retire_trap,
    // Asserted if the instruction is an `ebreak` instruction used to halt the
    // processor. This is used for debugging and testing purposes to end
    // a program.
    output wire        o_retire_halt,
    // The first register address read by the instruction being retired. If
    // the instruction does not read from a register (like `lui`), this
    // should be 5'd0.
    output wire [ 4:0] o_retire_rs1_raddr,
    // The second register address read by the instruction being retired. If
    // the instruction does not read from a second register (like `addi`), this
    // should be 5'd0.
    output wire [ 4:0] o_retire_rs2_raddr,
    // The first source register data read from the register file (in the
    // decode stage) for the instruction being retired. If rs1 is 5'd0, this
    // should also be 32'd0.
    output wire [31:0] o_retire_rs1_rdata,
    // The second source register data read from the register file (in the
    // decode stage) for the instruction being retired. If rs2 is 5'd0, this
    // should also be 32'd0.
    output wire [31:0] o_retire_rs2_rdata,
    // The destination register address written by the instruction being
    // retired. If the instruction does not write to a register (like `sw`),
    // this should be 5'd0.
    output wire [ 4:0] o_retire_rd_waddr,
    // The destination register data written to the register file in the
    // writeback stage by this instruction. If rd is 5'd0, this field is
    // ignored and can be treated as a don't care.
    output wire [31:0] o_retire_rd_wdata,
    // The current program counter of the instruction being retired - i.e.
    // the instruction memory address that the instruction was fetched from.
    output wire [31:0] o_retire_pc,
    // the next program counter after the instruction is retired. For most
    // instructions, this is `o_retire_pc + 4`, but must be the branch or jump
    // target for *taken* branches and jumps.
    output wire [31:0] o_retire_next_pc

`ifdef RISCV_FORMAL
    ,`RVFI_OUTPUTS,
`endif
);
    wire [31:0] next_instr_addr;// The Address of the subsequent instruction
    wire [31:0] jump_instr_addr;// The Instruction to jump to if branch is taken 
    wire        jump_sel;       // Both Jump pieces are determined during the exe phase
    // Instruction Fetch Phase
    wire [31:0] instr;
    instrFetch instructionFetch(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .o_imem_raddr(o_imem_raddr),
        .i_imem_rdata(i_imem_rdata),

        .i_next_instr_addr(next_instr_addr),
        .i_jump_instr_addr(jump_instr_addr),
        .i_jump_sel(jump_sel),

        .o_instr(instr),
        .o_incr_instr_addr(next_instr_addr)
    );
    
    // Instruction Decode Phase
    wire [31:0] reg_wr_data;        // This Value is selected later, in the Write Back Phase

    wire [4:0]  reg_rd_addr;
    wire [4:0]  reg_rs1_addr;
    wire [4:0]  reg_rs2_addr;
    wire [31:0] reg_rs1_data;
    wire [31:0] reg_rs2_data;
    wire [31:0] immed;

    wire        alu_input_sel;
    wire [2:0]  alu_op_sel;
    wire        alu_sub_sel;
    wire        alu_sign_sel;
    wire        alu_arith_sel;

    wire        jump_type_sel;
    //wire      jump_sel    Declared earlier
    
    wire        dmem_wr_en;
    wire        dmem_rd_en;

    wire [2:0]  reg_wr_sel;
    wire        halt_signal;

    wire [2:0]  funct3;
    wire [6:0]  funct7;

    wire [5:0]  instr_format;
    instrDecode instructionDecode(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_instr(instr),
        .i_reg_wr_data(reg_wr_data),

        .o_reg_addr_wr(reg_rd_addr),
        .o_reg_addr_1(reg_rs1_addr),
        .o_reg_addr_2(reg_rs2_addr),
        .o_reg_data_1(reg_rs1_data),
        .o_reg_data_2(reg_rs2_data),
        .o_immed(immed),

        .o_alu_input_sel(alu_input_sel),
        .o_alu_op_sel(alu_op_sel),
        .o_alu_sub_sel(alu_sub_sel),
        .o_alu_sign_sel(alu_sign_sel),
        .o_alu_arith_sel(alu_arith_sel),

        .o_jump_type_sel(jump_type_sel),
        .o_jump_sel(jump_sel),

        .o_dmem_wr_en(dmem_wr_en),
        .o_dmem_rd_en(dmem_rd_en),

        .o_reg_wr_sel(reg_wr_sel),
        .o_halt(halt_signal),

        .o_funct3(funct3),
        .o_funct7(funct7),

        .o_format(instr_format)
    );
    
    // Execution Phase
    wire [31:0]     alu_result;
    wire [31:0]     pc_immed;
    wire            branch_sel;
    exe execution(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_alu_input_sel(alu_input_sel),
        .i_alu_op_sel(alu_op_sel),
        .i_alu_sub_sel(alu_sub_sel),
        .i_alu_sign_sel(alu_sign_sel),
        .i_alu_arith_sel(alu_arith_sel),
        
        .i_jump_type_sel(jump_type_sel),
        .i_jump_sel(jump_sel),
        .i_funct3(funct3),

        .i_reg_rs1_data(reg_rs1_data),
        .i_reg_rs2_data(reg_rs2_data),
        .i_immed(immed),
        .i_instr(instr),

        .o_alu_result(alu_result),
        .o_jump_addr(jump_instr_addr),
        .o_pc_immed(pc_immed),
        .o_branch_sel(branch_sel)
    );



    // Memory Phase
    wire [31:0]  shifted_mem_data;
    
    mem memory(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .o_dmem_addr(o_dmem_addr),
        .o_dmem_ren(o_dmem_ren),
        .o_dmem_wen(o_dmem_wen),
        .o_dmem_wdata(o_dmem_wdata),
        .o_dmem_mask(o_dmem_mask),
        .i_dmem_rdata(i_dmem_rdata),

        .i_dmem_rd_en(dmem_rd_en),
        .i_dmem_wr_en(dmem_wr_en),
        .i_funct3(funct3),

        .i_alu_result(alu_result),
        .i_reg_rs2_data(reg_rs2_data),

        .o_dmem_shifted_data(shifted_mem_data)
    );

    // Write Back Phase
    wrBack writeBack(
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_reg_wr_sel(reg_wr_sel),

        .i_alu_result(alu_result),
        .i_shifted_mem_data(shifted_mem_data),
        .i_pc_immed(pc_immed),
        .i_immed(immed),
        .i_next_pc_addr(next_instr_addr),

        .o_wr_back_data(reg_wr_data)
    );

    // Set all Retire signals at the end of the cycle.
    assign o_retire_valid = halt_signal ? 1'b0 : 1'b1;
    assign o_retire_inst = instr;
    //assign o_retire_trap = ;
    assign o_retire_halt = halt_signal;
    assign o_retire_rs1_raddr = (instr_format[0] | instr_format[1] | instr_format[2] | instr_format[3]) ? reg_rs1_addr : 5'b00000;
    assign o_retire_rs2_raddr = (instr_format[0] | instr_format[2] | instr_format[3]) ? reg_rs2_addr : 5'b00000;
    assign o_retire_rs1_rdata = (instr_format[0] | instr_format[1] | instr_format[2] | instr_format[3]) ? reg_rs1_data : 32'h00000000;
    assign o_retire_rs2_rdata = (instr_format[0] | instr_format[2] | instr_format[3]) ? reg_rs2_data : 32'h00000000;
    assign o_retire_rd_waddr = (instr_format[0] | instr_format[1] | instr_format[4] | instr_format[5]) ? reg_rd_addr : 5'b00000;
    assign o_retire_rd_wdata = (instr_format[0] | instr_format[1] | instr_format[4] | instr_format[5]) ? reg_wr_data : 32'h00000000;
    //assign o_retire_pc = ;
    //assign o_retire_next_pc = ;


endmodule

`default_nettype wire