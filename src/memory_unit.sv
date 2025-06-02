module memory_unit #(
    parameter INSTR_MEM_SIZE = 256,
    parameter DATA_MEM_SIZE  = 256
)(
    input  logic         clk,
    input  logic         rst,

    // Instruction memory
    input  logic [63:0]  pc,
    output logic [31:0]  instruction,

    // Data memory
    input  logic [63:0]  addr,
    input  logic [63:0]  write_data,
    input  logic         mem_write,
    input  logic         mem_read,
    output logic [63:0]  read_data
);

    // Instruction memory (ROM, 32-bit words)
    logic [31:0] instr_mem [0:INSTR_MEM_SIZE-1];

    // Data memory (RAM, 64-bit words)
    logic [63:0] data_mem [0:DATA_MEM_SIZE-1];

    // --- Instruction fetch (ROM) ---
    assign instruction = instr_mem[pc[9:2]]; // pc[9:2] to align with 32-bit instructions

    // --- Data read (asynchronous) ---
    assign read_data = (mem_read) ? data_mem[addr[9:3]] : 64'b0; // addr[9:3] for 64-bit alignment

    // --- Data write (synchronous) ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < DATA_MEM_SIZE; i++) begin
                data_mem[i] <= 64'b0;
            end
        end
        else if (mem_write) begin
            data_mem[addr[9:3]] <= write_data;
        end
    end

    // Load instruction memory from file
    initial begin
        $readmemh("instr_mem.mem", instr_mem);
    end

endmodule
