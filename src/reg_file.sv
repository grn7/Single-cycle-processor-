module reg_file(
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  rd_addr1,
    output logic [63:0] rd_data1,
    input  logic [4:0]  rd_addr2,
    output logic [63:0] rd_data2,
    input  logic [4:0]  wr_addr,
    input  logic [63:0] wr_data,
    input  logic        wr_enable,
    output logic [63:0] debug_output
);

    // Register array
    reg [63:0] registers [0:31];
    
    // Initialize all registers to 0
    integer i;
    initial begin
        for (i = 0; i <= 31; i = i + 1) begin
            registers[i] = 64'b0;
        end
    end

    // Write operation
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i <= 31; i = i + 1) begin
                registers[i] <= 64'b0;
            end
        end else if (wr_enable && wr_addr != 5'b0) begin
            registers[wr_addr] <= wr_data;
            $display("REG WRITE: x%0d = %0d", wr_addr, wr_data);
        end
    end

    // Read operations
    assign rd_data1 = (rd_addr1 == 5'b0) ? 64'b0 : registers[rd_addr1];
    assign rd_data2 = (rd_addr2 == 5'b0) ? 64'b0 : registers[rd_addr2];
    assign debug_output = registers[31];

endmodule
