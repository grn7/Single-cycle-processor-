`include "definitions.sv"

module single_cycle_cpu (
    input  logic        clk,
    input  logic        rst,
    output logic [63:0] debug_out
);

    // Internal signals
    logic [63:0] pc;
    logic [31:0] instruction;
    logic [63:0] imm;

    // Control signals
    logic [2:0]  alu_control;
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        alu_src;
    logic        branch;

    // Datapath signals
    logic [63:0] alu_result;
    logic [63:0] write_data_memory;
    logic [63:0] read_data_memory;
    logic [4:0]  rd_addr;
    logic        zero;

    // Program Counter
    pc_logic pc_inst (
        .clk    (clk),
        .rst    (rst),
        .branch (branch),
        .zero   (zero),
        .imm    (imm),
        .pc     (pc)
    );

    // Instruction Memory
    instr_mem #(
        .mem_size(17),
        .mem_file("programs/fibo_comp.mem")
    ) instr_mem_inst (
        .address    (pc[31:0]),
        .instruction(instruction)
    );

    // Sign Extension
    sign_extend sign_ext_inst (
        .instr   (instruction),
        .imm_out (imm)
    );

    // Control Unit
    control_unit cu_inst (
        .opcode      (instruction[6:0]),
        .funct3      (instruction[14:12]),
        .funct7      (instruction[31:25]),
        .alu_control (alu_control),
        .reg_write   (reg_write),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .mem_to_reg  (mem_to_reg),
        .alu_src     (alu_src),
        .branch      (branch)
    );

    // Data Memory - reduce ROM size to allow more writes
    data_mem #(
        .mem_size(256),
        .rom_size(2),  // Only protect first 2 addresses
        .rom_file("programs/fibo_data.mem")
    ) data_mem_inst (
        .clk       (clk),
        .rst       (rst),
        .addr      (alu_result[31:0]),
        .wr_data   (write_data_memory),
        .wr_enable (mem_write),
        .rd_enable (1'b1),
        .rd_data   (read_data_memory)
    );

    // Datapath - now passes immediate from sign_extend
    datapath dp_inst (
        .clk                 (clk),
        .rst                 (rst),
        .instruction         (instruction),
        .read_data_memory    (read_data_memory),
        .imm_ext             (imm),  // Pass immediate from sign_extend
        .alu_control         (alu_control),
        .reg_write           (reg_write),
        .alu_src             (alu_src),
        .mem_to_reg          (mem_to_reg),
        .alu_result          (alu_result),
        .write_data_memory   (write_data_memory),
        .rd_addr             (rd_addr),
        .zero                (zero),
        .debug_out           (debug_out)
    );

endmodule
