module data_memory(clk,we,address,write_data,byte_enable,read_data,access_fault);

parameter integer WORDS = 256;

input logic clk, we;
input logic [31:0] address, write_data;
input logic [3:0] byte_enable;
output logic [31:0] read_data;
output logic access_fault;

logic [31:0] memory [0:WORDS-1];
integer lane;

always_comb begin
    access_fault = ((address >> 2) >= WORDS);
    read_data = 32'd0;
    if(!access_fault)
        read_data = memory[address >> 2];
end

always_ff @(posedge clk) begin
    if(we && !access_fault) begin
        for(lane = 0; lane < 4; lane = lane+1)
            if(byte_enable[lane])
                memory[address >> 2][lane*8 +: 8] <= write_data[lane*8 +: 8];
    end
end

endmodule: data_memory
