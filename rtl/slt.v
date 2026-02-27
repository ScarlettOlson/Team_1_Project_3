`default_nettype none

module set_less_than (
    input [31:0] val1,
    input [31:0] val2,
    input i_unsigned,

    output less_than
);
    wire [31:0] sub;
    wire [31:0] sub_op2 = val2 ^ {32{1'b1}};
    wire carry;

    add_pg_32 suber(
        .val1(val1),
        .val2(sub_op2),
        .carry_in(1'b1),

        .val_out(sub),
        .carry_out(carry),

        .prop_out(),
        .gen_out()
    );
    // Unsigned Comparison
    wire less_unsigned = ~carry;

    // Signed Comparison
    wire sign1 = val1[31]; 
    wire sign2 = val2[31]; 
    wire sign_sub = sub[31]; 
    wire less_signed = (sign1 != sign2) ? sign1 : sign_sub;

    // Select signed or unsigned result 
    assign less_than = i_unsigned ? less_unsigned : less_signed;


endmodule

`default_nettype wire