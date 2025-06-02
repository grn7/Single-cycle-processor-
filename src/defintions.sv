`ifndef DEFINITIONS_SV
`define DEFINITIONS_SV

// ALU control signals
`define ALU_ADD 3'b000
`define ALU_SUB 3'b001
`define ALU_AND 3'b010
`define ALU_OR  3'b011

// Opcode definitions
`define OP_R_TYPE   7'b0110011
`define OP_I_TYPE   7'b0000011
`define OP_S_TYPE   7'b0100011
`define OP_B_TYPE   7'b1100011

// Function codes
`define FUNC3_ADD_SUB 3'b000
`define FUNC3_AND     3'b111
`define FUNC3_OR      3'b110

`define FUNC7_ADD     7'b0000000
`define FUNC7_SUB     7'b0100000

`endif
