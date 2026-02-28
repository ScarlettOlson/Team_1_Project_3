`default_nettype none

module add_pg_4 (
    input wire [3:0] val1,
    input wire [3:0] val2,
    input wire carry_in,

    output wire [3:0] val_out,
    output wire carry_out,

    output wire prop_out,
    output wire gen_out
);
    wire [3:0] gen ;
    wire [3:0] prop;
    wire [3:0] carry;

    assign gen = val1 & val2;
    assign prop = val1 ^ val2;


    assign carry[0] = gen[0] | (carry_in & prop[0]);
    assign carry[1] = gen[1] | (carry[0] & prop[1]);
    assign carry[2] = gen[2] | (carry[1] & prop[2]);
    assign carry[3] = gen[3] | (carry[2] & prop[3]);

    
    assign val_out[0] = val1[0] ^ val2[0] ^ carry_in;
    assign val_out[1] = val1[1] ^ val2[1] ^ carry[0];
    assign val_out[2] = val1[2] ^ val2[2] ^ carry[1];
    assign val_out[3] = val1[3] ^ val2[3] ^ carry[2];
    assign carry_out = carry[3];

    assign prop_out = &prop;
    assign gen_out = gen[3] | 
                    (prop[3] & gen[2]) | 
                    (prop[3] & prop[2] & gen[1]) | 
                    (prop[3] & prop[2] & prop[1] & gen[0]);

endmodule

`default_nettype wire