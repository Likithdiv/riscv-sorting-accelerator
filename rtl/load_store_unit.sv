module load_store_unit(address,funct3,mem_read,mem_write,store_data,
                       memory_read_data,load_data,memory_write_data,
                       byte_enable,misaligned);

input logic [31:0] address, store_data, memory_read_data;
input logic [2:0] funct3;
input logic mem_read, mem_write;
output logic [31:0] load_data, memory_write_data;
output logic [3:0] byte_enable;
output logic misaligned;

logic [31:0] shifted_data;
logic [4:0] shift_amount;

always_comb begin
    shift_amount = {address[1:0],3'b000};
    shifted_data = memory_read_data >> shift_amount;
    memory_write_data = store_data << shift_amount;
    load_data = 32'd0;
    byte_enable = 4'b0000;
    misaligned = 1'b0;

    if(mem_read || mem_write) begin
        case(funct3[1:0])
            2'b00: byte_enable = 4'b0001 << address[1:0];
            2'b01: begin
                byte_enable = 4'b0011 << address[1:0];
                misaligned = address[0];
            end
            2'b10: begin
                byte_enable = 4'b1111;
                misaligned = (address[1:0] != 2'b00);
            end
            default: misaligned = 1'b1;
        endcase
    end

    case(funct3)
        3'b000: load_data = {{24{shifted_data[7]}},shifted_data[7:0]}; // LB
        3'b001: load_data = {{16{shifted_data[15]}},shifted_data[15:0]}; // LH
        3'b010: load_data = shifted_data; // LW
        3'b100: load_data = {24'd0,shifted_data[7:0]}; // LBU
        3'b101: load_data = {16'd0,shifted_data[15:0]}; // LHU
        default: load_data = 32'd0;
    endcase
end

endmodule: load_store_unit
