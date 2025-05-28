module tb_reg_file;
    logic clk;
    logic rst;
    logic[4:0] rd_addr1;
    logic[63:0] rd_data1;
    logic[4:0] rd_addr2;
    logic[63:0] rd_data2;
    logic[4:0] wr_addr;
    logic[63:0] wr_data;
    logic wr_enable;
    logic[63:0] debug_output;

    //instantiate module
    reg_file dut(
        .clk(clk),
        .rst(rst),
        .rd_addr1(rd_addr1),
        .rd_data1(rd_data1),
        .rd_addr2(rd_addr2),
        .rd_data2(rd_data2),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wr_enable(wr_enable),
        .debug_output(debug_output)
    );

    //clock
    always #5 clk=~clk; //time period is 10

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0,tb_reg_file);
        
        $display("Test register file \n");
        clk=0;
        rst=1; //apply reset
        rd_addr1=0;
        rd_addr2=0;
        wr_addr=0;
        wr_data=0;
        wr_enable=0;

        #20;
        rst=0;
        #10;

        $display("Checking initial state after reset \n");
        rd_addr1=5'b0; //register 0 and 1
        rd_addr2=5'b1;

        #10;
        $display("Register 0 = 0x%h (supposed to be 0) \n",rd_data1);
        $display("Register 1 = 0x%h (supposed to be 0) \n",rd_data2);

        $display("Checking write \n");
        //lets write to register 5
        wr_addr=5'b00101;
        wr_data=64'h0123456789ABCDEF;
        wr_enable=1;
        #10 //waiting for clock edge
        wr_enable=0;

        //let us now read from reg 5
        rd_addr1=5'b00101;
        #10
        $display("Value in register 5 : 0x%h(supposed to be 0123456789ABCDEF) \n",rd_data1);

        $display("Testing write and read from multiple registers \n");
        wr_addr=5'b01010; //reg 10
        wr_data=64'h1234123412341234;
        wr_enable=1;
        #10;
        wr_enable=0;

        wr_addr=5'b01111; //reg 15
        wr_data=64'h5678567856785678;
        wr_enable=1;
        #10;
        wr_enable=0;

        $display("Reading from 2 registers simultaneously \n");
        rd_addr1=5'b01010;
        rd_addr2=5'b01111;
        #10;
        $display("Register 10 (supposed to be 1234123412341234): 0x%h \n",rd_data1);
        $display("Register 15 (supposed to be 5678567856785678): 0x%h \n",rd_data2);

        $display("Let us try to write without write enable being 1 \n");
        wr_addr=5'b1;
        wr_data=64'h1111111111111111;
        wr_enable=0;
        #10;
        rd_addr1=5'b1;
        #10;
        $display("Register 1 value: 0x%h (supposed to be 0) \n",rd_data1);
        $display("Test completed\n");
        $finish;
    end
endmodule
