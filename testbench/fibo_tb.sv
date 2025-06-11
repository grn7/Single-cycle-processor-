`timescale 1ps/1ps

module fibo_tb;
    // Clock and reset
    logic clk;
    logic rst;
    logic [63:0] debug_out;

    // Instantiate the CPU
    single_cycle_cpu cpu (
        .clk(clk),
        .rst(rst),
        .debug_out(debug_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5000 clk = ~clk;
    end

    // Instruction type counters
    int ld_count = 0;
    int sd_count = 0;
    int add_count = 0;
    int sub_count = 0;
    int and_count = 0;
    int or_count = 0;
    int beq_count = 0;
    int addi_count = 0;
    int total_instr = 0;
    int cycle_count = 0;

    // Monitor instruction execution with detailed info
    always @(posedge clk) begin
        if (!rst) begin
            cycle_count++;
            
            // Decode current instruction and display detailed info
            case (cpu.instruction[6:0])
                7'b0000011: begin // LD
                    $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: LD", 
                             cycle_count, cpu.pc, cpu.instruction);
                    $display("  LD x%0d, %0d(x%0d) | x%0d=%0d -> x%0d", 
                             cpu.instruction[11:7], $signed(cpu.imm[11:0]), cpu.instruction[19:15],
                             cpu.instruction[19:15], cpu.dp_inst.rs1_data, cpu.instruction[11:7]);
                    ld_count++;
                end
                7'b0100011: begin // SD
                    $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: SD", 
                             cycle_count, cpu.pc, cpu.instruction);
                    $display("  SD x%0d, %0d(x%0d) | Store x%0d=%0d to addr=%0d", 
                             cpu.instruction[24:20], $signed(cpu.imm[11:0]), cpu.instruction[19:15],
                             cpu.instruction[24:20], cpu.dp_inst.rs2_data, cpu.alu_result);
                    sd_count++;
                end
                7'b0110011: begin // R-type
                    case ({cpu.instruction[31:25], cpu.instruction[14:12]})
                        {7'b0000000, 3'b000}: begin // ADD
                            $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: ADD", 
                                     cycle_count, cpu.pc, cpu.instruction);
                            $display("  ADD x%0d, x%0d, x%0d | %0d + %0d = %0d", 
                                     cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20],
                                     cpu.dp_inst.rs1_data, cpu.dp_inst.rs2_data, cpu.alu_result);
                            add_count++;
                        end
                        {7'b0100000, 3'b000}: begin // SUB
                            $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: SUB", 
                                     cycle_count, cpu.pc, cpu.instruction);
                            $display("  SUB x%0d, x%0d, x%0d | %0d - %0d = %0d", 
                                     cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20],
                                     cpu.dp_inst.rs1_data, cpu.dp_inst.rs2_data, cpu.alu_result);
                            sub_count++;
                        end
                        {7'b0000000, 3'b111}: begin // AND
                            $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: AND", 
                                     cycle_count, cpu.pc, cpu.instruction);
                            $display("  AND x%0d, x%0d, x%0d | %0d & %0d = %0d", 
                                     cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20],
                                     cpu.dp_inst.rs1_data, cpu.dp_inst.rs2_data, cpu.alu_result);
                            and_count++;
                        end
                        {7'b0000000, 3'b110}: begin // OR
                            $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: OR", 
                                     cycle_count, cpu.pc, cpu.instruction);
                            $display("  OR x%0d, x%0d, x%0d | %0d | %0d = %0d", 
                                     cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20],
                                     cpu.dp_inst.rs1_data, cpu.dp_inst.rs2_data, cpu.alu_result);
                            or_count++;
                        end
                        default: begin
                            $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: R-TYPE", 
                                     cycle_count, cpu.pc, cpu.instruction);
                        end
                    endcase
                end
                7'b1100011: begin // BEQ
                    $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: BEQ", 
                             cycle_count, cpu.pc, cpu.instruction);
                    $display("  BEQ x%0d, x%0d, %0d | Compare %0d == %0d? %s", 
                             cpu.instruction[19:15], cpu.instruction[24:20], $signed(cpu.imm),
                             cpu.dp_inst.rs1_data, cpu.dp_inst.rs2_data, 
                             cpu.zero ? "YES (branch)" : "NO");
                    beq_count++;
                end
                7'b0010011: begin // ADDI
                    $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: ADDI", 
                             cycle_count, cpu.pc, cpu.instruction);
                    $display("  ADDI x%0d, x%0d, %0d | %0d + %0d = %0d", 
                             cpu.instruction[11:7], cpu.instruction[19:15], $signed(cpu.imm[11:0]),
                             cpu.dp_inst.rs1_data, $signed(cpu.imm[11:0]), cpu.alu_result);
                    addi_count++;
                end
                default: begin
                    $display("CYCLE %0d | PC: 0x%02h | Instr: 0x%08h | Type: UNKNOWN", 
                             cycle_count, cpu.pc, cpu.instruction);
                end
            endcase
            
            // Show register file state for key registers
            $display("  Registers: x1=%0d x2=%0d x3=%0d x5=%0d x31=%0d", 
                     cpu.dp_inst.rf.registers[1], cpu.dp_inst.rf.registers[2], 
                     cpu.dp_inst.rf.registers[3], cpu.dp_inst.rf.registers[5], 
                     cpu.dp_inst.rf.registers[31]);
            $display("");
            
            total_instr++;
        end
    end

    // Test sequence
    initial begin
        // Variables for Fibonacci verification
        integer expected_fib[0:9];
        integer i;
        integer mem_addr;
        integer mem_value;
        integer correct_count;
        
        $dumpfile("fibo_comp.vcd");
        $dumpvars(0, fibo_tb);
        
        $display("=== RISC-V Fibonacci Comprehensive Test ===");
        $display("Testing ALL instructions with Fibonacci sequence calculation");
        $display("=========================================================");
        $display("");
        
        // Reset the CPU
        rst = 1;
        repeat(5) @(posedge clk);
        rst = 0;
        
        $display("Reset released, starting Fibonacci calculation...");
        $display("");
        
        // Run for 100 cycles
        repeat(100) begin
            @(posedge clk);
            if (cycle_count % 20 == 0 && cycle_count > 0) begin
                $display("--- After %0d cycles: computed %0d fib numbers ---", 
                         cycle_count, cpu.dp_inst.rf.registers[5]);
                $display("");
            end
        end
        
        // Display final results
        $display("=== FINAL RESULTS ===");
        $display("Debug output (Register 31): %0d", debug_out);
        $display("Register 1 (Fib n-1): %0d", cpu.dp_inst.rf.registers[1]);
        $display("Register 2 (Fib n):   %0d", cpu.dp_inst.rf.registers[2]);
        $display("Register 3 (Fib n+1): %0d", cpu.dp_inst.rf.registers[3]);
        $display("Register 5 (index):   %0d", cpu.dp_inst.rf.registers[5]);
        
        // Display instruction coverage
        $display("");
        $display("=== INSTRUCTION COVERAGE ===");
        $display("Total instructions: %0d", total_instr);
        $display(" LD:   %0d", ld_count);
        $display(" SD:   %0d", sd_count);
        $display(" ADD:  %0d", add_count);
        $display(" SUB:  %0d", sub_count);
        $display(" AND:  %0d", and_count);
        $display(" OR:   %0d", or_count);
        $display(" BEQ:  %0d", beq_count);
        $display(" ADDI: %0d", addi_count);
        
        if (ld_count > 0 && sd_count > 0 && add_count > 0 && sub_count > 0 && 
            and_count > 0 && or_count > 0 && beq_count > 0 && addi_count > 0) begin
            $display("");
            $display("SUCCESS: All instruction types executed!");
        end else begin
            $display("");
            $display("FAILURE: Not all instruction types executed!");
        end
        
        // Verify Fibonacci sequence in memory
        $display("");
        $display("=== FIBONACCI SEQUENCE IN MEMORY ===");
        
        // Initialize expected Fibonacci sequence
        expected_fib[1] = 1;
        expected_fib[2] = 1;
        expected_fib[3] = 2;
        expected_fib[4] = 3;
        expected_fib[5] = 5;
        expected_fib[6] = 8;
        expected_fib[7] = 13;
        expected_fib[8] = 21;
        expected_fib[9] = 34;
        
        // Check memory values against expected Fibonacci sequence
        correct_count = 0;
        for (i = 1; i <= 9; i = i + 1) begin
            mem_addr = i + 1; // Offset: Fib(1) at addr 2, Fib(2) at addr 3, etc.
            mem_value = cpu.data_mem_inst.memory_array[mem_addr];
            if (mem_value == expected_fib[i]) begin
                $display(" Fib(%0d) = %0d [CORRECT]", i, mem_value);
                correct_count = correct_count + 1;
            end else begin
                $display(" Fib(%0d) = %0d [ERROR - expected %0d]", i, mem_value, expected_fib[i]);
            end
        end
        
        $display("");
        if (correct_count == 9) begin
            $display("Verification: %0d/9 correct values", correct_count);
            $display("SUCCESS: Fibonacci calculation is CORRECT!");
        end else begin
            $display("Verification: %0d/9 correct values", correct_count);
            $display("FAILURE: Fibonacci calculation has errors");
        end
        
        $finish;
    end

endmodule
