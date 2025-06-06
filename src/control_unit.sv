// File: src/control_unit.sv
`include "definitions.sv"

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [2:0] alu_control,   // ALU operation select
    output logic       reg_write,     // Write to register file?
    output logic       mem_read,      // Read from data_mem?
    output logic       mem_write,     // Write to data_mem?
    output logic       mem_to_reg,    // Write-back: memory or ALU?
    output logic       alu_src,       // ALU second input = immediate?
    output logic       branch         // BEQ?
);

    always_comb begin
        // Defaults
        alu_control = `ALU_ADD;
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 1'b0;
        alu_src     = 1'b0;
        branch      = 1'b0;

        // If opcode is all X’s (unknown), do nothing
        if (opcode === 7'bxxxxxxx) begin
            // keep defaults; no warning
        end else begin
            case (opcode)
                // I‑Type (LD)
                `OP_I_TYPE: begin
                    alu_control = `ALU_ADD;
                    reg_write   = 1'b1;
                    mem_read    = 1'b1;
                    mem_write   = 1'b0;
                    mem_to_reg  = 1'b1;
                    alu_src     = 1'b1;
                    branch      = 1'b0;
                end

                // S‑Type (SD)
                `OP_S_TYPE: begin
                    alu_control = `ALU_ADD;
                    reg_write   = 1'b0;
                    mem_read    = 1'b0;
                    mem_write   = 1'b1;
                    mem_to_reg  = 1'b0;
                    alu_src     = 1'b1;
                    branch      = 1'b0;
                end

                // R‑Type (ADD/SUB/AND/OR)
                `OP_R_TYPE: begin
                    case (funct3)
                        `FUNC3_ADD_SUB: begin
                            if (funct7 == `FUNC7_SUB)
                                alu_control = `ALU_SUB;
                            else
                                alu_control = `ALU_ADD;
                        end
                        `FUNC3_AND: begin
                            alu_control = `ALU_AND;
                        end
                        `FUNC3_OR: begin
                            alu_control = `ALU_OR;
                        end
                        default: begin
                            alu_control = `ALU_ADD;
                        end
                    endcase

                    reg_write   = 1'b1;
                    mem_read    = 1'b0;
                    mem_write   = 1'b0;
                    mem_to_reg  = 1'b0;
                    alu_src     = 1'b0;
                    branch      = 1'b0;
                end

                // B‑Type (BEQ)
                `OP_B_TYPE: begin
                    alu_control = `ALU_SUB;
                    reg_write   = 1'b0;
                    mem_read    = 1'b0;
                    mem_write   = 1'b0;
                    mem_to_reg  = 1'b0;
                    alu_src     = 1'b0;
                    branch      = 1'b1;
                end

                default: begin
                    $display("Warning: Unknown opcode: 0x%h", opcode);
                end
            endcase
        end
    end

endmodule
