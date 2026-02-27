`default_nettype none

module b_cntr(
    input wire          i_jump,
    input wire [2:0]    i_funct3,

    input wire          i_eq,
    input wire          i_slt,

    output wire         o_jump_cntr
);
    wire branchTaken;
    assign branchTaken =    (funct3 == 3'b000) ? i_eq :
                            (funct3 == 3'b001) ? !i_eq :
                            (funct3 == 3'b100) ? i_slt :
                            (funct3 == 3'b101) ? !i_slt | i_eq :
                            (funct3 == 3'b110) ? i_slt :
                            (funct3 == 3'b111) ? !i_slt : 1'b0;

    assign jump_cntr = jump ? 1'b1 : branchTaken;

endmodule

`default_nettype wire