`include "defintions.sv"

module alu (
    input  logic [63:0] a,
    input  logic [63:0] b,
    input  logic [2:0]  alu_control,
    output logic [63:0] result,
    output logic        zero
);

    always_comb begin
        case (alu_control)
            `ALU_ADD: result = a + b;
            `ALU_SUB: result = a - b;
            `ALU_AND: result = a & b;
            `ALU_OR:  result = a | b;
            default:  result = 64'b0;
        endcase
    end

    assign zero = (result == 64'b0);

endmodule
