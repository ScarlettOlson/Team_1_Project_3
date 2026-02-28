`default_nettype none

module shifter (
    input wire [31:0] val,
    input wire [4:0] shamt,
    input wire shift_right,   // If this is set then a right shift occurs, otherwise a left shift occurs
    input wire shift_arith,   // If this is set then an arithmmetic shift occurs, otherwise a logical shift occurs

    output wire [31:0] shifted_val
);
    // Shift Left, arithmetic and logical are the same
    wire [31:0] shift_l1;
    wire [31:0] shift_l2;
    wire [31:0] shift_l3;
    wire [31:0] shift_l4;
    wire [31:0] shift_l5;

    // Shift Right Logical
    wire [31:0] shift_rl1;
    wire [31:0] shift_rl2;
    wire [31:0] shift_rl3;
    wire [31:0] shift_rl4;
    wire [31:0] shift_rl5;

    // Shift Right Arithmetic
    wire [31:0] shift_ra1;
    wire [31:0] shift_ra2;
    wire [31:0] shift_ra3;
    wire [31:0] shift_ra4;
    wire [31:0] shift_ra5;

    // Final shift right value
    wire [31:0] shift_rf;


    // Perform Left Shifts
    assign shift_l1 = (shamt[0]) ? {val[30:0], 1'b0} : val; // Mux Selects between a single bit shift and the whole value
    assign shift_l2 = (shamt[1]) ? {shift_l1[29:0], 2'b00} : shift_l1; // The next 4 muxes select between the last value and the last value shifted
    assign shift_l3 = (shamt[2]) ? {shift_l2[27:0], 4'b0000} : shift_l2;
    assign shift_l4 = (shamt[3]) ? {shift_l3[23:0], 8'b0000_0000} : shift_l3;
    assign shift_l5 = (shamt[4]) ? {shift_l4[15:0], 16'b0000_0000_0000_0000} : shift_l4;

    // Perform Logical Right Shifts
    assign shift_rl1 = (shamt[0]) ? {1'b0, val[31:1]} : val; // Mux Selects between a single bit shift and the whole value
    assign shift_rl2 = (shamt[1]) ? {2'b00, shift_rl1[31:2]} : shift_rl1; // The next 4 muxes select between the last value and the last value shifted
    assign shift_rl3 = (shamt[2]) ? {4'b0000, shift_rl2[31:4]} : shift_rl2;
    assign shift_rl4 = (shamt[3]) ? {8'b0000_0000, shift_rl3[31:8]} : shift_rl3;
    assign shift_rl5 = (shamt[4]) ? {16'b0000_0000_0000_0000, shift_rl4[31:16]} : shift_rl4;

    // Perform Arithmetic Right Shifts
    assign shift_ra1 = (shamt[0]) ? {val[31], val[31:1]}        : val;
    assign shift_ra2 = (shamt[1]) ? {{2{val[31]}}, shift_ra1[31:2]} : shift_ra1;
    assign shift_ra3 = (shamt[2]) ? {{4{val[31]}}, shift_ra2[31:4]} : shift_ra2;
    assign shift_ra4 = (shamt[3]) ? {{8{val[31]}}, shift_ra3[31:8]} : shift_ra3;
    assign shift_ra5 = (shamt[4]) ? {{16{val[31]}}, shift_ra4[31:16]} : shift_ra4;


    // Select type of Right Shift
    assign shift_rf = (shift_arith) ? shift_ra5 : shift_rl5;

    // Select Left or right shift
    assign shifted_val = (shift_right) ? shift_rf : shift_l5;
endmodule

`default_nettype wire