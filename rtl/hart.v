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
    // Setup Program Counter
    wire [31:0] next_ins_addr;
    wire [31:0] current_ins_addr;
    pc programCounter(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_next(next_ins_addr),
        .o_current(current_ins_addr)
    );

    // Get Instruction from I-Memery
    assign o_imem_raddr = current_ins_addr;
    wire [31:0] instruction;
    assign instruction = i_imem_rdata;

    // Increment PC by 4
    wire [31:0] incremented_pc;
    add_pg_32 pcAdder(
        .val1(current_ins_addr),
        .val2(32'b0000_0000_0000_0000_0000_0000_0000_0100),
        .carry_in(1'b0),
        .val_out(incremented_pc),
        .carry_out(),
        .prop_out(),
        .gen_out()
    );



    // Setup Control Unit
    wire reg_wen;
    wire [5:0] inst_type;
    wire [2:0] reg_write_mux_selector;
    wire alu_op2_control;
    wire [2:0] alu_opsel;
    wire alu_sub;
    wire alu_arith;
    wire alu_unsigned;
    wire halt;
    control_unit controlUnit(
        .opcode(i_imem_rdata[6:0]), 
        .funct3(i_imem_rdata[14:12]), 
        .funct7(i_imem_rdata[31:25]),
        .alu_mux(alu_op2_control),
        .reg_write_mux(reg_write_mux_selector),
        .reg_write_enable(reg_wen),
        .dmem_write_enable(o_dmem_wen),
        .dmem_read_enable(o_dmem_ren),
        .o_format(inst_type),
        .o_opsel(alu_opsel),
        .o_sub(alu_sub),
        .o_arith(alu_arith),
        .o_unsigned(alu_unsigned),
        .o_halt(halt)
    );

    // Setup up register file connections
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rwr_data;
    rf registerFile(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rs1_raddr(instruction[19:15]),
        .o_rs1_rdata(rs1_data),
        .i_rs2_raddr(instruction[24:20]),
        .o_rs2_rdata(rs2_data),
        .i_rd_wen(reg_wen),
        .i_rd_waddr(instruction[11:7]),
        .i_rd_wdata(rwr_data)
    );
    
    // Setup Immediate Generator
    wire [31:0] immed;
    imm immediateGenerator(
        .i_inst(instruction),
        .i_format(inst_type),
        .o_immediate(immed)
    );




    // Setp ALU
    wire [31:0] alu_op1;
    wire [31:0] alu_op2;
    assign alu_op1 = rs1_data;
    assign alu_op2 = (alu_op2_control) ? immed : rs2_data;
    wire [31:0] alu_result;
    wire alu_equal;
    wire alu_slt;
    alu ALU(
        .i_opsel(alu_opsel),
        .i_sub(alu_sub),
        .i_unsigned(alu_unsigned),
        .i_arith(alu_arith),
        .i_op1(alu_op1),
        .i_op2(alu_op2),
        .o_result(alu_result),
        .o_eq(alu_equal),
        .o_slt(alu_slt)
    );

    wire [31:0] pc_plus_immed;
    add_pg_32 pc_immediate_adder(
        .val1(current_ins_addr),
        .val2(immed),
        .carry_in(1'b0),
        .val_out(incremented_pc),
        .carry_out(),
        .prop_out(),
        .gen_out()
    );



    // Setup up Data Memory
    wire [4:0] shift_amt;
    assign shift_amt = {rs2_data[1:0], 3'b000};
    wire [31:0] write_val;
    shifter memInputShifter(
        .val(rs2_data),
        .shamt(shift_amt),
        .shift_right(1'b1),
        .shift_arith(1'b0),
        .shifted_val(write_val)
    );

    assign o_dmem_addr = {rs2_data[31:2], 2'b00};
    assign o_dmem_wdata = write_val;

    mem_control memoryMaskGenerator(
        .funct3(i_imem_rdata[14:12]),
        .pos(rs2_data[1:0]),
        .dmem_mask(o_dmem_mask)
    );

    wire zero_extend;
    assign zero_extend = !i_imem_rdata[14];
    wire [31:0] dmem_shifted;
    shifter memoryOutputShifter(
        .val(i_dmem_rdata),
        .shamt(shift_amt),
        .shift_right(1'b1),
        .shift_arith(zero_extend),
        .shifted_val(dmem_shifted)
    );

    wire [31:0] reg_write_select_1a;
    wire [31:0] reg_write_select_1b;
    wire [31:0] reg_write_select_2;
    assign reg_write_select_1a = reg_write_mux_selector[1] ? immed : alu_result;
    assign reg_write_select_1b = reg_write_mux_selector[1] ? pc_plus_immed : dmem_shifted;
    assign reg_write_select_2 = reg_write_mux_selector[0] ? reg_write_select_1a: reg_write_select_1b;
    assign rwr_data = reg_write_mux_selector[2] ? incremented_pc : reg_write_select_2;



    // Test Bench output signals
    assign o_retire_valid     = 1'b1;
    assign o_retire_inst      = instruction;
    assign o_retire_trap      = 1'b0;      
    assign o_retire_halt      = halt;

    assign o_retire_rs1_raddr = instruction[19:15];
    assign o_retire_rs2_raddr = instruction[24:20];
    assign o_retire_rs1_rdata = rs1_data;
    assign o_retire_rs2_rdata = rs2_data;

    assign o_retire_rd_waddr  = instruction[11:7];
    assign o_retire_rd_wdata  = rwr_data;

    assign o_retire_pc        = current_ins_addr;
    assign o_retire_next_pc   = next_ins_addr;

endmodule

`default_nettype wire