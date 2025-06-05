module datapath (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instruction,
    input  logic [63:0] read_data_memory,
    input  logic [2:0]  alu_control,
    input  logic        reg_write,
    input  logic        alu_src,
    input  logic        mem_to_reg,

    output logic [63:0] alu_result,
    output logic [63:0] write_data_memory,
    output logic [4:0]  rd_addr,
    output logic        zero,
    output logic [63:0] debug_out
);

    logic [63:0] rs1_data, rs2_data;
    logic [63:0] imm;
    logic [63:0] alu_b;
    logic [63:0] wb_data;

    logic [4:0] rs1 = instruction[19:15];
    logic [4:0] rs2 = instruction[24:20];
    assign rd_addr  = instruction[11:7];

    reg_file rf (
        .clk(clk),
        .rst(rst),
        .rd_addr1(rs1),
        .rd_data1(rs1_data),
        .rd_addr2(rs2),
        .rd_data2(rs2_data),
        .wr_addr(rd_addr),
        .wr_data(wb_data),
        .wr_enable(reg_write),
        .debug_output(debug_out)
    );

    assign imm = {{52{instruction[31]}}, instruction[31:20]};
    assign alu_b = (alu_src) ? imm : rs2_data;

    alu alu_inst (
        .a(rs1_data),
        .b(alu_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    assign write_data_memory = rs2_data;
    assign wb_data = (mem_to_reg) ? read_data_memory : alu_result;

endmodule
