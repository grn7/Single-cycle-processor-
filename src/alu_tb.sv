module tb_alu;

    logic [63:0] a, b;
    logic [2:0]  alu_control;
    logic [63:0] result;
    logic        zero;

    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu_wave.vcd");
        $dumpvars(0, tb_alu);

        $display("Testing ALU with inputs a, b...");

        // ADD
        a = 64'd10;
        b = 64'd5;
        alu_control = 3'b000;
        #10;
        $display("ADD: a + b = %d (Expected: 15)", result);

        // SUB (zero case)
        a = 64'd20;
        b = 64'd20;
        alu_control = 3'b001;
        #10;
        $display("SUB: a - b = %d (Expected: 0), Zero = %b", result, zero);

        // AND
        a = 64'hF0F0F0F0F0F0F0F0;
        b = 64'h0F0F0F0F0F0F0F0F;
        alu_control = 3'b010;
        #10;
        $display("AND: result = 0x%h (Expected: 0)", result);

        // OR
        alu_control = 3'b011;
        #10;
        $display("OR: result = 0x%h (Expected: FFFFFFFFFFFFFFFF)", result);

        // Unknown opcode
        alu_control = 3'b100;
        #10;
        $display("Unknown ALU op: result = 0x%h (Expected: 0)", result);

        $display("ALU testing completed.");
        $finish;
    end
endmodule
