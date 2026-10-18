module sort_engine(clk,rst,read_en,write_en,address,funct3,write_data,
                   read_data,access_fault);

input logic clk, rst, read_en, write_en;
input logic [8:0] address;
input logic [2:0] funct3;
input logic [31:0] write_data;
output logic [31:0] read_data;
output logic access_fault;


logic signed [31:0] buffer [0:63];
logic [63:0] loaded;
logic busy, done;
logic [5:0] phase;
logic [31:0] sort_cycles;
logic data_address;
logic [5:0] index;
integer pair;

assign data_address = address[8];
assign index = address[7:2];

always_comb begin
    read_data = 32'd0;
    access_fault = 1'b0;

    if(read_en || write_en) begin
        if(address[1:0] != 2'b00 || funct3 != 3'b010 || (read_en && write_en))
            access_fault = 1'b1;
        else if(data_address) begin
            if(busy || (read_en && !loaded[index]))
                access_fault = 1'b1;
            else if(read_en)
                read_data = buffer[index];
        end
        else begin
            case(address)
                9'h000: begin
                    if(write_en && (busy || write_data > 32'd2 ||
                       (write_data == 32'd1 && !(&loaded))))
                        access_fault = 1'b1;
                end
                9'h004: begin
                    read_data = {29'd0,(&loaded),done,busy};
                    if(write_en) access_fault = 1'b1;
                end
                9'h008: begin
                    read_data = sort_cycles;
                    if(write_en) access_fault = 1'b1;
                end
                default: access_fault = 1'b1;
            endcase
        end
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        loaded <= 64'd0;
        busy <= 1'b0;
        done <= 1'b0;
        phase <= 6'd0;
        sort_cycles <= 32'd0;
    end
    else if(busy) begin
        
        if(!phase[0]) begin
            for(pair = 0; pair < 32; pair = pair+1) begin
                if($signed(buffer[2*pair]) > $signed(buffer[2*pair+1])) begin
                    buffer[2*pair] <= buffer[2*pair+1];
                    buffer[2*pair+1] <= buffer[2*pair];
                end
            end
        end
        else begin
            for(pair = 0; pair < 31; pair = pair+1) begin
                if($signed(buffer[2*pair+1]) > $signed(buffer[2*pair+2])) begin
                    buffer[2*pair+1] <= buffer[2*pair+2];
                    buffer[2*pair+2] <= buffer[2*pair+1];
                end
            end
        end

        sort_cycles <= sort_cycles+32'd1;
        if(phase == 6'd63) begin
            busy <= 1'b0;
            done <= 1'b1;
        end
        else
            phase <= phase+6'd1;
    end
    else if(write_en && !access_fault) begin
        if(data_address) begin
            buffer[index] <= write_data;
            loaded[index] <= 1'b1;
            done <= 1'b0;
        end
        else if(address == 9'h000) begin
            if(write_data == 32'd1) begin
                busy <= 1'b1;
                done <= 1'b0;
                phase <= 6'd0;
                sort_cycles <= 32'd0;
            end
            else if(write_data == 32'd2)
                done <= 1'b0;
        end
    end
end

endmodule: sort_engine
