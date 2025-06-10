`include "definitions.sv"

module sign_extend (
    input  logic [31:0] instr,
    output logic [63:0] imm_out
);

    // Simple I-type immediate for all instructions
    assign imm_out = {{52{instr[31]}}, instr[31:20]};

endmodule
