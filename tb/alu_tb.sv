module alu_tb();

 logic [31:0] a, b;
 logic [3:0] opcode;
 logic [31:0] result;

alu alu1(.a(a), .b(b), .opcode(opcode),
 .result(result));

initial begin
opcode = 4'b0000;
a = 32'd7;
b = 32'd5;
#1;
if(result !== 32'd12) $display("Error: ADD operation failed");

opcode = 4'b0001;
a = 32'd5;
b = 32'd7;
#1;
if(result !== 32'hFFFFFFFE) $display("Error: SUB operation failed");

opcode = 4'b0010;
a = 32'h000000AA;
b = 32'h000000CC;
#1;
if(result !== 32'h00000088) $display("Error: AND operation failed");

opcode = 4'b0011;
a = 32'h000000AA;
b = 32'h000000CC;
#1;
if(result !== 32'h000000EE) $display("Error: OR operation failed");

opcode = 4'b0100;
a = 32'h000000AA;
b = 32'h000000CC;
#1;
if(result !== 32'h00000066) $display("Error: XOR operation failed");

opcode = 4'b0101;
a = 32'd1;
b = 32'd3;
#1;
if(result !== 32'd8) $display("Error: SLL operation failed");

opcode = 4'b0110;
a = 32'h80000000;
b = 32'd1;
#1;
if(result !== 32'h40000000) $display("Error: SRL operation failed");

opcode = 4'b0111;
a = 32'h80000000;
b = 32'd1;
#1;
if(result !== 32'hC0000000) $display("Error: SRA operation failed");

opcode = 4'b1000;
a = 32'hFFFFFFFF;
b = 32'd1;
#1;
if(result !== 32'd1) $display("Error: SLT operation failed");

opcode = 4'b1001;
a = 32'hFFFFFFFF;
b = 32'd1;
#1;
if(result !== 32'd0) $display("Error: SLTU operation failed");

end

endmodule: alu_tb