`default_nettype none

module instrFetch(
    input wire          i_clk,
    input wire          i_rst,

    // Pass through connects module to the provided instruction memory
    output wire [31:0]  o_imem_raddr,
    input  wire [31:0]  i_imem_rdata,
    
    input wire [31:0]   i_next_instr_addr,
    input wire [31:0]   i_jump_instr_addr,
    input wire          i_jump_sel,

    output wire [31:0]  o_instr,
    output wire [31:0]  o_instr_addr,
    output wire [31:0]  o_incr_instr_addr
);  
    // Deside what the next Instruction will be
    wire [31:0] next_instr =    i_jump_sel ? i_jump_instr_addr : i_next_instr_addr;
    
    // Get the current instruction from the pc and write the new instruction
    wire [31:0] instr_addr;
    pc programCounter(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_next(next_instr),
        .o_current(instr_addr)
    );

    // Increment Instruction address
    add_pg_32 pc_incr(
        .val1(instr_addr),
        .val2(32'h00000004),
        .carry_in(1'b0),
        .val_out(o_incr_instr_addr),
        .carry_out(),
        .prop_out(),
        .gen_out()
    );

    // Decode instruction from the Instruction Memory
    assign o_imem_raddr = instr_addr;
    assign o_instr = i_imem_rdata;
    assign o_instr_addr = instr_addr;

endmodule
`default_nettype wire