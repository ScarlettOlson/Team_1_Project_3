`default_nettype none

module add_pg_16 (
    input wire [15:0] val1,
    input wire [15:0] val2,
    input wire carry_in,

    output wire [15:0] val_out,
    output wire carry_out,

    output wire prop_out,
    output wire gen_out
);
    wire [3:0] gen;
    wire [3:0] prop;
    wire [3:0] carry;

    add_pg_4 adder0 (
        .val1(val1[3:0]),
        .val2(val2[3:0]),
        .carry_in(carry_in),

        .val_out(val_out[3:0]),
        .carry_out(),

        .prop_out(prop[0]),
        .gen_out(gen[0])
    );
    assign carry[0] = gen[0] | carry_in & prop[0];


    add_pg_4 adder1 (
        .val1(val1[7:4]),
        .val2(val2[7:4]),
        .carry_in(carry[0]),

        .val_out(val_out[7:4]),
        .carry_out(),

        .prop_out(prop[1]),
        .gen_out(gen[1])
    );
    assign carry[1] = gen[1] | carry[0] & prop[1];


    add_pg_4 adder2 (
        .val1(val1[11:8]),
        .val2(val2[11:8]),
        .carry_in(carry[1]),

        .val_out(val_out[11:8]),
        .carry_out(),

        .prop_out(prop[2]),
        .gen_out(gen[2])
    );
    assign carry[2] = gen[2] | carry[1] & prop[2];


    add_pg_4 adder3 (
        .val1(val1[15:12]),
        .val2(val2[15:12]),
        .carry_in(carry[2]),

        .val_out(val_out[15:12]),
        .carry_out(carry_out),

        .prop_out(prop[3]),
        .gen_out(gen[3])
    );
    assign carry[3] = gen[3] | carry[2] & prop[3];


    assign carry_out = carry[3];
    assign prop_out = &prop;
    assign gen_out = gen[3] | 
                    prop[3] & gen[2] | 
                    prop[3] & prop[2] & gen[1] | 
                    prop[3] & prop[2] & prop[1] & gen[0];
    
endmodule

`default_nettype wire