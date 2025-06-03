module sign_extend (
    input  logic [31:0] instr,
    output logic [63:0] imm_out
);
    // Extract opcode
    wire [6:0] opcode;
    assign opcode = instr[6:0];
    
    // Create all possible immediate values
    wire [63:0] i_imm_ext, s_imm_ext, b_imm_ext;
    
    assign i_imm_ext = {{52{instr[31]}}, instr[31:20]};
    assign s_imm_ext = {{52{instr[31]}}, instr[31:25], instr[11:7]};
    assign b_imm_ext = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    
    // Select the right one based on opcode
    assign imm_out = (opcode == `OP_I_TYPE) ? i_imm_ext :
                     (opcode == `OP_S_TYPE) ? s_imm_ext :
                     (opcode == `OP_B_TYPE) ? b_imm_ext : 64'b0;
endmodule