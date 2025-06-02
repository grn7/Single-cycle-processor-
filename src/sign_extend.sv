module sign_extend (
    input  logic [31:0] instr,
    output logic [63:0] imm_out
);
    logic [6:0] opcode = instr[6:0];

    always_comb begin
        case (opcode)
            7'b0000011: // ld
                imm_out = {{52{instr[31]}}, instr[31:20]}; // I-type
            7'b0100011: // sd
                imm_out = {{52{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
            7'b1100011: // beq
                imm_out = {{51{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            default:
                imm_out = 64'b0;
        endcase
    end
endmodule
