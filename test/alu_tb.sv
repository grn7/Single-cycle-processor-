`include "../src/includes/definitions.sv"


module alu_tb;
    logic [31:0] a, b;
    logic [3:0] alu_control;
    logic [31:0] result;
    logic zero;
    
    alu dut (
        // module definition stuff
    );
    
    initial begin
        // Test ADD
        a = 32'd5; b = 32'd7; alu_control = ALU_ADD;
        #10;
        assert(result == 32'd12) else $error("ADD failed");
        
        // Test SUB
        a = 32'd10; b = 32'd3; alu_control = ALU_SUB;
        #10;
        assert(result == 32'd7) else $error("SUB failed");
        
        // More tests...
        
        $display("ALU tests completed");
    end
endmodule