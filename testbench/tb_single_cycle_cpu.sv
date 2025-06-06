`timescale 1ns/1ps
module tb_single_cycle_cpu;
    logic        clk, rst;
    logic [63:0] debug_out;

    // Instantiate top‑level CPU
    single_cycle_cpu uut (
        .clk      (clk),
        .rst      (rst),
        .debug_out(debug_out)
    );

    // --------------- Clock Generation ---------------
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz clock → 10 ns period

    // --------------- Simulation Control ---------------
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_single_cycle_cpu);

        // Hold reset for 15 ns, then release
        rst = 1;
        #15;
        rst = 0;

        // Run for 500 ns more, then finish
        #500 $finish;
    end

    // --------------- Monitor PC & Instruction (only when rst=0) ---------------
    // debug_out[63:32] = PC, debug_out[31:0] = instruction
    always_ff @(posedge clk) begin
        if (!rst) begin
            $display("Time: %0t | PC = 0x%08h | Instr = 0x%08h",
                     $time, debug_out[63:32], debug_out[31:0]);
        end
    end

endmodule
