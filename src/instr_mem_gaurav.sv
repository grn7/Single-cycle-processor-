module instr_mem #(
    parameter mem_size = 256,  //no of instruction words
    parameter mem_file = "program.mem"  
) (
    input  logic [31:0] address,     //address of instruction to read (byte address)
    output logic [31:0] instruction  //instruction at that address
);

    logic [31:0] memory [mem_size-1:0];

    initial begin
        //initialize all memory to NOP instructions first
        for (int i = 0; i < mem_size; i++) begin
            memory[i] = 32'h00000013; 
        end
        
        //load instructions from the .mem file
        $readmemh(mem_file, memory);
        
    end
    
    //asynchronous read 
    //convert byte address to word address by dividing by 4 
    assign instruction = memory[address[31:2]];

endmodule
