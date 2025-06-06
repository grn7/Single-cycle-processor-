module instr_mem #(
    parameter integer mem_size = 6,
    parameter string  mem_file  = "programs/program.mem"
) (
    input  logic [31:0] address,    // PC[31:0] as byte address
    output logic [31:0] instruction // fetched 32‑bit instruction
);

    logic [31:0] memory_array [0:mem_size-1];

    initial begin
        // Initialize all 6 slots to “R‑type NOP” = add x0,x0,x0 = 32'h00000033
        for (int i = 0; i < mem_size; i++) begin
            memory_array[i] = 32'h00000033;
        end

        // Load exactly 6 instructions from the .mem file
        $display("Loading instruction memory from %s", mem_file);
        $readmemh(mem_file, memory_array);
    end

    // Convert byte address to word index (divide by 4).
    // If out of bounds (i.e. index ≥ mem_size), return R‑type NOP = 32'h00000033
    assign instruction = (address[31:2] < mem_size)
                       ? memory_array[address[31:2]]
                       : 32'h00000033;

endmodule
