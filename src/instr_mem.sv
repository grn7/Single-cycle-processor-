module instr_mem #(
    parameter integer mem_size = 5
) (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    // Instruction array
    reg [31:0] memory_array [0:mem_size-1];
    
    // Initialize with our test program
    initial begin
        memory_array[0] = 32'h00003083;  // ld x1, 0(x0)   - Load 15 into x1
        memory_array[1] = 32'h00803103;  // ld x2, 8(x0)   - Load 25 into x2
        memory_array[2] = 32'h002081b3;  // add x3, x1, x2 - x3 = x1 + x2 = 40
        memory_array[3] = 32'h00300f93;  // addi x31, x0, 3 - x31 = 3
        memory_array[4] = 32'h00000013;  // nop
        
        $display("Instructions loaded:");
        $display("  [0]: 0x%h (ld x1, 0(x0))", memory_array[0]);
        $display("  [1]: 0x%h (ld x2, 8(x0))", memory_array[1]);
        $display("  [2]: 0x%h (add x3, x1, x2)", memory_array[2]);
        $display("  [3]: 0x%h (addi x31, x0, 3)", memory_array[3]);
    end

    // Output instruction
    wire [31:0] word_addr = address[31:2];
    assign instruction = (word_addr < mem_size) ? memory_array[word_addr] : 32'h00000013;

endmodule
