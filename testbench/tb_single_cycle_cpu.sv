testbench:
`timescale 1ns/1ps
module tb_single_cycle_cpu;
    logic clk, rst;
    logic [63:0] debug_out;

    single_cycle_cpu uut (
        .clk(clk),
        .rst(rst),
        .debug_out(debug_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // Simulation control
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_single_cycle_cpu);
        rst = 1;
        #15;
        rst = 0;

        // Run simulation for 500ns
        #500 $finish;
    end
endmodule
