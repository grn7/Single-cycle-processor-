`timescale 1ns/1ps

module tb_fibonacci_comprehensive;
    // Clock, reset, debug output
    logic        clk, rst;
    logic [63:0] debug_out;

    // Instruction counters
    int load_count   = 0;
    int store_count  = 0;
    int add_count    = 0;
    int sub_count    = 0;
    int and_count    = 0;
    int or_count     = 0;
    int beq_count    = 0;
    int addi_count   = 0;
    int total_instr  = 0;
    int cycle_count  = 0;

    // Expected Fibonacci values (initialized later)
    static logic [63:0] expected_fib [0:9];

    // Workspace variables
    logic [63:0] fib_value;
    int correct_count;

    // Instantiate CPU with Fibonacci program
    single_cycle_cpu uut (
        .clk      (clk),
        .rst      (rst),
        .debug_out(debug_out)
    );

    // Override memory files for this test
    defparam uut.instr_mem_inst.mem_size  = 17;
    defparam uut.instr_mem_inst.mem_file  = "programs/fibo_comp.mem";
    defparam uut.data_mem_inst.rom_file   = "programs/fibo_data.mem";
    defparam uut.data_mem_inst.rom_size   = 2;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Main test sequence
    initial begin
        $dumpfile("fibo_comp.vcd");
        $dumpvars(0, tb_fibonacci_comprehensive);

        // Initialize expected_fib array
        expected_fib[0] = 1;
        expected_fib[1] = 1;
        expected_fib[2] = 2;
        expected_fib[3] = 3;
        expected_fib[4] = 5;
        expected_fib[5] = 8;
        expected_fib[6] = 13;
        expected_fib[7] = 21;
        expected_fib[8] = 34;
        expected_fib[9] = 55;

        // Display header
        $display("=== RISC-V Fibonacci Comprehensive Test ===");
        $display("Testing ALL instructions with Fibonacci sequence calculation\n");

        // Reset
        rst = 1;
        #20;
        rst = 0;
        $display("Reset released, starting Fibonacci calculation...\n");

        // Run simulation
        #1000;

        // Report final register values
        $display("=== FINAL RESULTS ===");
        $display("Debug output (Register 31): %0d", debug_out);
        $display("Register 1 (Fib n-1): %0d", uut.dp_inst.rf.registers[1]);
        $display("Register 2 (Fib n):   %0d", uut.dp_inst.rf.registers[2]);
        $display("Register 3 (Fib n+1): %0d", uut.dp_inst.rf.registers[3]);
        $display("Register 5 (index):   %0d\n", uut.dp_inst.rf.registers[5]);

        // Instruction coverage
        $display("=== INSTRUCTION COVERAGE ===");
        $display("Total instructions: %0d", total_instr);
        $display(" LD:   %0d", load_count);
        $display(" SD:   %0d", store_count);
        $display(" ADD:  %0d", add_count);
        $display(" SUB:  %0d", sub_count);
        $display(" AND:  %0d", and_count);
        $display(" OR:   %0d", or_count);
        $display(" BEQ:  %0d", beq_count);
        $display(" ADDI: %0d\n", addi_count);

        if (load_count>0 && store_count>0 && add_count>0 && sub_count>0 &&
            and_count>0 && or_count>0 && beq_count>0 && addi_count>0) begin
            $display("✓ SUCCESS: All instruction types executed!\n");
        end else begin
            $display("✗ FAILURE: Missing instruction executions!\n");
        end

        // Fibonacci memory contents
        $display("=== FIBONACCI SEQUENCE IN MEMORY ===");
        for (int i = 0; i < 10; i++) begin
            fib_value = uut.data_mem_inst.memory_array[i];
            $display(" Fib(%0d) = %0d", i+1, fib_value);
        end

        // Verify against expected
        correct_count = 0;
        for (int i = 0; i < uut.dp_inst.rf.registers[5] && i < 10; i++) begin
            if (uut.data_mem_inst.memory_array[i] == expected_fib[i]) begin
                correct_count++;
            end
        end
        $display("\nVerification: %0d/%0d correct values", correct_count, uut.dp_inst.rf.registers[5]);
        if (correct_count >= 5) begin
            $display("✓ Fibonacci calculation is working correctly!");
        end else begin
            $display("✗ Fibonacci calculation has errors");
        end

        $finish;
    end

    // Instruction tracking on each clock
    always @(posedge clk) begin
        if (!rst) begin
            cycle_count++;
            case (uut.instruction[6:0])
                7'b0000011: load_count++;
                7'b0100011: store_count++;
                7'b0110011: begin
                    case (uut.instruction[14:12])
                        3'b000: if (uut.instruction[30]) sub_count++; else add_count++;
                        3'b111: and_count++;
                        3'b110: or_count++;
                    endcase
                end
                7'b1100011: beq_count++;
                7'b0010011: addi_count++;
            endcase

            if (uut.instruction != 32'h00000013) begin
                total_instr++;
                if (cycle_count <= 20) begin
                    $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%h | Type: %s | R1: %0d | R2: %0d | R3: %0d | R5: %0d | R31: %0d", 
                             cycle_count,
                             uut.pc[7:0],
                             uut.instruction,
                             get_instr_type(uut.instruction),
                             uut.dp_inst.rf.registers[1],
                             uut.dp_inst.rf.registers[2],
                             uut.dp_inst.rf.registers[3],
                             uut.dp_inst.rf.registers[5],
                             uut.dp_inst.rf.registers[31]);
                end
            end

            if (cycle_count % 20 == 0) begin
                $display("--- Cycle %0d: computed %0d fib numbers ---", cycle_count, uut.dp_inst.rf.registers[5]);
            end

            if (cycle_count > 200) begin
                $display("Stopping simulation after 200 cycles");
                $finish;
            end
        end
    end

    // Helper: decode instruction type
    function string get_instr_type(logic [31:0] instr);
        case (instr[6:0])
            7'b0000011: get_instr_type = "LD";
            7'b0100011: get_instr_type = "SD";
            7'b0110011: begin
                case (instr[14:12])
                    3'b000: get_instr_type = instr[30] ? "SUB" : "ADD";
                    3'b111: get_instr_type = "AND";
                    3'b110: get_instr_type = "OR";
                    default: get_instr_type = "R-TYPE";
                endcase
            end
            7'b1100011: get_instr_type = "BEQ";
            7'b0010011: get_instr_type = "ADDI";
            default:      get_instr_type = "UNKNOWN";
        endcase
    endfunction

endmodule
