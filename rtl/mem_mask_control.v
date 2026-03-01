`default_nettype none

module memCntr(
    input wire [2:0]    i_funct3,
    input wire [1:0]    i_pos,
    input wire          is_store,

    output wire [3:0]  o_dmem_mask
);
    wire is_byte;
    wire is_half;
    wire is_word;
    assign is_byte = !i_funct3[0] & !i_funct3[1];
    assign is_half = i_funct3[0];
    assign is_word = i_funct3[1];
    // Generate memory Mask
    assign o_dmem_mask[0] = is_word | (is_half & (i_pos == 2'b00)) | (is_byte & (i_pos == 2'b00));
    assign o_dmem_mask[1] = is_word | (is_half & (i_pos == 2'b00)) | (is_byte & (i_pos == 2'b01));
    assign o_dmem_mask[2] = is_word | (is_half & (i_pos == 2'b10)) | (is_byte & (i_pos == 2'b10));
    assign o_dmem_mask[3] = is_word | (is_half & (i_pos == 2'b10)) | (is_byte & (i_pos == 2'b11));
endmodule

`default_nettype wire