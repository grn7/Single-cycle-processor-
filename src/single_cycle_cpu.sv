`include "definitions.sv"

module single_cycle_cpu (
    input  logic clk,
    input  logic rst,
    output logic [63:0] debug_out  // Output from register x31 for monitoring
);

    // Program counter
    logic [63:0] pc;
    logic [31:0] instruction;
    logic [63:0] imm;

    // Control signals (removed jump)
    logic [2:0] alu_control;
    logic reg_write, mem_read, mem_write, mem_to_reg;
    logic alu_src, branch;

    // Datapath to memory connections
    logic [63:0] alu_result, write_data_memory;
    logic [4:0] rd_addr;
    logic [63:0] read_data_memory;
    logic zero;

    // Instantiate PC logic (removed jump signal)
    pc_logic pc_module (
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .zero(zero),
        .imm(imm),
        .pc(pc)
    );

    // Instruction Memory (ROM)
    instr_mem instr_mem_inst (
        .address(pc[31:0]),          // 32-bit PC used as byte address
        .instruction(instruction)
    );

    // Sign Extension
    sign_extend sign_ext_inst (
        .instr(instruction),
        .imm_out(imm)
    );

    // Control Unit (removed jump signal)
    control_unit cu (
        .opcode (instruction[6:0]),
        .funct3 (instruction[14:12]),
        .funct7 (instruction[31:25]),
        .alu_control(alu_control),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch)
    );

    // Data Memory
    data_mem data_memory (
        .clk(clk),
        .rst(rst),
        .addr(alu_result[31:0]),
        .wr_data(write_data_memory),
        .wr_enable(mem_write),
        .rd_enable(mem_read),
        .rd_data(read_data_memory)
    );

    // Datapath
    datapath datapath_inst (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .read_data_memory(read_data_memory),
        .alu_control(alu_control),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .alu_result(alu_result),
        .write_data_memory(write_data_memory),
        .rd_addr(rd_addr),
        .zero(zero),
        .debug_out(debug_out)
    );

endmodule
