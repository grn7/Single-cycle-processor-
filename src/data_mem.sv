module data_mem #(
    parameter integer mem_size = 256,                // total 64‑bit words
    parameter integer rom_size = 4,
    parameter string  rom_file  = "programs/data.mem" // initial ROM contents
) (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] addr,    // byte address
    input  logic [63:0] wr_data,
    input  logic        wr_enable,
    input  logic        rd_enable,
    output logic [63:0] rd_data
);

    logic [63:0] memory_array [0:mem_size-1];
    logic [31:0] word_addr = addr[31:3]; // convert byte address to 64‑bit word index

    initial begin
        // Initialize entire data memory to zero
        for (int i = 0; i < mem_size; i++) begin
            memory_array[i] = 64'b0;
        end
        // Preload the first rom_size words from the .mem file
        $display("Loading data memory (ROM portion) from %s", rom_file);
        $readmemh(rom_file, memory_array, 0, rom_size-1);
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // only reset RAM portion (addresses ≥ rom_size)
            for (int i = rom_size; i < mem_size; i++) begin
                memory_array[i] <= 64'b0;
            end
        end else if (wr_enable) begin
            if (word_addr >= rom_size) begin
                memory_array[word_addr] <= wr_data;
            end else begin
                $display("Attempt to write to ROM region at address %0d", word_addr);
            end
        end
    end

    always_comb begin
        if (rd_enable) begin
            rd_data = memory_array[word_addr];
        end else begin
            rd_data = 64'b0;
        end
    end

endmodule
