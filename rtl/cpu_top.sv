module cpu_top(clk,rst,halted,trap,pc_value,instruction);

parameter integer IMEM_WORDS = 256;
parameter integer DMEM_WORDS = 256;
parameter IMEM_FILE = "programs/demo.hex";
localparam logic [31:0] SORT_BASE = 32'h10000000;

input logic clk, rst;
output logic halted, trap;
output logic [31:0] pc_value, instruction;

typedef struct packed {
    logic valid;
    logic [31:0] pc;
    logic [31:0] instruction;
    logic fetch_fault;
} if_id_t;

typedef struct packed {
    logic valid;
    logic [31:0] pc;
    logic [31:0] immediate;
    logic [31:0] operand1, operand2;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [3:0] alu_op;
    logic [1:0] writeback_sel;
    logic reg_write, mem_read, mem_write;
    logic alu_src_imm, alu_src_pc, lui;
    logic branch, jal, jalr;
    logic fault, system_stop;
} id_ex_t;

typedef struct packed {
    logic valid;
    logic [31:0] pc;
    logic [31:0] alu_result;
    logic [31:0] store_data;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [1:0] writeback_sel;
    logic reg_write, mem_read, mem_write;
    logic stop, fault;
} ex_mem_t;

typedef struct packed {
    logic valid;
    logic [31:0] pc;
    logic [31:0] result;
    logic [4:0] rd;
    logic reg_write;
    logic stop, fault;
} mem_wb_t;

if_id_t if_id, fetched;
id_ex_t id_ex, decoded;
ex_mem_t ex_mem, executed;
mem_wb_t mem_wb, memory_result;

logic [31:0] next_pc, sequential_pc;
logic pc_en, instruction_fault, stopping;
logic [31:0] read_data1, read_data2, immediate;
logic reg_write, mem_read, mem_write, alu_src_imm, alu_src_pc;
logic lui, branch, jal, jalr, illegal, system_stop;
logic [3:0] alu_op;
logic [1:0] writeback_sel;
logic uses_rs1, uses_rs2, load_stall;
logic [31:0] forwarded_a, forwarded_b, alu_a, alu_b, alu_result;
logic [31:0] ex_mem_forward_data, branch_target;
logic branch_taken, control_taken, control_misaligned, execute_fault, redirect;
logic [31:0] memory_read_data, memory_write_data, load_data;
logic [3:0] byte_enable;
logic misaligned, data_fault, memory_fault, memory_stop;
logic register_we, memory_we;
logic sort_select, sort_read, sort_write, sort_fault;
logic ram_fault;
logic [31:0] ram_read_data, sort_read_data;

// IF
pc pc1(.clk(clk),.rst(rst),.en(pc_en),.next_pc(next_pc),.current_pc(pc_value));

instruction_memory #(.WORDS(IMEM_WORDS),.INIT_FILE(IMEM_FILE)) imem(
    .address(pc_value),.instruction(instruction),.access_fault(instruction_fault));

assign sequential_pc = pc_value + 32'd4;

always_comb begin
    fetched = '0;
    fetched.valid = 1'b1;
    fetched.pc = pc_value;
    fetched.instruction = instruction;
    fetched.fetch_fault = instruction_fault;
end

// ID
 decoder decoder1(.instruction(if_id.instruction),.reg_write(reg_write),
    .mem_read(mem_read),.mem_write(mem_write),.alu_src_imm(alu_src_imm),
    .alu_src_pc(alu_src_pc),.lui(lui),.branch(branch),.jal(jal),.jalr(jalr),
    .alu_op(alu_op),.writeback_sel(writeback_sel),.illegal(illegal),
    .system_stop(system_stop));

reg_file rf(.clk(clk),.we(register_we),.rs1(if_id.instruction[19:15]),
    .rs2(if_id.instruction[24:20]),.rd(mem_wb.rd),.write_data(mem_wb.result),
    .read_data1(read_data1),.read_data2(read_data2));

immediate_generator immediate1(.instruction(if_id.instruction),.immediate(immediate));

always_comb begin
    uses_rs1 = 1'b0;
    uses_rs2 = 1'b0;
    case(if_id.instruction[6:0])
        7'b0110011, 7'b0100011, 7'b1100011: begin
            uses_rs1 = 1'b1;
            uses_rs2 = 1'b1;
        end
        7'b0010011, 7'b0000011, 7'b1100111: uses_rs1 = 1'b1;
        default: begin end
    endcase
