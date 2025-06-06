`include "definitions.sv"

module single_cycle_cpu (
    input  logic        clk,
    input  logic        rst,
    output logic [63:0] debug_out   // packs {PC[31:0], instruction[31:0]} for our testbench
);

    // ***** Internal wires *****
    logic [63:0] pc;                // 64‑bit program counter
    logic [31:0] instruction;       // 32‑bit fetched instruction
    logic [63:0] imm;               // sign‑extended immediate

    // Control signals
    logic [2:0]  alu_control;
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        alu_src;
    logic        branch;

    // Datapath ↔ Memory wires
    logic [63:0] alu_result;
    logic [63:0] write_data_memory;
    logic [63:0] read_data_memory;
    logic [4:0]  rd_addr;   // unused at top level
    logic        zero;

    // ***** Module instantiations *****

    // 1) Program Counter logic
    pc_logic pc_inst (
        .clk    (clk),
        .rst    (rst),
        .branch (branch),
        .zero   (zero),
        .imm    (imm),
        .pc     (pc)
    );

    // 2) Instruction Memory (reads from "programs/program.mem")
    instr_mem #(
        .mem_size(6),
        .mem_file ("programs/program.mem")
    ) instr_mem_inst (
        .address    (pc[31:0]),
        .instruction(instruction)
    );

    // 3) Sign‑extension unit (I‑type or B‑type)
    sign_extend sign_ext_inst (
        .instr   (instruction),
        .imm_out (imm)
    );

    // 4) Control Unit
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

    // 5) Data Memory
    data_mem #(
        .mem_size(256),
        .rom_size(4),
        .rom_file("programs/data.mem")
    ) data_mem_inst (
        .clk       (clk),
        .rst       (rst),
        .addr      (alu_result[31:0]),
        .wr_data   (write_data_memory),
        .wr_enable (mem_write),
        .rd_enable (mem_read),
        .rd_data   (read_data_memory)
    );

    // 6) Datapath
    datapath dp_inst (
        .clk                 (clk),
        .rst                 (rst),
        .instruction         (instruction),
        .read_data_memory    (read_data_memory),
        .alu_control         (alu_control),
        .reg_write           (reg_write),
        .alu_src             (alu_src),
        .mem_to_reg          (mem_to_reg),
        .alu_result          (alu_result),
        .write_data_memory   (write_data_memory),
        .rd_addr             (rd_addr),
        .zero                (zero),
        .debug_out           (/*not used at top‑level*/ ) 
    );

    // ***** Pack PC + instruction into debug_out for the testbench *****
    // Upper 32 bits = PC[31:0], Lower 32 bits = fetched instruction[31:0]
    assign debug_out = { pc[31:0], instruction };

endmodule
