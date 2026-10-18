`timescale 1ns/1ps

module cpu_tb();

logic clk, rst;
logic halted, trap;
logic [31:0] pc_value, instruction;
integer i;
integer cycles;
integer retired;
integer stall_cycles;
integer redirect_cycles;
logic pipeline_full;

cpu_top #(.IMEM_FILE("")) cpu1(
    .clk(clk),.rst(rst),.halted(halted),.trap(trap),
    .pc_value(pc_value),.instruction(instruction));

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

always @(posedge clk) begin
    if(rst) begin
        cycles <= 0;
        retired <= 0;
        stall_cycles <= 0;
        redirect_cycles <= 0;
        pipeline_full <= 1'b0;
    end
    else if(!halted) begin
        cycles <= cycles+1;
        if(cpu1.mem_wb.valid && !cpu1.mem_wb.stop)
            retired <= retired+1;
        if(!cpu1.stopping && !cpu1.memory_stop && !cpu1.redirect && cpu1.load_stall)
            stall_cycles <= stall_cycles+1;
        if(!cpu1.stopping && !cpu1.memory_stop && cpu1.redirect)
            redirect_cycles <= redirect_cycles+1;
        if(cpu1.if_id.valid && cpu1.id_ex.valid && cpu1.ex_mem.valid && cpu1.mem_wb.valid)
            pipeline_full <= 1'b1;
    end
end

initial begin
    rst = 1'b1;
    #1;

    
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;

    cpu1.imem.memory[0] = 32'h00000093;
    cpu1.imem.memory[1] = 32'h00000113;
    cpu1.imem.memory[2] = 32'h00000193;
    cpu1.imem.memory[3] = 32'h00000213;
    cpu1.imem.memory[4] = 32'h00000293;
    cpu1.imem.memory[5] = 32'h00000313;
    cpu1.imem.memory[6] = 32'h00000393;
    cpu1.imem.memory[7] = 32'h00000413;
    cpu1.imem.memory[8] = 32'h00000493;
    cpu1.imem.memory[9] = 32'h00000513;
    cpu1.imem.memory[10] = 32'h00000593;
    cpu1.imem.memory[11] = 32'h00000613;
    cpu1.imem.memory[12] = 32'h00000693;
    cpu1.imem.memory[13] = 32'h00000713;
    cpu1.imem.memory[14] = 32'h00000793;
    cpu1.imem.memory[15] = 32'h00000813;
    cpu1.imem.memory[16] = 32'h00000893;
    cpu1.imem.memory[17] = 32'h00000913;
    cpu1.imem.memory[18] = 32'h00000993;
    cpu1.imem.memory[19] = 32'h00000A13;
    cpu1.imem.memory[20] = 32'h00000A93;
    cpu1.imem.memory[21] = 32'h00000B13;
    cpu1.imem.memory[22] = 32'h00000B93;
    cpu1.imem.memory[23] = 32'h00000C13;
    cpu1.imem.memory[24] = 32'h00000C93;
    cpu1.imem.memory[25] = 32'h00000D13;
    cpu1.imem.memory[26] = 32'h00000D93;
    cpu1.imem.memory[27] = 32'h00000E13;
    cpu1.imem.memory[28] = 32'h00000E93;
    cpu1.imem.memory[29] = 32'h00000F13;
    cpu1.imem.memory[30] = 32'h00000F93;
    cpu1.imem.memory[31] = 32'h06300013;
    cpu1.imem.memory[32] = 32'h00000193;
    cpu1.imem.memory[33] = 32'h10302023;
    cpu1.imem.memory[34] = 32'h00700093;
    cpu1.imem.memory[35] = 32'h00500113;
    cpu1.imem.memory[36] = 32'h002081B3;
    cpu1.imem.memory[37] = 32'h10302223;
    cpu1.imem.memory[38] = 32'h00500093;
    cpu1.imem.memory[39] = 32'h00700113;
    cpu1.imem.memory[40] = 32'h402081B3;
    cpu1.imem.memory[41] = 32'h10302423;
    cpu1.imem.memory[42] = 32'h0AA00093;
    cpu1.imem.memory[43] = 32'h0CC00113;
    cpu1.imem.memory[44] = 32'h0020F1B3;
    cpu1.imem.memory[45] = 32'h10302623;
    cpu1.imem.memory[46] = 32'h0AA00093;
    cpu1.imem.memory[47] = 32'h0CC00113;
    cpu1.imem.memory[48] = 32'h0020E1B3;
    cpu1.imem.memory[49] = 32'h10302823;
    cpu1.imem.memory[50] = 32'h0AA00093;
    cpu1.imem.memory[51] = 32'h0CC00113;
    cpu1.imem.memory[52] = 32'h0020C1B3;
    cpu1.imem.memory[53] = 32'h10302A23;
    cpu1.imem.memory[54] = 32'h00100093;
    cpu1.imem.memory[55] = 32'h00300113;
    cpu1.imem.memory[56] = 32'h002091B3;
    cpu1.imem.memory[57] = 32'h10302C23;
    cpu1.imem.memory[58] = 32'hFF000093;
    cpu1.imem.memory[59] = 32'h00200113;
    cpu1.imem.memory[60] = 32'h0020D1B3;
    cpu1.imem.memory[61] = 32'h10302E23;
    cpu1.imem.memory[62] = 32'hFF000093;
    cpu1.imem.memory[63] = 32'h00200113;
    cpu1.imem.memory[64] = 32'h4020D1B3;
    cpu1.imem.memory[65] = 32'h12302023;
    cpu1.imem.memory[66] = 32'hFFF00093;
    cpu1.imem.memory[67] = 32'h00100113;
    cpu1.imem.memory[68] = 32'h0020A1B3;
    cpu1.imem.memory[69] = 32'h12302223;
    cpu1.imem.memory[70] = 32'hFFF00093;
    cpu1.imem.memory[71] = 32'h00100113;
    cpu1.imem.memory[72] = 32'h0020B1B3;
    cpu1.imem.memory[73] = 32'h12302423;
    cpu1.imem.memory[74] = 32'h00100093;
    cpu1.imem.memory[75] = 32'h02300113;
    cpu1.imem.memory[76] = 32'h002091B3;
    cpu1.imem.memory[77] = 32'h12302623;
    cpu1.imem.memory[78] = 32'hFFF00093;
    cpu1.imem.memory[79] = 32'h00100113;
    cpu1.imem.memory[80] = 32'h002081B3;
    cpu1.imem.memory[81] = 32'h12302823;
    cpu1.imem.memory[82] = 32'h00500093;
    cpu1.imem.memory[83] = 32'h00500113;
    cpu1.imem.memory[84] = 32'h0020A1B3;
    cpu1.imem.memory[85] = 32'h12302A23;
    cpu1.imem.memory[86] = 32'h00100093;
    cpu1.imem.memory[87] = 32'h00200113;
    cpu1.imem.memory[88] = 32'h0020B1B3;
    cpu1.imem.memory[89] = 32'h12302C23;
    cpu1.imem.memory[90] = 32'h00700093;
    cpu1.imem.memory[91] = 32'hFF608193;
    cpu1.imem.memory[92] = 32'h12302E23;
    cpu1.imem.memory[93] = 32'h0AA00093;
    cpu1.imem.memory[94] = 32'h00F0F193;
    cpu1.imem.memory[95] = 32'h14302023;
    cpu1.imem.memory[96] = 32'h0A000093;
    cpu1.imem.memory[97] = 32'h00F0E193;
    cpu1.imem.memory[98] = 32'h14302223;
    cpu1.imem.memory[99] = 32'h0AA00093;
    cpu1.imem.memory[100] = 32'h0FF0C193;
    cpu1.imem.memory[101] = 32'h14302423;
    cpu1.imem.memory[102] = 32'hFFF00093;
    cpu1.imem.memory[103] = 32'h0010A193;
    cpu1.imem.memory[104] = 32'h14302623;
    cpu1.imem.memory[105] = 32'hFFF00093;
    cpu1.imem.memory[106] = 32'h0010B193;
    cpu1.imem.memory[107] = 32'h14302823;
    cpu1.imem.memory[108] = 32'h00100093;
    cpu1.imem.memory[109] = 32'h01F09193;
    cpu1.imem.memory[110] = 32'h14302A23;
    cpu1.imem.memory[111] = 32'hFF000093;
    cpu1.imem.memory[112] = 32'h0020D193;
    cpu1.imem.memory[113] = 32'h14302C23;
    cpu1.imem.memory[114] = 32'hFF000093;
    cpu1.imem.memory[115] = 32'h4020D193;
    cpu1.imem.memory[116] = 32'h14302E23;
    cpu1.imem.memory[117] = 32'h123451B7;
    cpu1.imem.memory[118] = 32'h16302023;
    cpu1.imem.memory[119] = 32'h00001197;
    cpu1.imem.memory[120] = 32'h16302223;
    cpu1.imem.memory[121] = 32'h0000000F;
    cpu1.imem.memory[122] = 32'h123450B7;
    cpu1.imem.memory[123] = 32'h67808093;
    cpu1.imem.memory[124] = 32'h08102023;
    cpu1.imem.memory[125] = 32'h08002183;
    cpu1.imem.memory[126] = 32'h16302423;
    cpu1.imem.memory[127] = 32'hF8000113;
    cpu1.imem.memory[128] = 32'h082000A3;
    cpu1.imem.memory[129] = 32'h08100183;
    cpu1.imem.memory[130] = 32'h16302623;
    cpu1.imem.memory[131] = 32'h08104183;
    cpu1.imem.memory[132] = 32'h16302823;
    cpu1.imem.memory[133] = 32'hFFE00113;
    cpu1.imem.memory[134] = 32'h08201123;
    cpu1.imem.memory[135] = 32'h08201183;
    cpu1.imem.memory[136] = 32'h16302A23;
    cpu1.imem.memory[137] = 32'h08205183;
    cpu1.imem.memory[138] = 32'h16302C23;
    cpu1.imem.memory[139] = 32'h08002183;
    cpu1.imem.memory[140] = 32'h16302E23;
    cpu1.imem.memory[141] = 32'h00100093;
    cpu1.imem.memory[142] = 32'h00100113;
    cpu1.imem.memory[143] = 32'h00208463;
    cpu1.imem.memory[144] = 32'h001F8F93;
    cpu1.imem.memory[145] = 32'h00100093;
    cpu1.imem.memory[146] = 32'h00200113;
    cpu1.imem.memory[147] = 32'h00208463;
    cpu1.imem.memory[148] = 32'h001F0F13;
    cpu1.imem.memory[149] = 32'h00100093;
    cpu1.imem.memory[150] = 32'h00200113;
    cpu1.imem.memory[151] = 32'h00209463;
    cpu1.imem.memory[152] = 32'h001F8F93;
    cpu1.imem.memory[153] = 32'h00100093;
    cpu1.imem.memory[154] = 32'h00100113;
    cpu1.imem.memory[155] = 32'h00209463;
    cpu1.imem.memory[156] = 32'h001F0F13;
    cpu1.imem.memory[157] = 32'hFFF00093;
    cpu1.imem.memory[158] = 32'h00100113;
    cpu1.imem.memory[159] = 32'h0020C463;
    cpu1.imem.memory[160] = 32'h001F8F93;
    cpu1.imem.memory[161] = 32'h00100093;
    cpu1.imem.memory[162] = 32'hFFF00113;
    cpu1.imem.memory[163] = 32'h0020C463;
    cpu1.imem.memory[164] = 32'h001F0F13;
    cpu1.imem.memory[165] = 32'h00100093;
    cpu1.imem.memory[166] = 32'hFFF00113;
    cpu1.imem.memory[167] = 32'h0020D463;
    cpu1.imem.memory[168] = 32'h001F8F93;
    cpu1.imem.memory[169] = 32'hFFF00093;
    cpu1.imem.memory[170] = 32'h00100113;
    cpu1.imem.memory[171] = 32'h0020D463;
    cpu1.imem.memory[172] = 32'h001F0F13;
    cpu1.imem.memory[173] = 32'h00100093;
    cpu1.imem.memory[174] = 32'hFFF00113;
    cpu1.imem.memory[175] = 32'h0020E463;
    cpu1.imem.memory[176] = 32'h001F8F93;
    cpu1.imem.memory[177] = 32'hFFF00093;
    cpu1.imem.memory[178] = 32'h00100113;
    cpu1.imem.memory[179] = 32'h0020E463;
    cpu1.imem.memory[180] = 32'h001F0F13;
    cpu1.imem.memory[181] = 32'hFFF00093;
    cpu1.imem.memory[182] = 32'h00100113;
    cpu1.imem.memory[183] = 32'h0020F463;
    cpu1.imem.memory[184] = 32'h001F8F93;
    cpu1.imem.memory[185] = 32'h00100093;
    cpu1.imem.memory[186] = 32'hFFF00113;
    cpu1.imem.memory[187] = 32'h0020F463;
    cpu1.imem.memory[188] = 32'h001F0F13;
    cpu1.imem.memory[189] = 32'h19F02023;
    cpu1.imem.memory[190] = 32'h19E02223;
    cpu1.imem.memory[191] = 32'h00A00093;
    cpu1.imem.memory[192] = 32'h00000113;
    cpu1.imem.memory[193] = 32'h00110133;
    cpu1.imem.memory[194] = 32'hFFF08093;
    cpu1.imem.memory[195] = 32'hFE009CE3;
    cpu1.imem.memory[196] = 32'h18202423;
    cpu1.imem.memory[197] = 32'h0080056F;
    cpu1.imem.memory[198] = 32'h001F8F93;
    cpu1.imem.memory[199] = 32'h18A02623;
    cpu1.imem.memory[200] = 32'h32D00593;
    cpu1.imem.memory[201] = 32'h00058667;
    cpu1.imem.memory[202] = 32'h001F8F93;
    cpu1.imem.memory[203] = 32'h18C02823;
    cpu1.imem.memory[204] = 32'h19F02A23;
    cpu1.imem.memory[205] = 32'h00100073;

    #11;
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;

    if(trap !== 1'b0) $fatal(1,"Error: unexpected main program trap");
    if(pc_value !== 32'd820) $fatal(1,"Error: incorrect main program final PC");
    if(cpu1.dmem.memory[64] !== 32'h00000000) $fatal(1,"Error: x0 ignores writes");
    if(cpu1.dmem.memory[65] !== 32'h0000000C) $fatal(1,"Error: ADD");
    if(cpu1.dmem.memory[66] !== 32'hFFFFFFFE) $fatal(1,"Error: SUB");
    if(cpu1.dmem.memory[67] !== 32'h00000088) $fatal(1,"Error: AND");
    if(cpu1.dmem.memory[68] !== 32'h000000EE) $fatal(1,"Error: OR");
    if(cpu1.dmem.memory[69] !== 32'h00000066) $fatal(1,"Error: XOR");
    if(cpu1.dmem.memory[70] !== 32'h00000008) $fatal(1,"Error: SLL");
    if(cpu1.dmem.memory[71] !== 32'h3FFFFFFC) $fatal(1,"Error: SRL");
    if(cpu1.dmem.memory[72] !== 32'hFFFFFFFC) $fatal(1,"Error: SRA");
    if(cpu1.dmem.memory[73] !== 32'h00000001) $fatal(1,"Error: SLT");
    if(cpu1.dmem.memory[74] !== 32'h00000000) $fatal(1,"Error: SLTU");
    if(cpu1.dmem.memory[75] !== 32'h00000008) $fatal(1,"Error: SLL masked shift");
    if(cpu1.dmem.memory[76] !== 32'h00000000) $fatal(1,"Error: ADD wrap");
    if(cpu1.dmem.memory[77] !== 32'h00000000) $fatal(1,"Error: SLT equal");
    if(cpu1.dmem.memory[78] !== 32'h00000001) $fatal(1,"Error: SLTU true");
    if(cpu1.dmem.memory[79] !== 32'hFFFFFFFD) $fatal(1,"Error: ADDI");
    if(cpu1.dmem.memory[80] !== 32'h0000000A) $fatal(1,"Error: ANDI");
    if(cpu1.dmem.memory[81] !== 32'h000000AF) $fatal(1,"Error: ORI");
    if(cpu1.dmem.memory[82] !== 32'h00000055) $fatal(1,"Error: XORI");
    if(cpu1.dmem.memory[83] !== 32'h00000001) $fatal(1,"Error: SLTI");
    if(cpu1.dmem.memory[84] !== 32'h00000000) $fatal(1,"Error: SLTIU");
    if(cpu1.dmem.memory[85] !== 32'h80000000) $fatal(1,"Error: SLLI");
    if(cpu1.dmem.memory[86] !== 32'h3FFFFFFC) $fatal(1,"Error: SRLI");
    if(cpu1.dmem.memory[87] !== 32'hFFFFFFFC) $fatal(1,"Error: SRAI");
    if(cpu1.dmem.memory[88] !== 32'h12345000) $fatal(1,"Error: LUI");
    if(cpu1.dmem.memory[89] !== 32'h000011DC) $fatal(1,"Error: AUIPC uses current PC");
    if(cpu1.dmem.memory[90] !== 32'h12345678) $fatal(1,"Error: SW and LW");
    if(cpu1.dmem.memory[91] !== 32'hFFFFFF80) $fatal(1,"Error: LB signed");
    if(cpu1.dmem.memory[92] !== 32'h00000080) $fatal(1,"Error: LBU unsigned");
    if(cpu1.dmem.memory[93] !== 32'hFFFFFFFE) $fatal(1,"Error: LH signed");
    if(cpu1.dmem.memory[94] !== 32'h0000FFFE) $fatal(1,"Error: LHU unsigned");
    if(cpu1.dmem.memory[95] !== 32'hFFFE8078) $fatal(1,"Error: SB and SH preserve other bytes");
    if(cpu1.dmem.memory[96] !== 32'h00000000) $fatal(1,"Error: all taken branches skip poison");
    if(cpu1.dmem.memory[97] !== 32'h00000006) $fatal(1,"Error: all untaken branches fall through");
    if(cpu1.dmem.memory[98] !== 32'h00000037) $fatal(1,"Error: backward loop sum 1 through 10");
    if(cpu1.dmem.memory[99] !== 32'h00000318) $fatal(1,"Error: JAL link");
    if(cpu1.dmem.memory[100] !== 32'h00000328) $fatal(1,"Error: JALR link and target");
    if(cpu1.dmem.memory[101] !== 32'h00000000) $fatal(1,"Error: jumps skipped poison instructions");

    if(cpu1.read_data1 !== 32'd0 || cpu1.read_data2 !== 32'd0)
        $fatal(1,"Error: x0 read ports incorrect");
    $display("PASS: arithmetic, immediate, memory, branch, loop and jump program (%0d cycles including EBREAK)",cycles);

    
    #20;
    if(pc_value !== 32'd820 || halted !== 1'b1) $fatal(1,"Error: halt is not stable");

    // illegal instruction
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'hFFFFFFFF;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before illegal instruction");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: illegal instruction trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: illegal instruction final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: illegal instruction changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: illegal instruction changed memory");
    $display("PASS: illegal instruction");

    // misaligned load
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h00102303;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before misaligned load");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: misaligned load trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: misaligned load final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: misaligned load changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: misaligned load changed memory");
    $display("PASS: misaligned load");

    // misaligned store
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h001020A3;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before misaligned store");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: misaligned store trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: misaligned store final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: misaligned store changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: misaligned store changed memory");
    $display("PASS: misaligned store");

    // out of range load
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h40002303;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before out of range load");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: out of range load trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: out of range load final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: out of range load changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: out of range load changed memory");
    $display("PASS: out of range load");

    // out of range store
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h40102023;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before out of range store");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: out of range store trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: out of range store final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: out of range store changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: out of range store changed memory");
    $display("PASS: out of range store");

    // misaligned JAL
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h0020036F;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before misaligned JAL");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: misaligned JAL trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: misaligned JAL final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: misaligned JAL changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: misaligned JAL changed memory");
    $display("PASS: misaligned JAL");

    // misaligned JALR
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h00300367;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before misaligned JALR");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1) $fatal(1,"Error: misaligned JALR trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: misaligned JALR final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: misaligned JALR changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: misaligned JALR changed memory");
    $display("PASS: misaligned JALR");

    // ECALL educational halt
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h00000073;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before ECALL educational halt");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0) $fatal(1,"Error: ECALL educational halt trap flag");
    if(pc_value !== 32'd0) $fatal(1,"Error: ECALL educational halt final PC");
    if(cpu1.rf.registers[6] !== 32'd0) $fatal(1,"Error: ECALL educational halt changed x6");
    if(cpu1.dmem.memory[0] !== 32'h12345678) $fatal(1,"Error: ECALL educational halt changed memory");
    $display("PASS: ECALL educational halt");

    // An untaken branch must not fault on its misaligned target.
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h00001163;
    cpu1.imem.memory[1] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0 || pc_value !== 32'd4)
        $fatal(1,"Error: untaken branch incorrectly faulted");
    $display("PASS: untaken misaligned branch target");

    // An aligned jump outside instruction memory faults on the next fetch.
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h4000036F;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd1024)
        $fatal(1,"Error: out of range instruction fetch");
    if(cpu1.rf.registers[6] !== 32'd4)
        $fatal(1,"Error: valid jump did not commit before fetch fault");
    $display("PASS: out of range instruction fetch");

    // Independent instructions must overlap without stalls or flushes.
    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h00100093;
    cpu1.imem.memory[1] = 32'h00200113;
    cpu1.imem.memory[2] = 32'h00300193;
    cpu1.imem.memory[3] = 32'h00400213;
    cpu1.imem.memory[4] = 32'h00500293;
    cpu1.imem.memory[5] = 32'h00600313;
    cpu1.imem.memory[6] = 32'h00700393;
    cpu1.imem.memory[7] = 32'h00800413;
    cpu1.imem.memory[8] = 32'h00900493;
    cpu1.imem.memory[9] = 32'h00A00513;
    cpu1.imem.memory[10] = 32'h00B00593;
    cpu1.imem.memory[11] = 32'h00C00613;
    cpu1.imem.memory[12] = 32'h00100073;
    cpu1.imem.memory[13] = 32'h00102023;
    cpu1.imem.memory[14] = 32'h06300093;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0 || pc_value !== 32'd48)
        $fatal(1,"Error: straight-line pipeline termination");
    for(i = 1; i <= 12; i = i+1)
        if(cpu1.rf.registers[i] !== i)
            $fatal(1,"Error: straight-line result x%0d",i);
    if(retired != 12 || cycles != 17 || stall_cycles != 0 || redirect_cycles != 0)
        $fatal(1,"Error: expected 12 completed instructions in 17 cycles without hazards");
    if(pipeline_full !== 1'b1)
        $fatal(1,"Error: instructions did not overlap across all pipeline registers");
    if(cpu1.dmem.memory[0] !== 32'h12345678)
        $fatal(1,"Error: instruction after EBREAK committed a store");
    $display("PASS: five-stage overlap and straight-line throughput");

    // Forwarding, newest-result priority, WB-to-ID bypass and load hazards.
    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h00300093;
    cpu1.imem.memory[1] = 32'h00408093;
    cpu1.imem.memory[2] = 32'h00508113;
    cpu1.imem.memory[3] = 32'h002081B3;
    cpu1.imem.memory[4] = 32'h00000013;
    cpu1.imem.memory[5] = 32'h00000013;
    cpu1.imem.memory[6] = 32'h00118233;
    cpu1.imem.memory[7] = 32'h04402023;
    cpu1.imem.memory[8] = 32'h04002283;
    cpu1.imem.memory[9] = 32'h00428333;
    cpu1.imem.memory[10] = 32'h04002383;
    cpu1.imem.memory[11] = 32'h04702223;
    cpu1.imem.memory[12] = 32'h04002403;
    cpu1.imem.memory[13] = 32'h00440663;
    cpu1.imem.memory[14] = 32'h00102023;
    cpu1.imem.memory[15] = 32'hFFFFFFFF;
    cpu1.imem.memory[16] = 32'h05500513;
    cpu1.imem.memory[17] = 32'h04A02423;
    cpu1.imem.memory[18] = 32'h04802583;
    cpu1.imem.memory[19] = 32'h00058667;
    cpu1.imem.memory[20] = 32'h00102023;
    cpu1.imem.memory[21] = 32'h00160693;
    cpu1.imem.memory[22] = 32'h04002003;
    cpu1.imem.memory[23] = 32'h00500713;
    cpu1.imem.memory[24] = 32'h04002783;
    cpu1.imem.memory[25] = 32'h00F00813;
    cpu1.imem.memory[26] = 32'h0000000F;
    cpu1.imem.memory[27] = 32'h00100073;
    cpu1.imem.memory[28] = 32'h00102023;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0 || pc_value !== 32'd108)
        $fatal(1,"Error: forwarding program termination");
    if(cpu1.rf.registers[2] !== 32'd12 || cpu1.rf.registers[3] !== 32'd19 ||
       cpu1.rf.registers[4] !== 32'd26 || cpu1.rf.registers[6] !== 32'd52)
        $fatal(1,"Error: ALU forwarding or WB-to-ID bypass");
    if(cpu1.dmem.memory[16] !== 32'd26 || cpu1.dmem.memory[17] !== 32'd26)
        $fatal(1,"Error: forwarded store data");
    if(cpu1.rf.registers[12] !== 32'd80 || cpu1.rf.registers[13] !== 32'd81)
        $fatal(1,"Error: load-to-JALR or jump-link forwarding");
    if(cpu1.rf.registers[14] !== 32'd5 || cpu1.rf.registers[16] !== 32'd15)
        $fatal(1,"Error: x0 or immediate operand handling");
    if(stall_cycles != 4 || redirect_cycles != 2)
        $fatal(1,"Error: expected four load-use stalls and two redirects, got %0d/%0d",stall_cycles,redirect_cycles);
    if(cpu1.dmem.memory[0] !== 32'h12345678)
        $fatal(1,"Error: flushed instruction wrote memory");
    $display("PASS: forwarding, load-use stalls, branch/JALR flushes and false-hazard avoidance");

    // Older instructions commit; a fault discards younger writes and redirects.
    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h04200A93;
    cpu1.imem.memory[1] = 32'h04002823;
    cpu1.imem.memory[2] = 32'h04D00A13;
    cpu1.imem.memory[3] = 32'h00102A83;
    cpu1.imem.memory[4] = 32'h01000A6F;
    cpu1.imem.memory[5] = 32'h05402823;
    cpu1.imem.memory[6] = 32'h06300A13;
    cpu1.imem.memory[7] = 32'h00100073;
    cpu1.dmem.memory[20] = 32'h12345678;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd12)
        $fatal(1,"Error: precise load fault PC");
    if(cpu1.rf.registers[20] !== 32'd77 || cpu1.rf.registers[21] !== 32'd66)
        $fatal(1,"Error: older WB lost or younger fault/jump result committed");
    if(cpu1.dmem.memory[20] !== 32'd0)
        $fatal(1,"Error: older store lost or younger store committed");
    #20;
    if(cpu1.register_we !== 1'b0 || cpu1.memory_we !== 1'b0 || pc_value !== 32'd12)
        $fatal(1,"Error: fault halt allowed further updates");
    $display("PASS: precise stop ordering and older-MEM priority over younger-EX redirect");

    // A jump at the last ROM word must flush speculative out-of-range fetches.
    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h3FC0006F;
    cpu1.imem.memory[1] = 32'h00100073;
    cpu1.imem.memory[255] = 32'hC09FF06F;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0 || pc_value !== 32'd4 || redirect_cycles != 2)
        $fatal(1,"Error: speculative fetch fault survived a redirect");
    $display("PASS: wrong-path instruction-fetch fault flush");

    // Reset while instructions are in flight must discard pending side effects.
    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h06300C93;
    cpu1.imem.memory[1] = 32'h01902023;
    cpu1.imem.memory[2] = 32'h00100073;
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    rst = 1'b0;
    repeat(3) @(posedge clk);
    @(negedge clk);
    rst = 1'b1;
    cpu1.imem.memory[0] = 32'h00100073;
    @(negedge clk);
    if(pc_value !== 32'd0 || cpu1.if_id.valid !== 1'b0 || cpu1.id_ex.valid !== 1'b0 ||
       cpu1.ex_mem.valid !== 1'b0 || cpu1.mem_wb.valid !== 1'b0)
        $fatal(1,"Error: reset did not flush the pipeline");
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0 || pc_value !== 32'd0 || cpu1.rf.registers[25] !== 32'd0 ||
       cpu1.dmem.memory[0] !== 32'h12345678)
        $fatal(1,"Error: reset allowed an in-flight instruction to commit");
    $display("PASS: reset flushes in-flight instructions");

    // MMIO load forwarding and suppression of wrong-path peripheral writes.
    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h04D00113;
    cpu1.imem.memory[2] = 32'h1020A023;
    cpu1.imem.memory[3] = 32'h1000A183;
    cpu1.imem.memory[4] = 32'h00118213;
    cpu1.imem.memory[5] = 32'h0040A283;
    cpu1.imem.memory[6] = 32'h00C0006F;
    cpu1.imem.memory[7] = 32'h1020A223;
    cpu1.imem.memory[8] = 32'h0020A023;
    cpu1.imem.memory[9] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b0 || pc_value !== 32'd36 ||
       cpu1.rf.registers[3] !== 32'd77 || cpu1.rf.registers[4] !== 32'd78 ||
       cpu1.rf.registers[5] !== 32'd0)
        $fatal(1,"Error: MMIO read or load forwarding");
    if(cpu1.sorter.loaded !== 64'd1 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: wrong-path MMIO store changed the accelerator");
    $display("PASS: MMIO routing, load forwarding and wrong-path write suppression");

    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h00100313;
    cpu1.imem.memory[2] = 32'h00408303;
    cpu1.imem.memory[3] = 32'h1060A023;
    cpu1.imem.memory[4] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd8 || cpu1.rf.registers[6] !== 32'd1)
        $fatal(1,"Error: byte MMIO read");
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: byte MMIO read");

    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h00100313;
    cpu1.imem.memory[2] = 32'h0060A223;
    cpu1.imem.memory[3] = 32'h1060A023;
    cpu1.imem.memory[4] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd8 || cpu1.rf.registers[6] !== 32'd1)
        $fatal(1,"Error: read-only MMIO write");
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: read-only MMIO write");

    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h00100313;
    cpu1.imem.memory[2] = 32'h0100A303;
    cpu1.imem.memory[3] = 32'h1060A023;
    cpu1.imem.memory[4] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd8 || cpu1.rf.registers[6] !== 32'd1)
        $fatal(1,"Error: reserved MMIO offset");
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: reserved MMIO offset");

    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h00100313;
    cpu1.imem.memory[2] = 32'h0060A023;
    cpu1.imem.memory[3] = 32'h1060A023;
    cpu1.imem.memory[4] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd8 || cpu1.rf.registers[6] !== 32'd1)
        $fatal(1,"Error: start before all 64 inputs");
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: start before all 64 inputs");

    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h00100313;
    cpu1.imem.memory[2] = 32'h1010A303;
    cpu1.imem.memory[3] = 32'h1060A023;
    cpu1.imem.memory[4] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd8 || cpu1.rf.registers[6] !== 32'd1)
        $fatal(1,"Error: misaligned MMIO access");
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: misaligned MMIO access");

    @(negedge clk);
    rst = 1'b1;
    for(i = 0; i < 256; i = i+1)
        cpu1.imem.memory[i] = 32'h00000013;
    cpu1.imem.memory[0] = 32'h100000B7;
    cpu1.imem.memory[1] = 32'h00100313;
    cpu1.imem.memory[2] = 32'h2000A303;
    cpu1.imem.memory[3] = 32'h1060A023;
    cpu1.imem.memory[4] = 32'h00100073;
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    if(trap !== 1'b1 || pc_value !== 32'd8 || cpu1.rf.registers[6] !== 32'd1)
        $fatal(1,"Error: unmapped address after MMIO");
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: unmapped address after MMIO");

    $display("All CPU tests passed");
    $finish;
end

initial begin
    #20000;
    $fatal(1,"Error: CPU testbench timed out");
end

endmodule: cpu_tb
