module pc(clk,rst,en,next_pc,current_pc);

parameter logic [31:0] RESET_PC = 32'd0;

input logic clk, rst, en;
input logic [31:0] next_pc;
output logic [31:0] current_pc;

always_ff @(posedge clk) begin
    if(rst)
        current_pc <= RESET_PC;
    else if(en)
        current_pc <= next_pc;
end

endmodule: pc
