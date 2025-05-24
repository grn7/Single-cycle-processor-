// Instruction opcodes
localparam OP_LOAD    = 7'b0000011;
localparam OP_STORE   = 7'b0100011;
localparam OP_BRANCH  = 7'b1100011;
localparam OP_OP_IMM  = 7'b0010011;
localparam OP_OP      = 7'b0110011;
localparam OP_JAL     = 7'b1101111;

// ALU operations
localparam ALU_ADD  = 4'b0000;
localparam ALU_SUB  = 4'b0001;
localparam ALU_AND  = 4'b0010;
localparam ALU_OR   = 4'b0011;
localparam ALU_XOR  = 4'b0100;
localparam ALU_SLT  = 4'b0101;
localparam ALU_SLL  = 4'b0110;
localparam ALU_SRL  = 4'b0111;
localparam ALU_SRA  = 4'b1000;