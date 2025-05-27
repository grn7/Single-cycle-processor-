module reg_file(
    input logic clk,
    input logic rst,
    input logic[4:0] rd_addr1,
    output logic[63:0] rd_data1,
    input logic[4:0] rd_addr2,
    output logic[63:0] rd_data2,
    input logic[4:0] wr_addr,
    input logic[63:0] wr_data,
    input logic wr_enable,

    output logic[63:0] debug_output //reg 31 which is connected to output pins
);
logic [63:0] registers[31:0];

always_ff@(posedge clk or posedge rst) begin
    if(rst) begin
        for(int i=0;i<32;i++) begin
            registers[i]<=64'b0;
        end
    end
    else if(wr_enable) begin
        registers[wr_addr]<=wr_data;
    end
end

assign rd_data1=registers[rd_addr1];
assign rd_data2=registers[rd_addr2];

assign debug_output=registers[31];

endmodule