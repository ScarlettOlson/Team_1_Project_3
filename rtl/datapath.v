module datapath (
    input  wire        clk,
    input  wire        rst,

    // control signals
    input  wire        pc_sel,
    input  wire        reg_wen,
    input  wire        alu_src,
    input  wire [2:0]  alu_op,
    input  wire        mem_wen,
    input  wire        mem_ren,
    input  wire [1:0]  wb_sel,

    // instruction memory
    input  wire [31:0] imem_rdata,
    output wire [31:0] imem_addr,

    // data memory
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    input  wire [31:0] dmem_rdata
);

    // PC
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;

    assign pc_plus4 = pc + 32'd4;
    assign pc_next  = pc_sel ? dmem_addr : pc_plus4;

    always @(posedge clk) begin
        pc <= rst ? 32'd0 : pc_next;
    end

    assign imem_addr = pc;

    // Instruction Fields
    wire [4:0] rs1 = imem_rdata[19:15];
    wire [4:0] rs2 = imem_rdata[24:20];
    wire [4:0] rd  = imem_rdata[11:7];

    // Register File
    wire [31:0] reg_rdata1;
    wire [31:0] reg_rdata2;
    wire [31:0] wb_data;

    regfile rf (
        .clk(clk),
        .wen(reg_wen),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wdata(wb_data),
        .rdata1(reg_rdata1),
        .rdata2(reg_rdata2)
    );

    // Immediate Generator (I-type)
    wire [31:0] imm_i;
    assign imm_i = {{20{imem_rdata[31]}}, imem_rdata[31:20]};

    // ALU
    wire [31:0] alu_op2;
    wire [31:0] alu_result;

    assign alu_op2 = alu_src ? imm_i : reg_rdata2;

    alu alu_unit (
        .a(reg_rdata1),
        .b(alu_op2),
        .op(alu_op),
        .y(alu_result)
    );

    assign dmem_addr  = alu_result;
    assign dmem_wdata = reg_rdata2;

    // Writeback MUX (4:1)
    assign wb_data =
        (wb_sel == 2'd0) ? alu_result :
        (wb_sel == 2'd1) ? dmem_rdata :
        (wb_sel == 2'd2) ? pc_plus4    :
                           32'd0;

endmodule

