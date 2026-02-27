`default_nettype none

module mem_control(
    input wire [2:0]  funct3,
    input wire [1:0]  pos,
    output wire [3:0]  dmem_mask
);
    // Generate memory Mask
    assign dmem_mask[0] = !pos[1] & !pos[0];
    assign dmem_mask[1] = (!pos[1] & !pos[0]) | ((funct3[1] ^ funct3[0]) & !pos[0]);
    assign dmem_mask[2] = (pos[1] & !pos[0]) | funct3[1];
    assign dmem_mask[3] = funct3[1] | ((funct3[1] ^ funct3[0]) & (pos[1] ^ pos[0])) | (pos[1] & pos[0]);
endmodule

`default_nettype wire