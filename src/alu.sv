module alu (
    input  logic [63:0] a,
    input  logic [63:0] b,
    input  logic [2:0]  alu_control,
    output logic [63:0] result,
    output logic        zero
);

    always_comb begin
        case (alu_control)
            3'b000: result = a + b;    // ADD
            3'b001: result = a - b;    // SUB
            3'b010: result = a & b;    // AND
            3'b011: result = a | b;    // OR
            default: result = 64'b0;
        endcase
    end

    assign zero = (result == 64'b0);

endmodule
