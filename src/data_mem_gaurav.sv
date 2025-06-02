module data_mem #(
    parameter mem_size=256, //size in terms of 64 bit words
    parameter rom_size=16,
    parameter rom_file="data.mem" //file to initialize rom
)(
    input logic clk,
    input logic rst,
    input logic[31:0] addr, //byte address
    input logic[63:0] wr_data,
    input logic wr_enable,
    input logic rd_enable,
    output logic[63:0] rd_data
);

logic[63:0] memory[mem_size-1:0]; //data memory

//convert byte address to word address 
logic[31:0] word_addr=addr[31:3];

initial begin
    for(int i=0;i<mem_size;i++) begin
        memory[i]=64'b0;
    end
    //load rom region into data memory
    $readmemh(rom_file,memory,0,rom_size-1);
end

always_ff@(posedge clk or posedge rst) begin
    if(rst) begin
        for(int i=rom_size;i<mem_size;i++) begin //only reset ram portion
            memory[i]<=64'b0;
        end
    end
    else if(wr_enable) begin
        //only allow writing to ram region
        if(word_addr>=rom_size) begin
            memory[word_addr]<=wr_data;
        end
        else begin
            $display("Attempt to write to ROM region");
        end
    end
end

always_comb begin 
    if(rd_enable) begin
        rd_data=memory[word_addr];
    end
    else begin
        //if read not enabled output 0
        rd_data=64'b0;
    end
end

endmodule