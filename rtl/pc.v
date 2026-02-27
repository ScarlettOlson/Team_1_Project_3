`default_nettype none

module pc #(
    parameter RESET_ADDR = 32'h00000000
) (
    // Global clock.
    input  wire        i_clk,
    // Synchronous active-high reset.
    input  wire        i_rst,


    input [31:0] i_next,
    output [31:0]  o_current
);
    reg [31:0] register;

    always@(posedge i_clk) begin
        if(i_rst) begin
            register <= RESET_ADDR;
        end
        else begin
          register <= i_next;
        end
    end

    assign o_current = register;

endmodule
    