`default_nettype none

module add_pg_32 (
    input wire [31:0] val1,
    input wire [31:0] val2,
    input wire carry_in,

    output wire [31:0] val_out,
    output wire carry_out,

    output wire prop_out,
    output wire gen_out
);
    wire [1:0] gen;
    wire [1:0] prop;
    wire [1:0] carry;

    add_pg_16 adder0 (
        .val1(val1[15:0]),
        .val2(val2[15:0]),
        .carry_in(carry_in),

        .val_out(val_out[15:0]),
        .carry_out(),

        .prop_out(prop[0]),
        .gen_out(gen[0])
    );
    assign carry[0] = gen[0] | (carry_in & prop[0]);


    add_pg_16 adder1 (
        .val1(val1[31:16]),
        .val2(val2[31:16]),
        .carry_in(carry[0]),

        .val_out(val_out[31:16]),
        .carry_out(),

        .prop_out(prop[1]),
        .gen_out(gen[1])
    );
    assign carry[1] = gen[1] | (carry[0] & prop[1]);

    assign carry_out = carry[1];
    assign prop_out = &prop;
    assign gen_out = gen[1] | (prop[1] & gen[0]);
endmodule

`default_nettype wire