module pc_logic (
    input  logic        clk,
    input  logic        rst,
    input  logic        branch,
    input  logic        zero,
    input  logic [63:0] imm,
    output logic [63:0] pc
);

    logic [63:0] pc_next;
    logic        take_branch;
    
    // Branch decision: take branch if it's a branch instruction AND zero flag is set
    assign take_branch = branch & zero;
    
    // Next PC calculation
    always_comb begin
        if (take_branch) begin
            // Branch taken: PC = PC + sign_extended_offset
            pc_next = pc + imm;
        end else begin
            // Normal increment: PC = PC + 4
            pc_next = pc + 64'd4;
        end
    end

    // PC register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 64'b0;
        end else begin
            pc <= pc_next;
        end
    end

endmodule
