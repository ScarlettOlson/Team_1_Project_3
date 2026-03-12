`default_nettype none


module if_id_reg (
    input wire        i_clk,
    
    input wire [31:0] i_instr,
    input wire [31:0] i_imem_raddr,
    input wire [31:0] i_pc,
    input wire [31:0] i_pc_plus_4,

    output wire [31:0] o_instr,
    output wire [31:0] o_imem_raddr,
    output wire [31:0] o_pc,
    output wire [31:0] o_pc_plus_4
);
    reg [31:0] instr;
    reg [31:0] imem_raddr;
    reg [31:0] pc;
    reg [31:0] pc_plus_4;


    always@(posedge i_clk) begin
        instr       <= i_instr;
        imem_raddr     <= i_imem_raddr;
        pc          <= i_pc;
        pc_plus_4   <= i_pc_plus_4;
    end

    assign o_instr      = instr;
    assign o_imem_raddr = imem_raddr;
    assign o_pc         = pc;
    assign o_pc_plus_4  = pc_plus_4;


endmodule
`default_nettype  wire 