module pc_logic (
    input  logic        clk,
    input  logic        rst,
    input  logic        branch,
    input  logic        zero,
    input  logic [63:0] imm,
    output logic [63:0] pc
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 64'b0;
        end else begin
            pc <= pc + 64'd4;  // Simple increment, ignore branches for now
        end
    end

endmodule