end

assign load_stall = if_id.valid && id_ex.valid && id_ex.mem_read &&
                    (id_ex.rd != 5'd0) &&
                    ((uses_rs1 && id_ex.rd == if_id.instruction[19:15]) ||
                     (uses_rs2 && id_ex.rd == if_id.instruction[24:20]));

always_comb begin
    decoded = '0;
    decoded.valid = if_id.valid;
    decoded.pc = if_id.pc;
    decoded.immediate = immediate;
    decoded.rs1 = if_id.instruction[19:15];
    decoded.rs2 = if_id.instruction[24:20];
    decoded.rd = if_id.instruction[11:7];
    decoded.funct3 = if_id.instruction[14:12];
    decoded.operand1 = read_data1;
    decoded.operand2 = read_data2;

    // A WB write and an ID read can happen on the same rising edge.
    if(register_we && mem_wb.rd == if_id.instruction[19:15])
        decoded.operand1 = mem_wb.result;
    if(register_we && mem_wb.rd == if_id.instruction[24:20])
        decoded.operand2 = mem_wb.result;

    decoded.alu_op = alu_op;
    decoded.writeback_sel = writeback_sel;
    decoded.reg_write = reg_write;
    decoded.mem_read = mem_read;
    decoded.mem_write = mem_write;
    decoded.alu_src_imm = alu_src_imm;
    decoded.alu_src_pc = alu_src_pc;
    decoded.lui = lui;
    decoded.branch = branch;
    decoded.jal = jal;
    decoded.jalr = jalr;
    decoded.fault = if_id.fetch_fault || illegal;
    decoded.system_stop = system_stop;
end

// EX
assign ex_mem_forward_data = (ex_mem.writeback_sel == 2'b10) ?
                             ex_mem.pc + 32'd4 : ex_mem.alu_result;

always_comb begin
    forwarded_a = id_ex.operand1;
    forwarded_b = id_ex.operand2;

    if(mem_wb.valid && mem_wb.reg_write && !mem_wb.stop && mem_wb.rd != 5'd0) begin
        if(mem_wb.rd == id_ex.rs1) forwarded_a = mem_wb.result;
        if(mem_wb.rd == id_ex.rs2) forwarded_b = mem_wb.result;
    end

    // The newer EX/MEM result wins over MEM/WB. Loads need the stall above.
    if(ex_mem.valid && ex_mem.reg_write && !ex_mem.mem_read &&
       !ex_mem.stop && ex_mem.rd != 5'd0) begin
        if(ex_mem.rd == id_ex.rs1) forwarded_a = ex_mem_forward_data;
        if(ex_mem.rd == id_ex.rs2) forwarded_b = ex_mem_forward_data;
    end
end

assign alu_a = id_ex.lui ? 32'd0 : (id_ex.alu_src_pc ? id_ex.pc : forwarded_a);
assign alu_b = id_ex.alu_src_imm ? id_ex.immediate : forwarded_b;

alu alu1(.a(alu_a),.b(alu_b),.opcode(id_ex.alu_op),.result(alu_result));
branch_unit branch1(.a(forwarded_a),.b(forwarded_b),
    .funct3(id_ex.funct3),.taken(branch_taken));

assign control_taken = id_ex.jal || id_ex.jalr || (id_ex.branch && branch_taken);
assign branch_target = id_ex.jalr ? (alu_result & 32'hFFFFFFFE) :
                                   (id_ex.pc + id_ex.immediate);
assign control_misaligned = control_taken && (branch_target[1:0] != 2'b00);
assign execute_fault = id_ex.fault || control_misaligned;
assign redirect = id_ex.valid && control_taken && !execute_fault && !id_ex.system_stop;

always_comb begin
    executed = '0;
    executed.valid = id_ex.valid;
    executed.pc = id_ex.pc;
    executed.alu_result = alu_result;
    executed.store_data = forwarded_b;
    executed.rd = id_ex.rd;
    executed.funct3 = id_ex.funct3;
    executed.writeback_sel = id_ex.writeback_sel;
    executed.fault = execute_fault;
    executed.stop = execute_fault || id_ex.system_stop;
    executed.reg_write = id_ex.reg_write && !executed.stop;
    executed.mem_read = id_ex.mem_read && !executed.stop;
    executed.mem_write = id_ex.mem_write && !executed.stop;
end

// MEM
load_store_unit lsu(.address(ex_mem.alu_result),.funct3(ex_mem.funct3),
    .mem_read(ex_mem.mem_read),.mem_write(ex_mem.mem_write),
    .store_data(ex_mem.store_data),.memory_read_data(memory_read_data),
    .load_data(load_data),.memory_write_data(memory_write_data),
    .byte_enable(byte_enable),.misaligned(misaligned));

data_memory #(.WORDS(DMEM_WORDS)) dmem(.clk(clk),.we(memory_we && !sort_select),
    .address(ex_mem.alu_result),.write_data(memory_write_data),
    .byte_enable(byte_enable),.read_data(ram_read_data),.access_fault(ram_fault));

// MMIO requests are issued only by valid, nonfaulting MEM instructions.
// Fault checking uses the request; the peripheral gates its own writes on it.
assign sort_select = (ex_mem.alu_result[31:9] == SORT_BASE[31:9]);
assign sort_read = !rst && !halted && !stopping && ex_mem.valid &&
                   !ex_mem.stop && !ex_mem.fault && ex_mem.mem_read && sort_select;
assign sort_write = !rst && !halted && !stopping && ex_mem.valid &&
                    !ex_mem.stop && !ex_mem.fault && ex_mem.mem_write && sort_select;

sort_engine sorter(.clk(clk),.rst(rst),.read_en(sort_read),.write_en(sort_write),
    .address(ex_mem.alu_result[8:0]),.funct3(ex_mem.funct3),
    .write_data(ex_mem.store_data),.read_data(sort_read_data),.access_fault(sort_fault));

assign memory_read_data = sort_select ? sort_read_data : ram_read_data;
assign data_fault = sort_select ? sort_fault : ram_fault;

assign memory_fault = ex_mem.fault ||
                      ((ex_mem.mem_read || ex_mem.mem_write) && (misaligned || data_fault));
assign memory_stop = ex_mem.valid && (ex_mem.stop || memory_fault);
assign memory_we = !rst && !halted && !stopping && ex_mem.valid &&
                   ex_mem.mem_write && !memory_stop;

always_comb begin
    memory_result = '0;
    memory_result.valid = ex_mem.valid && !stopping;
    memory_result.pc = ex_mem.pc;
    memory_result.rd = ex_mem.rd;
    memory_result.stop = ex_mem.stop || memory_fault;
    memory_result.fault = memory_fault;
    memory_result.reg_write = ex_mem.reg_write && !memory_result.stop;
    case(ex_mem.writeback_sel)
        2'b00: memory_result.result = ex_mem.alu_result;
        2'b01: memory_result.result = load_data;
        2'b10: memory_result.result = ex_mem.pc + 32'd4;
        default: memory_result.result = 32'd0;
    endcase
end

// WB
assign register_we = !rst && !halted && mem_wb.valid && mem_wb.reg_write &&
                     !mem_wb.stop && (mem_wb.rd != 5'd0);

// An older MEM stop takes priority over a younger EX redirect or ID stall.
assign pc_en = !rst && !halted && !stopping &&
               (memory_stop || redirect || !load_stall);
assign next_pc = memory_stop ? ex_mem.pc : (redirect ? branch_target : sequential_pc);

always_ff @(posedge clk) begin
    if(rst) begin
        if_id <= '0;
        id_ex <= '0;
        ex_mem <= '0;
        mem_wb <= '0;
        stopping <= 1'b0;
        halted <= 1'b0;
        trap <= 1'b0;
    end
    else if(!halted) begin
        if(mem_wb.valid && mem_wb.stop) begin
            halted <= 1'b1;
            trap <= mem_wb.fault;
            if_id <= '0;
            id_ex <= '0;
            ex_mem <= '0;
            mem_wb <= '0;
        end
        else begin
            mem_wb <= memory_result;
            if(memory_stop || stopping) begin
                stopping <= 1'b1;
                if_id <= '0;
                id_ex <= '0;
                ex_mem <= '0;
            end
            else begin
                ex_mem <= executed;
                if(redirect) begin
                    if_id <= '0;
                    id_ex <= '0;
                end
                else if(load_stall) begin
                    id_ex <= '0;
                end
                else begin
                    if_id <= fetched;
                    id_ex <= decoded;
                end
            end
        end
    end
end

endmodule: cpu_top
