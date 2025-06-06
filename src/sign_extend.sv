`include "definitions.sv"

module sign_extend (
    input  logic [31:0] instr,
    output logic [63:0] imm_out
);

    // I‑type immediate (bits [31:20])
    logic [63:0] imm_i = {{52{instr[31]}}, instr[31:20]};

    // B‑type immediate (bits: [31], [7], [30:25], [11:8], then <<1)
    logic [63:0] imm_b = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

    // Select between I‑type (LD) and B‑type (BEQ)
    assign imm_out = (instr[6:0] == `OP_B_TYPE) ? imm_b : imm_i;

endmodule
