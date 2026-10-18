module decoder(instruction,reg_write,mem_read,mem_write,alu_src_imm,
               alu_src_pc,lui,branch,jal,jalr,alu_op,writeback_sel,
               illegal,system_stop);

input logic [31:0] instruction;
output logic reg_write, mem_read, mem_write, alu_src_imm;
output logic alu_src_pc, lui, branch, jal, jalr;
output logic [3:0] alu_op;
output logic [1:0] writeback_sel; 
output logic illegal, system_stop;

logic [2:0] funct3;
logic [6:0] funct7;
assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];

always_comb begin
    reg_write = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    alu_src_imm = 1'b0;
    alu_src_pc = 1'b0;
    lui = 1'b0;
    branch = 1'b0;
    jal = 1'b0;
    jalr = 1'b0;
    alu_op = 4'b0000;
    writeback_sel = 2'b00;
    illegal = 1'b0;
    system_stop = 1'b0;

    case(instruction[6:0])
        7'b0110011: begin
            reg_write = 1'b1;
            case({funct7,funct3})
                10'b0000000_000: alu_op = 4'b0000; // ADD
                10'b0100000_000: alu_op = 4'b0001; // SUB
                10'b0000000_111: alu_op = 4'b0010; // AND
                10'b0000000_110: alu_op = 4'b0011; // OR
                10'b0000000_100: alu_op = 4'b0100; // XOR
                10'b0000000_001: alu_op = 4'b0101; // SLL
                10'b0000000_101: alu_op = 4'b0110; // SRL
                10'b0100000_101: alu_op = 4'b0111; // SRA
                10'b0000000_010: alu_op = 4'b1000; // SLT
                10'b0000000_011: alu_op = 4'b1001; // SLTU
                default: illegal = 1'b1;
            endcase
        end
        7'b0010011: begin // Immediate arithmetic
            reg_write = 1'b1;
            alu_src_imm = 1'b1;
            case(funct3)
                3'b000: alu_op = 4'b0000; // ADDI
                3'b111: alu_op = 4'b0010; // ANDI
                3'b110: alu_op = 4'b0011; // ORI
                3'b100: alu_op = 4'b0100; // XORI
                3'b010: alu_op = 4'b1000; // SLTI
                3'b011: alu_op = 4'b1001; // SLTIU
                3'b001: begin
                    alu_op = 4'b0101; // SLLI
                    if(funct7 != 7'b0000000) illegal = 1'b1;
                end
                3'b101: begin
                    if(funct7 == 7'b0000000) alu_op = 4'b0110; // SRLI
                    else if(funct7 == 7'b0100000) alu_op = 4'b0111; // SRAI
                    else illegal = 1'b1;
                end
                default: illegal = 1'b1;
            endcase
        end
        7'b0000011: begin // LB, LH, LW, LBU, LHU
            reg_write = 1'b1;
            mem_read = 1'b1;
            alu_src_imm = 1'b1;
            writeback_sel = 2'b01;
            case(funct3)
                3'b000,3'b001,3'b010,3'b100,3'b101: begin end
                default: illegal = 1'b1;
            endcase
        end
        7'b0100011: begin // SB, SH, SW
            mem_write = 1'b1;
            alu_src_imm = 1'b1;
            case(funct3)
                3'b000,3'b001,3'b010: begin end
                default: illegal = 1'b1;
            endcase
        end
        7'b1100011: begin
            branch = 1'b1;
            case(funct3)
                3'b000,3'b001,3'b100,3'b101,3'b110,3'b111: begin end
                default: illegal = 1'b1;
            endcase
        end
        7'b1101111: begin // JAL
            jal = 1'b1;
            reg_write = 1'b1;
            writeback_sel = 2'b10;
        end
        7'b1100111: begin // JALR
            jalr = 1'b1;
            reg_write = 1'b1;
            alu_src_imm = 1'b1;
            writeback_sel = 2'b10;
            if(funct3 != 3'b000) illegal = 1'b1;
        end
        7'b0110111: begin 
            lui = 1'b1;
            reg_write = 1'b1;
            alu_src_imm = 1'b1;
        end
        7'b0010111: begin 
            alu_src_pc = 1'b1;
            reg_write = 1'b1;
            alu_src_imm = 1'b1;
        end
        7'b0001111: begin 
            if(funct3 != 3'b000) illegal = 1'b1;
        end
        7'b1110011: begin
            if(instruction == 32'h00000073 || instruction == 32'h00100073)
                system_stop = 1'b1; 
            else illegal = 1'b1;
        end
        default: illegal = 1'b1;
    endcase
end

endmodule: decoder
