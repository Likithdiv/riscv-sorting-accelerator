module alu(a,b,opcode,result);

input logic [31:0] a, b;
input logic [3:0] opcode;
output logic [31:0] result;


always_comb begin
case(opcode)
    4'b0000: result = a+b;
    4'b0001: result = a-b;
    4'b0010: result = a&b;
    4'b0011: result = a|b;
    4'b0100: result = a^b;
    4'b0101: result = a<<b[4:0];//SLL
    4'b0110: result = a>>b[4:0];//SRL
    4'b0111: result = $signed(a)>>>b[4:0];//SRA
    4'b1000: result = ($signed(a)<$signed(b))? 1'b1 : 1'b0;//SLT
    4'b1001: result = ($unsigned(a)<$unsigned(b))? 1'b1 : 1'b0;//SLTU
    default: result = 32'b0;
endcase
end




endmodule: alu