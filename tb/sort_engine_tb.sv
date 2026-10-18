`timescale 1ns/1ps

module sort_engine_tb();

logic clk, rst, read_en, write_en;
logic [8:0] address;
logic [2:0] funct3;
logic [31:0] write_data, read_data;
logic access_fault;
integer expected [0:63];
integer test_case, i, j, key, busy_edges;
logic [31:0] seed;

sort_engine dut(.*);

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

always @(posedge clk) begin
    if(rst || !dut.busy) busy_edges <= 0;
    else busy_edges <= busy_edges+1;
end

task automatic write_word(input logic [8:0] offset, input logic [31:0] value,
                          input logic fault_expected, input logic [2:0] size = 3'b010);
    @(negedge clk);
    address = offset;
    write_data = value;
    funct3 = size;
    write_en = 1'b1;
    read_en = 1'b0;
    #1;
    if(access_fault !== fault_expected)
        $fatal(1,"Error: write fault response at offset %h",offset);
    @(negedge clk);
    write_en = 1'b0;
endtask

task automatic read_word(input logic [8:0] offset, input logic [31:0] value,
                         input logic fault_expected, input logic [2:0] size = 3'b010);
    @(negedge clk);
    address = offset;
    funct3 = size;
    read_en = 1'b1;
    write_en = 1'b0;
    #1;
    if(access_fault !== fault_expected)
        $fatal(1,"Error: read fault response at offset %h",offset);
    if(!fault_expected && read_data !== value)
        $fatal(1,"Error: offset %h expected %h got %h",offset,value,read_data);
    @(negedge clk);
    read_en = 1'b0;
endtask

initial begin
    rst = 1'b1;
    read_en = 1'b0;
    write_en = 1'b0;
    address = 9'd0;
    funct3 = 3'b010;
    write_data = 32'd0;
    seed = 32'h1BADF00D;
    #12;
    rst = 1'b0;

    read_word(9'h004,32'd0,1'b0);
    read_word(9'h008,32'd0,1'b0);
    read_word(9'h100,32'd0,1'b1);
    write_word(9'h000,32'd1,1'b1);
    write_word(9'h000,32'd3,1'b1);
    write_word(9'h004,32'd1,1'b1);
    write_word(9'h008,32'd1,1'b1);
    read_word(9'h010,32'd0,1'b1);
    write_word(9'h010,32'd1,1'b1);
    write_word(9'h101,32'd1,1'b1);
    write_word(9'h100,32'd1,1'b1,3'b000);
    read_word(9'h004,32'd0,1'b1,3'b100);
    read_word(9'h004,32'd0,1'b0);

    for(test_case = 0; test_case < 25; test_case = test_case+1) begin
        for(i = 0; i < 64; i = i+1) begin
            seed = seed ^ (seed << 13);
            seed = seed ^ (seed >> 17);
            seed = seed ^ (seed << 5);
            case(test_case)
                0: expected[i] = 63-i;
                1: expected[i] = i-32;
                2: expected[i] = -7;
                3: expected[i] = i[0] ? 32'h80000000 : 32'h7FFFFFFF;
                4: expected[i] = (i % 3)-1;
                default: expected[i] = $signed(seed);
            endcase
            write_word(9'h100+i*4,expected[i],1'b0);
        end

        // Independent insertion-sort reference, not the hardware algorithm.
        for(i = 1; i < 64; i = i+1) begin
            key = expected[i];
            j = i-1;
            while(j >= 0 && expected[j] > key) begin
                expected[j+1] = expected[j];
                j = j-1;
            end
            expected[j+1] = key;
        end

        read_word(9'h004,32'd4,1'b0);
        write_word(9'h000,32'd1,1'b0);
        read_word(9'h004,32'd5,1'b0);
        write_word(9'h000,32'd1,1'b1);
        write_word(9'h100,32'hDEADBEEF,1'b1);
        read_word(9'h100,32'd0,1'b1);
        wait(dut.done === 1'b1);
        #1;
        if(busy_edges != 64) $fatal(1,"Error: sort did not take exactly 64 cycles");
        read_word(9'h004,32'd6,1'b0);
        read_word(9'h008,32'd64,1'b0);
        for(i = 0; i < 64; i = i+1)
            read_word(9'h100+i*4,expected[i],1'b0);
        write_word(9'h000,32'd2,1'b0);
        read_word(9'h004,32'd4,1'b0);
    end

    // Reuse the loaded buffer without loading a new batch.
    write_word(9'h000,32'd1,1'b0);
    wait(dut.done === 1'b1);
    #1;
    for(i = 0; i < 64; i = i+1)
        read_word(9'h100+i*4,expected[i],1'b0);

    // Reset aborts a job and invalidates the old buffer contents.
    write_word(9'h000,32'd1,1'b0);
    repeat(5) @(negedge clk);
    rst = 1'b1;
    @(negedge clk);
    rst = 1'b0;
    read_word(9'h004,32'd0,1'b0);
    read_word(9'h008,32'd0,1'b0);
    read_word(9'h100,32'd0,1'b1);
    write_word(9'h000,32'd1,1'b1);

    $display("All sorting-engine tests passed (25 signed input vectors and MMIO/reset checks)");
    $finish;
end

initial begin
    #300000;
    $fatal(1,"Error: sorting-engine testbench timed out");
end

endmodule: sort_engine_tb
