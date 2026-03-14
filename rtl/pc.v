`default_nettype none

module pc #(
    parameter RESET_ADDR = 32'h0000_0000
) (
    input wire          i_clk,
    input wire          i_rst,
    input wire          i_stall,


    input wire [31:0] i_next,
    output wire [31:0]  o_current
);
    reg [31:0] register;

    always@(posedge i_clk) begin
        if(i_rst) begin
            register <= RESET_ADDR;
        end
        else if(!i_stall)begin
          register <= i_next;
        end
    end

    assign o_current = register;

endmodule

`default_nettype wire    