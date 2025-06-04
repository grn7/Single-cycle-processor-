`include "definitions.sv"

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [2:0] alu_control,   
    output logic       reg_write,     
    output logic       mem_read,       
    output logic       mem_write,      
    output logic       mem_to_reg,     
    output logic       alu_src,        
    output logic       branch         
    
    //program counter control
    // output logic       jump            //enable unconditional jump (unused)
);

    always_comb begin
        alu_control = `ALU_ADD;   //default to ADD operation
        reg_write   = 1'b0;       //don't write to registers by default
        mem_read    = 1'b0;       //don't read from memory by default
        mem_write   = 1'b0;       //don't write to memory by default
        mem_to_reg  = 1'b0;       //select ALU result by default
        alu_src     = 1'b0;       //use register for ALU input B by default
        branch      = 1'b0;       //don't branch by default
        // jump        = 1'b0;       //don't jump by default
        
        case (opcode)
            `OP_I_TYPE: begin
                alu_control = `ALU_ADD;   //to calculate memory address(rs1 + offset)
                reg_write   = 1'b1;       
                mem_read    = 1'b1;       
                mem_write   = 1'b0;       
                mem_to_reg  = 1'b1;       
                alu_src     = 1'b1;       //use immediate val (offset) for ALU input B
                branch      = 1'b0;       
                // jump        = 1'b0;       
            end
            
            `OP_S_TYPE: begin
                alu_control = `ALU_ADD;   //to calculate memory address (rs1 + offset)
                reg_write   = 1'b0;       
                mem_read    = 1'b0;       
                mem_write   = 1'b1;       
                mem_to_reg  = 1'b0;       //don't care (not writing to register)
                alu_src     = 1'b1;       
                branch      = 1'b0;       
                // jump        = 1'b0;       
            end

            `OP_R_TYPE: begin
                //determine specific ALU operation based on funct3 and funct7
                case (funct3)
                    `FUNC3_ADD_SUB: begin
                        //ADD or SUB - distinguished by funct7
                        if (funct7 == `FUNC7_ADD)
                            alu_control = `ALU_ADD;   
                        else if (funct7 == `FUNC7_SUB)
                            alu_control = `ALU_SUB;   
                        else
                            alu_control = `ALU_ADD;   //default to ADD 
                    end
                    
                    `FUNC3_AND: begin
                        alu_control = `ALU_AND;       
                    end
                    
                    `FUNC3_OR: begin
                        alu_control = `ALU_OR;        
                    end
                    
                    default: begin
                        alu_control = `ALU_ADD;       //default to ADD for unknown funct3
                    end
                endcase
                
                //common control signals for all R-type instructions
                reg_write   = 1'b1;       
                mem_read    = 1'b0;       
                mem_write   = 1'b0;       
                mem_to_reg  = 1'b0;       
                alu_src     = 1'b0;       
                branch      = 1'b0;       
                // jump        = 1'b0;       
            end

            `OP_B_TYPE: begin
                alu_control = `ALU_SUB;   //use ALU to compare registers (rs1 - rs2)
                reg_write   = 1'b0;       
                mem_read    = 1'b0;       
                mem_write   = 1'b0;       
                mem_to_reg  = 1'b0;       
                alu_src     = 1'b0;       
                branch      = 1'b1;      
                // jump        = 1'b0;       
            end

            default: begin
                alu_control = `ALU_ADD;   //safe default operation
                reg_write   = 1'b0;       
                mem_read    = 1'b0;       
                mem_write   = 1'b0;       
                mem_to_reg  = 1'b0;       
                alu_src     = 1'b0;       
                branch      = 1'b0;       
                // jump        = 1'b0;      
                
                $display("Warning: Unknown opcode 0x%h encountered", opcode);
            end
            
        endcase
    end

endmodule
