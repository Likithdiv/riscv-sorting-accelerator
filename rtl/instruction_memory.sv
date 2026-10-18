module instruction_memory(address,instruction,access_fault);

parameter integer WORDS = 256;
parameter INIT_FILE = "programs/demo.hex";

input logic [31:0] address;
output logic [31:0] instruction;
output logic access_fault;

logic [31:0] memory [0:WORDS-1];
integer i;

initial begin
    for(i = 0; i < WORDS; i = i+1)
        memory[i] = 32'h00000013; // NOP

    memory[0] = 32'h00700093; // addi x1,x0,7
    memory[1] = 32'h00500113; // addi x2,x0,5
    memory[2] = 32'h002081B3; // add x3,x1,x2
    memory[3] = 32'h00100073; // ebreak
end

always_comb begin
    instruction = 32'h00000013;
    access_fault = (address[1:0] != 2'b00) || ((address >> 2) >= WORDS);
    if(!access_fault)
        instruction = memory[address >> 2];
end

endmodule: instruction_memory
