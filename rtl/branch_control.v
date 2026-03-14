`default_nettype none

module b_cntr(
    input wire          i_jump,
    input wire          i_branch,
    input wire [2:0]    i_funct3,
    input wire [31:0]   i_pc_plus_4,
    input wire [31:0]   i_jump_addr,

    input wire          i_eq,
    input wire          i_slt,

    output wire         o_pc_sel,
    output wire [31:0]  o_next_instr_addr
);
    wire branchTaken;
    assign branchTaken =    !i_branch            ? 1'b0 :
                            (i_funct3 == 3'b000) ? i_eq :
                            (i_funct3 == 3'b001) ? !i_eq :
                            (i_funct3 == 3'b100) ? i_slt :
                            (i_funct3 == 3'b101) ? !i_slt | i_eq :
                            (i_funct3 == 3'b110) ? i_slt :
                            (i_funct3 == 3'b111) ? !i_slt : 1'b0;

    assign o_pc_sel             = (i_jump | branchTaken) ? 1'b1 : 1'b0;
    assign o_next_instr_addr    = o_pc_sel ? i_jump_addr : i_pc_plus_4;

endmodule

`default_nettype wire