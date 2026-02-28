`default_nettype none

module memCntr(
    input wire [2:0]  i_funct3,
    input wire [1:0]  i_pos,

    output wire [3:0]  o_dmem_mask
);
    // Generate memory Mask
    assign o_dmem_mask[0] = !i_pos[1] & !i_pos[0];
    assign o_dmem_mask[1] = (!i_pos[1] & !i_pos[0]) | ((i_funct3[1] ^ i_funct3[0]) & !i_pos[0]);
    assign o_dmem_mask[2] = (i_pos[1] & !i_pos[0]) | i_funct3[1];
    assign o_dmem_mask[3] = i_funct3[1] | ((i_funct3[1] ^ i_funct3[0]) & (i_pos[1] ^ i_pos[0])) | (i_pos[1] & i_pos[0]);
endmodule

`default_nettype wire