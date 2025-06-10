`timescale 1ns/1ps

module tb_single_cycle_cpu;
    logic        clk, rst;
    logic [63:0] debug_out;

    // Instantiate CPU
    single_cycle_cpu uut (
        .clk      (clk),
        .rst      (rst),
        .debug_out(debug_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_single_cycle_cpu);

        $display("=== RISC-V Single Cycle CPU Test ===");
        $display("Program: Load 15, Load 25, Add them, Set debug to 3");
        $display("");

        // Reset
        rst = 1;
        #20;
        rst = 0;
        $display("Reset released, starting execution...");
        $display("");

        // Run for several cycles
        #100;
        
        // Check final results
        $display("=== FINAL RESULTS ===");
        $display("Debug output (Register 31): %0d", debug_out);
        $display("Register 1: %0d", uut.dp_inst.rf.registers[1]);
        $display("Register 2: %0d", uut.dp_inst.rf.registers[2]);
        $display("Register 3: %0d", uut.dp_inst.rf.registers[3]);
        
        if (debug_out == 64'd3) begin
            $display("✓ SUCCESS: Debug register correct!");
        end else begin
            $display("✗ FAILURE: Debug register wrong");
        end
        
        if (uut.dp_inst.rf.registers[3] == 64'd40) begin
            $display("✓ SUCCESS: Addition correct! 15 + 25 = 40");
        end else begin
            $display("✗ FAILURE: Addition wrong");
        end
        
        $finish;
    end

    // Simple monitoring
    always @(posedge clk) begin
        if (!rst) begin
            $display("Cycle | PC: 0x%02h | Instr: 0x%h | R1: %0d | R2: %0d | R3: %0d | R31: %0d", 
                     uut.pc[7:0], uut.instruction,
                     uut.dp_inst.rf.registers[1],
                     uut.dp_inst.rf.registers[2], 
                     uut.dp_inst.rf.registers[3],
                     uut.dp_inst.rf.registers[31]);
        end
    end

endmodule
