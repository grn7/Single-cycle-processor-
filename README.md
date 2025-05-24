# RISC - V Single Cycle Processor

First project on System Architectures using System Verilogs.

```py
src/      
│---- datapath.sv           # Main datapath implementation
│---- control_unit.sv       # Control unit implementation
│---- alu.sv                # ALU implementation
│---- reg_file.sv           # Register file
│---- memory_unit.sv        # Instruction and data memory
│---- sign_extend.sv        # Sign extension unit
│---- pc_logic.sv           # Program counter logic
│---- single_cycle_cpu.sv   # Top-level module
└── includes/
    └── definitions.sv        # Common definitions

tests/
├── unit_tests/              # Individual module tests
│   ├── alu_tb.sv
│   ├── reg_file_tb.sv
│   └── ... more stuff if you need ( dot products, etc if we extend to vector later )
├── integration_tests/       # Tests for module combinations
├── system_tests/            # Full CPU tests
│   ├── add_test.sv
│   ├── beq_test.sv
│   └── ...
└── test_programs/           # Assembly test programs
    ├── fibonacci.asm
    ├── factorial.asm
    └── ...
```

