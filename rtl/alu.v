`default_nettype none

// The arithmetic logic unit (ALU) is responsible for performing the core
// calculations of the processor. It takes two 32-bit operands and outputs
// a 32 bit result based on the selection operation - addition, comparison,
// shift, or logical operation. This ALU is a purely combinational block, so
// you should not attempt to add any registers or pipeline it.
module alu (
    // NOTE: Both 3'b010 and 3'b011 are used for set less than operations and
    // your implementation should output the same result for both codes. The
    // reason for this will become clear in project 3.
    //
    // Major operation selection.
    // 3'b000: addition/subtraction if `i_sub` asserted
    // 3'b001: shift left logical
    // 3'b010,
    // 3'b011: set less than/unsigned if `i_unsigned` asserted
    // 3'b100: exclusive or
    // 3'b101: shift right logical/arithmetic if `i_arith` asserted
    // 3'b110: or
    // 3'b111: and
    input  wire [ 2:0] i_opsel,
    // When asserted, addition operations should subtract instead.
    // This is only used for `i_opsel == 3'b000` (addition/subtraction).
    input  wire        i_sub,
    // When asserted, comparison operations should be treated as unsigned.
    // This is used for branch comparisons and set less than unsigned. For
    // b ranch operations, the ALU result is not used, only the comparison
    // results.
    input  wire        i_unsigned,
    // When asserted, right shifts should be treated as arithmetic instead of
    // logical. This is only used for `i_opsel == 3'b101` (shift right).
    input  wire        i_arith,
    // First 32-bit input operand.
    input  wire [31:0] i_op1,
    // Second 32-bit input operand.
    input  wire [31:0] i_op2,
    // 32-bit output result. Any carry out should be ignored.
    output wire [31:0] o_result,
    // Equality result. This is used externally to determine if a branch
    // should be taken.
    output wire        o_eq,
    // Set less than result. This is used externally to determine if a branch
    // should be taken.
    output wire        o_slt
);
    wire [31:0] add;
    wire [31:0] sub;
    wire [31:0] shift;
    wire slt;
    wire [31:0] val_xor;
    wire [31:0] val_or;
    wire [31:0] val_and;

    // Perform add and subtract
    add_pg_32 adder(
        .val1(i_op1),
        .val2(i_op2),
        .carry_in(1'b0),

        .val_out(add),
        .carry_out(),

        .prop_out(),
        .gen_out()
    );
    wire [31:0] sub_op2 = i_op2 ^ {32{1'b1}};
    add_pg_32 suber(
        .val1(i_op1),
        .val2(sub_op2),
        .carry_in(1'b1),

        .val_out(sub),
        .carry_out(),

        .prop_out(),
        .gen_out()
    );
    
    // Perfom shift logical
    shifter shifter0(
        .val(i_op1),
        .shamt(i_op2[4:0]),
        .shift_right(i_opsel[2]),
        .shift_arith(i_arith),

        .shifted_val(shift)
    );

    // Perform set less than
    set_less_than slt1(
        .val1(i_op1),
        .val2(i_op2),
        .i_unsigned(i_unsigned),

        .less_than(slt)
    );

    // Perform xor
    assign val_xor = i_op1 ^ i_op2;

    // Perform or
    assign val_or = i_op1 | i_op2;

    // Perform and
    assign val_and = i_op1 & i_op2;

    // Select between add and subtract
    wire [31:0] add_sub;
    assign add_sub = (i_sub) ? sub : add;

    // Set branching flags
    assign o_eq = ~|sub;
    assign o_slt = slt;

    // Set result value
    assign o_result = 
        (i_opsel == 3'b000) ? add_sub :             // Select Add/Sub
        (i_opsel == 3'b001) ? shift :               // Select Shift
        (i_opsel == 3'b010) ? {{31{1'b0}}, slt} :   // Set less then
        (i_opsel == 3'b011) ? {{31{1'b0}}, slt} :   // Set less then unsigned
        (i_opsel == 3'b100) ? val_xor :             // Select xor
        (i_opsel == 3'b101) ? shift :               // Select Shift
        (i_opsel == 3'b110) ? val_or :              // Select or
        val_and;                                    // Select and


endmodule

`default_nettype wire
