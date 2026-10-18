module immediate_generator(instruction,immediate);

input logic [31:0] instruction;
output logic [31:0] immediate;

always_comb begin
case(instruction[6:0])
    7'b0010011, 7'b0000011, 7'b1100111:
        immediate = {{20{instruction[31]}},instruction[31:20]}; // I
    7'b0100011:
        immediate = {{20{instruction[31]}},instruction[31:25],instruction[11:7]}; // S
    7'b1100011:
        immediate = {{19{instruction[31]}},instruction[31],instruction[7],
                     instruction[30:25],instruction[11:8],1'b0}; // B
    7'b0110111, 7'b0010111:
        immediate = {instruction[31:12],12'd0}; // U
    7'b1101111:
        immediate = {{11{instruction[31]}},instruction[31],instruction[19:12],
                     instruction[20],instruction[30:21],1'b0}; // J
    default: immediate = 32'd0;
endcase
end

endmodule: immediate_generator
