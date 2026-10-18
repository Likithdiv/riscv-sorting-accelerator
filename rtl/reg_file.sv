module reg_file(clk,we,rs1,rs2,rd,write_data,read_data1,read_data2);

input logic clk, we;
input logic [4:0] rs1, rs2, rd;
input logic [31:0] write_data;
output logic [31:0] read_data1, read_data2;

logic [31:0] registers [0:31];

always_comb begin
    read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];
end

always_ff @(posedge clk) begin
    if(we && rd != 5'd0)
        registers[rd] <= write_data;
end

endmodule: reg_file
