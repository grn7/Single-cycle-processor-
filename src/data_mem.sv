module data_mem #(
    parameter integer mem_size = 256,
    parameter integer rom_size = 8
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] addr,
    input  logic [63:0] wr_data,
    input  logic        wr_enable,
    input  logic        rd_enable,
    output logic [63:0] rd_data
);

    // Memory array
    reg [63:0] memory_array [0:mem_size-1];
    
    // Word address
    wire [31:0] word_addr = addr[31:3];

    // Initialize memory
    integer i;
    initial begin
        for (i = 0; i < mem_size; i = i + 1) begin
            memory_array[i] = 64'b0;
        end
        
        // Set test data
        memory_array[0] = 64'd15;  // Address 0: value 15
        memory_array[1] = 64'd25;  // Address 8: value 25
        
        $display("Memory initialized: [0]=%0d, [1]=%0d", memory_array[0], memory_array[1]);
    end

    // Write operation
    always_ff @(posedge clk) begin
        if (wr_enable && word_addr < mem_size) begin
            memory_array[word_addr] <= wr_data;
            $display("MEM WRITE: addr=%0d, data=%0d", word_addr, wr_data);
        end
    end

    // Read operation - always output data
    assign rd_data = (word_addr < mem_size) ? memory_array[word_addr] : 64'b0;

endmodule
