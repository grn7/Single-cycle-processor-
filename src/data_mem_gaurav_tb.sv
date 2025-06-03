module tb_data_mem;

    logic clk;
    logic rst;
    logic[31:0] addr;
    logic[63:0] wr_data;
    logic wr_enable;
    logic rd_enable;
    logic[63:0] rd_data;

    localparam mem_size=256;
    localparam rom_size=16;

    initial begin
        $dumpfile("wave.vcd"); //for gtkwave
        $dumpvars(0,tb_data_mem);

        int fd;
        fd=$fopen("test_data.mem","w");
        if(fd) begin
            $fdisplay(fd,"0000000000000001"); //constants
            $fdisplay(fd,"0000000000000002");
            $fdisplay(fd,"000000000000000A");
            $fdisplay(fd,"0000000000000064");
            $fdisplay(fd,"00000000000ALPHA");
            $fdisplay(fd,"BETA000000000000");
            $fdisplay(fd,"1234567890ABCDEF");
            $fdisplay(fd,"FEDCBA9876543210");
            $fclose(fd);
            $display("File created for ROM region \n");
        end
        else begin
            $error("Could not create file for ROM region \n");
        end
    end

    //instantiate module
    data_mem #(
        .mem_size(mem_size),
        .rom_size(rom_size),
        .rom_file("test_data.mem")
    ) dut(
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .wr_data(wr_data),
        .wr_enable(wr_enable),
        .rd_enable(rd_enable),
        .rd_data(rd_data)
    );

    always #5 clk = ~clk; //time period 10 units

    intial begin
        $display("Starting data memory testbench");

        clk=0;
        rst=1;
        addr=0;
        wr_data=0;
        wr_enable=0;
        rd_enable=0;

        #20;
        rst=0;
        #10;

        $display("Testing ROM region loaded from .mem file \n");
        //read from rom region
        rd_enable=1;
        addr=32'h00000000; 
        #10;
        $display("ROM address 0x%h: Read data = 0x%h (expected 0x1) \n",addr,rd_data);
        if(rd_data!==64'h0000000000000001) begin
            $error("ROM data at address 0 incorrect \n");
        end

        addr=32'h00000008; //address 8 (2nd 64-bit word)
        #10;
        $display("ROM address 0x%h: Read data = 0x%h (expected 0x2) \n",addr,rd_data);
        if(rd_data!==64'h0000000000000002) begin
            $error("ROM data at address 8 incorrect \n");
        end

        $display("Testing write protection for ROM region \n");
        //trying to write to rom region(shouldn't be allowed )
        addr=32'h00000000;
        wr_data=64'hFFFFFFFF;
        wr_enable=1;
        rd_enable=0;
        #10; //waiting for clock edge
        //read to check if write was ignored
        wr_enable=0;
        rd_enable=1;
        #10;
        $display("After write attempt to ROM, Address 0x%h: Read data=0x%h(should be 0000000000000001) \n",addr,rd_data);
        if(rd_data!==64'h0000000000000001) begin
            $error("ROM write protection failed \n");
        end

        $display("Testing RAM region \n");

        //writing to ram region
        addr=32'h00000080 //address 128 
        wr_data=64'h123456789ABCDEF0;
        wr_enable=1;
        rd_enable=0;
        #10;

        //read back from ram region
        wr_enable=0;
        rd_enable=1;
        #10;
        $display("RAM address 0x%h: Read data = 0x%h (supposed to be 0x123456789ABCDEF0) \n",addr,rd_data);
        if(rd_data!==64'h123456789ABCDEF0) begin
            $error("RAM write/read failed \n");
        end

        //test reset
        $display("Testing reset functionality \n");

        rst=1;
        #20;
        rst=0;
        #10;

        //read from rom region after reset ; should be unchanged 
        addr=32'h00000000;
        rd_enable=1;
        #10;
        $display("After reset, ROM address 0x%h: Read data = 0x%h (supposed to be 0x0000000000000001) \n",addr,rd_data);
        if(rd_data!==64'h0000000000000001) begin
            $error("ROM data not preserved after reset \n");
        end

        //read from ram region after reset
        addr=32'h00000080;
        #10;
        $display("After reset, RAM address 0x%h : Read data=0x%h (should be 0) \n",addr,rd_data);
        if(rd_data!==64'h0000000000000000) begin
            $error("RAM data should be cleared after reset \n");
        end

        $display("Testing read enable control \n");
        //test raeding with read enable as 0
        addr=32'h00000000 
        rd_enable=0;
        #10;
        $display("Read with read enable = 0: 0x%h (supposed to be 0) \n",rd_data);
        if(rd_data!==64'h0000000000000000) begin
            $error("Read enable functioning incorrectly \n");
        end

        $display("Data memory testbench completed \n");
        $finish;
    end

endmodule