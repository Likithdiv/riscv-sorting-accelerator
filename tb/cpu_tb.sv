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

task automatic clear_program();
    for(integer index = 0; index < 256; index = index+1)
        cpu1.imem.memory[index] = 32'h00000013;
endtask

task automatic load_instruction(input integer index, input logic [31:0] word);
    cpu1.imem.memory[index] = word;
endtask

task automatic reset_cpu(input bit clear_imem = 1'b1);
    @(negedge clk);
    rst = 1'b1;
    if(clear_imem) clear_program();
endtask

task automatic run_cpu();
    @(negedge clk);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
endtask

task automatic check_register(input integer index, input logic [31:0] expected,
                              input string message);
    if(cpu1.rf.registers[index] !== expected)
        $fatal(1,"Error: %s (x%0d expected %h, got %h)",message,index,
               expected,cpu1.rf.registers[index]);
endtask

task automatic check_memory(input integer index, input logic [31:0] expected,
                            input string message);
    if(cpu1.dmem.memory[index] !== expected)
        $fatal(1,"Error: %s (word %0d expected %h, got %h)",message,index,
               expected,cpu1.dmem.memory[index]);
endtask

task automatic check_halt(input logic expected_trap, input logic [31:0] expected_pc,
                          input string message);
    if(trap !== expected_trap || pc_value !== expected_pc)
        $fatal(1,"Error: %s (trap=%b, PC=%h)",message,trap,pc_value);
endtask

task automatic test_stop(input logic [31:0] word, input logic expected_trap,
                         input string name);
    reset_cpu(1'b0);
    load_instruction(0,word);
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    if(pc_value !== 32'd0 || halted !== 1'b0 || trap !== 1'b0)
        $fatal(1,"Error: reset failed before %s",name);
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;
    check_halt(expected_trap,32'd0,name);
    check_register(6,32'd0,{name," changed x6"});
    check_memory(0,32'h12345678,{name," changed memory"});
    $display("PASS: %s",name);
endtask

task automatic test_mmio_fault(input logic [31:0] word, input string name);
    reset_cpu();
    load_instruction(0,32'h100000B7);
    load_instruction(1,32'h00100313);
    load_instruction(2,word);
    load_instruction(3,32'h1060A023);
    load_instruction(4,32'h00100073);
    run_cpu();
    check_halt(1'b1,32'd8,name);
    check_register(6,32'd1,name);
    if(cpu1.sorter.loaded !== 64'd0 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: faulting/younger MMIO store caused a side effect");
    $display("PASS: %s",name);
endtask

initial begin
    rst = 1'b1;
    #1;

    clear_program();

    for(i = 1; i < 32; i = i+1)
        load_instruction(i-1,(i << 7) | 32'h00000013);
    load_instruction(31,32'h06300013);
    load_instruction(32,32'h00000193);
    load_instruction(33,32'h10302023);
    load_instruction(34,32'h00700093);
    load_instruction(35,32'h00500113);
    load_instruction(36,32'h002081B3);
    load_instruction(37,32'h10302223);
    load_instruction(38,32'h00500093);
    load_instruction(39,32'h00700113);
    load_instruction(40,32'h402081B3);
    load_instruction(41,32'h10302423);
    load_instruction(42,32'h0AA00093);
    load_instruction(43,32'h0CC00113);
    load_instruction(44,32'h0020F1B3);
    load_instruction(45,32'h10302623);
    load_instruction(46,32'h0AA00093);
    load_instruction(47,32'h0CC00113);
    load_instruction(48,32'h0020E1B3);
    load_instruction(49,32'h10302823);
    load_instruction(50,32'h0AA00093);
    load_instruction(51,32'h0CC00113);
    load_instruction(52,32'h0020C1B3);
    load_instruction(53,32'h10302A23);
    load_instruction(54,32'h00100093);
    load_instruction(55,32'h00300113);
    load_instruction(56,32'h002091B3);
    load_instruction(57,32'h10302C23);
    load_instruction(58,32'hFF000093);
    load_instruction(59,32'h00200113);
    load_instruction(60,32'h0020D1B3);
    load_instruction(61,32'h10302E23);
    load_instruction(62,32'hFF000093);
    load_instruction(63,32'h00200113);
    load_instruction(64,32'h4020D1B3);
    load_instruction(65,32'h12302023);
    load_instruction(66,32'hFFF00093);
    load_instruction(67,32'h00100113);
    load_instruction(68,32'h0020A1B3);
    load_instruction(69,32'h12302223);
    load_instruction(70,32'hFFF00093);
    load_instruction(71,32'h00100113);
    load_instruction(72,32'h0020B1B3);
    load_instruction(73,32'h12302423);
    load_instruction(74,32'h00100093);
    load_instruction(75,32'h02300113);
    load_instruction(76,32'h002091B3);
    load_instruction(77,32'h12302623);
    load_instruction(78,32'hFFF00093);
    load_instruction(79,32'h00100113);
    load_instruction(80,32'h002081B3);
    load_instruction(81,32'h12302823);
    load_instruction(82,32'h00500093);
    load_instruction(83,32'h00500113);
    load_instruction(84,32'h0020A1B3);
    load_instruction(85,32'h12302A23);
    load_instruction(86,32'h00100093);
    load_instruction(87,32'h00200113);
    load_instruction(88,32'h0020B1B3);
    load_instruction(89,32'h12302C23);
    load_instruction(90,32'h00700093);
    load_instruction(91,32'hFF608193);
    load_instruction(92,32'h12302E23);
    load_instruction(93,32'h0AA00093);
    load_instruction(94,32'h00F0F193);
    load_instruction(95,32'h14302023);
    load_instruction(96,32'h0A000093);
    load_instruction(97,32'h00F0E193);
    load_instruction(98,32'h14302223);
    load_instruction(99,32'h0AA00093);
    load_instruction(100,32'h0FF0C193);
    load_instruction(101,32'h14302423);
    load_instruction(102,32'hFFF00093);
    load_instruction(103,32'h0010A193);
    load_instruction(104,32'h14302623);
    load_instruction(105,32'hFFF00093);
    load_instruction(106,32'h0010B193);
    load_instruction(107,32'h14302823);
    load_instruction(108,32'h00100093);
    load_instruction(109,32'h01F09193);
    load_instruction(110,32'h14302A23);
    load_instruction(111,32'hFF000093);
    load_instruction(112,32'h0020D193);
    load_instruction(113,32'h14302C23);
    load_instruction(114,32'hFF000093);
    load_instruction(115,32'h4020D193);
    load_instruction(116,32'h14302E23);
    load_instruction(117,32'h123451B7);
    load_instruction(118,32'h16302023);
    load_instruction(119,32'h00001197);
    load_instruction(120,32'h16302223);
    load_instruction(121,32'h0000000F);
    load_instruction(122,32'h123450B7);
    load_instruction(123,32'h67808093);
    load_instruction(124,32'h08102023);
    load_instruction(125,32'h08002183);
    load_instruction(126,32'h16302423);
    load_instruction(127,32'hF8000113);
    load_instruction(128,32'h082000A3);
    load_instruction(129,32'h08100183);
    load_instruction(130,32'h16302623);
    load_instruction(131,32'h08104183);
    load_instruction(132,32'h16302823);
    load_instruction(133,32'hFFE00113);
    load_instruction(134,32'h08201123);
    load_instruction(135,32'h08201183);
    load_instruction(136,32'h16302A23);
    load_instruction(137,32'h08205183);
    load_instruction(138,32'h16302C23);
    load_instruction(139,32'h08002183);
    load_instruction(140,32'h16302E23);
    load_instruction(141,32'h00100093);
    load_instruction(142,32'h00100113);
    load_instruction(143,32'h00208463);
    load_instruction(144,32'h001F8F93);
    load_instruction(145,32'h00100093);
    load_instruction(146,32'h00200113);
    load_instruction(147,32'h00208463);
    load_instruction(148,32'h001F0F13);
    load_instruction(149,32'h00100093);
    load_instruction(150,32'h00200113);
    load_instruction(151,32'h00209463);
    load_instruction(152,32'h001F8F93);
    load_instruction(153,32'h00100093);
    load_instruction(154,32'h00100113);
    load_instruction(155,32'h00209463);
    load_instruction(156,32'h001F0F13);
    load_instruction(157,32'hFFF00093);
    load_instruction(158,32'h00100113);
    load_instruction(159,32'h0020C463);
    load_instruction(160,32'h001F8F93);
    load_instruction(161,32'h00100093);
    load_instruction(162,32'hFFF00113);
    load_instruction(163,32'h0020C463);
    load_instruction(164,32'h001F0F13);
    load_instruction(165,32'h00100093);
    load_instruction(166,32'hFFF00113);
    load_instruction(167,32'h0020D463);
    load_instruction(168,32'h001F8F93);
    load_instruction(169,32'hFFF00093);
    load_instruction(170,32'h00100113);
    load_instruction(171,32'h0020D463);
    load_instruction(172,32'h001F0F13);
    load_instruction(173,32'h00100093);
    load_instruction(174,32'hFFF00113);
    load_instruction(175,32'h0020E463);
    load_instruction(176,32'h001F8F93);
    load_instruction(177,32'hFFF00093);
    load_instruction(178,32'h00100113);
    load_instruction(179,32'h0020E463);
    load_instruction(180,32'h001F0F13);
    load_instruction(181,32'hFFF00093);
    load_instruction(182,32'h00100113);
    load_instruction(183,32'h0020F463);
    load_instruction(184,32'h001F8F93);
    load_instruction(185,32'h00100093);
    load_instruction(186,32'hFFF00113);
    load_instruction(187,32'h0020F463);
    load_instruction(188,32'h001F0F13);
    load_instruction(189,32'h19F02023);
    load_instruction(190,32'h19E02223);
    load_instruction(191,32'h00A00093);
    load_instruction(192,32'h00000113);
    load_instruction(193,32'h00110133);
    load_instruction(194,32'hFFF08093);
    load_instruction(195,32'hFE009CE3);
    load_instruction(196,32'h18202423);
    load_instruction(197,32'h0080056F);
    load_instruction(198,32'h001F8F93);
    load_instruction(199,32'h18A02623);
    load_instruction(200,32'h32D00593);
    load_instruction(201,32'h00058667);
    load_instruction(202,32'h001F8F93);
    load_instruction(203,32'h18C02823);
    load_instruction(204,32'h19F02A23);
    load_instruction(205,32'h00100073);

    #11;
    rst = 1'b0;
    wait(halted === 1'b1);
    #1;

    if(trap !== 1'b0) $fatal(1,"Error: unexpected main program trap");
    if(pc_value !== 32'd820) $fatal(1,"Error: incorrect main program final PC");
    check_memory(64,32'h00000000,"x0 ignores writes");
    check_memory(65,32'h0000000C,"ADD");
    check_memory(66,32'hFFFFFFFE,"SUB");
    check_memory(67,32'h00000088,"AND");
    check_memory(68,32'h000000EE,"OR");
    check_memory(69,32'h00000066,"XOR");
    check_memory(70,32'h00000008,"SLL");
    check_memory(71,32'h3FFFFFFC,"SRL");
    check_memory(72,32'hFFFFFFFC,"SRA");
    check_memory(73,32'h00000001,"SLT");
    check_memory(74,32'h00000000,"SLTU");
    check_memory(75,32'h00000008,"SLL masked shift");
    check_memory(76,32'h00000000,"ADD wrap");
    check_memory(77,32'h00000000,"SLT equal");
    check_memory(78,32'h00000001,"SLTU true");
    check_memory(79,32'hFFFFFFFD,"ADDI");
    check_memory(80,32'h0000000A,"ANDI");
    check_memory(81,32'h000000AF,"ORI");
    check_memory(82,32'h00000055,"XORI");
    check_memory(83,32'h00000001,"SLTI");
    check_memory(84,32'h00000000,"SLTIU");
    check_memory(85,32'h80000000,"SLLI");
    check_memory(86,32'h3FFFFFFC,"SRLI");
    check_memory(87,32'hFFFFFFFC,"SRAI");
    check_memory(88,32'h12345000,"LUI");
    check_memory(89,32'h000011DC,"AUIPC uses current PC");
    check_memory(90,32'h12345678,"SW and LW");
    check_memory(91,32'hFFFFFF80,"LB signed");
    check_memory(92,32'h00000080,"LBU unsigned");
    check_memory(93,32'hFFFFFFFE,"LH signed");
    check_memory(94,32'h0000FFFE,"LHU unsigned");
    check_memory(95,32'hFFFE8078,"SB and SH preserve other bytes");
    check_memory(96,32'h00000000,"all taken branches skip poison");
    check_memory(97,32'h00000006,"all untaken branches fall through");
    check_memory(98,32'h00000037,"backward loop sum 1 through 10");
    check_memory(99,32'h00000318,"JAL link");
    check_memory(100,32'h00000328,"JALR link and target");
    check_memory(101,32'h00000000,"jumps skipped poison instructions");

    if(cpu1.read_data1 !== 32'd0 || cpu1.read_data2 !== 32'd0)
        $fatal(1,"Error: x0 read ports incorrect");
    $display("PASS: arithmetic, immediate, memory, branch, loop and jump program (%0d cycles including EBREAK)",cycles);

    #20;
    if(pc_value !== 32'd820 || halted !== 1'b1) $fatal(1,"Error: halt is not stable");

    test_stop(32'hFFFFFFFF,1'b1,"illegal instruction");

    test_stop(32'h00102303,1'b1,"misaligned load");

    test_stop(32'h001020A3,1'b1,"misaligned store");

    test_stop(32'h40002303,1'b1,"out of range load");

    test_stop(32'h40102023,1'b1,"out of range store");

    test_stop(32'h0020036F,1'b1,"misaligned JAL");

    test_stop(32'h00300367,1'b1,"misaligned JALR");

    test_stop(32'h00000073,1'b0,"ECALL halt");

    // An untaken branch must not fault on its misaligned target.
    reset_cpu(1'b0);
    load_instruction(0,32'h00001163);
    load_instruction(1,32'h00100073);
    run_cpu();
    if(trap !== 1'b0 || pc_value !== 32'd4)
        $fatal(1,"Error: untaken branch incorrectly faulted");
    $display("PASS: untaken misaligned branch target");

    // An aligned jump outside instruction memory faults on the next fetch.
    reset_cpu(1'b0);
    load_instruction(0,32'h4000036F);
    run_cpu();
    if(trap !== 1'b1 || pc_value !== 32'd1024)
        $fatal(1,"Error: out of range instruction fetch");
    check_register(6,32'd4,"valid jump did not commit before fetch fault");
    $display("PASS: out of range instruction fetch");

    // Independent instructions must overlap without stalls or flushes.
    reset_cpu();
    for(i = 1; i <= 12; i = i+1)
        load_instruction(i-1,(i << 20) | (i << 7) | 32'h00000013);
    load_instruction(12,32'h00100073);
    load_instruction(13,32'h00102023);
    load_instruction(14,32'h06300093);
    cpu1.dmem.memory[0] = 32'h12345678;
    run_cpu();
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
    reset_cpu();
    load_instruction(0,32'h00300093);
    load_instruction(1,32'h00408093);
    load_instruction(2,32'h00508113);
    load_instruction(3,32'h002081B3);
    load_instruction(4,32'h00000013);
    load_instruction(5,32'h00000013);
    load_instruction(6,32'h00118233);
    load_instruction(7,32'h04402023);
    load_instruction(8,32'h04002283);
    load_instruction(9,32'h00428333);
    load_instruction(10,32'h04002383);
    load_instruction(11,32'h04702223);
    load_instruction(12,32'h04002403);
    load_instruction(13,32'h00440663);
    load_instruction(14,32'h00102023);
    load_instruction(15,32'hFFFFFFFF);
    load_instruction(16,32'h05500513);
    load_instruction(17,32'h04A02423);
    load_instruction(18,32'h04802583);
    load_instruction(19,32'h00058667);
    load_instruction(20,32'h00102023);
    load_instruction(21,32'h00160693);
    load_instruction(22,32'h04002003);
    load_instruction(23,32'h00500713);
    load_instruction(24,32'h04002783);
    load_instruction(25,32'h00F00813);
    load_instruction(26,32'h0000000F);
    load_instruction(27,32'h00100073);
    load_instruction(28,32'h00102023);
    cpu1.dmem.memory[0] = 32'h12345678;
    run_cpu();
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
    reset_cpu();
    load_instruction(0,32'h04200A93);
    load_instruction(1,32'h04002823);
    load_instruction(2,32'h04D00A13);
    load_instruction(3,32'h00102A83);
    load_instruction(4,32'h01000A6F);
    load_instruction(5,32'h05402823);
    load_instruction(6,32'h06300A13);
    load_instruction(7,32'h00100073);
    cpu1.dmem.memory[20] = 32'h12345678;
    run_cpu();
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
    reset_cpu();
    load_instruction(0,32'h3FC0006F);
    load_instruction(1,32'h00100073);
    load_instruction(255,32'hC09FF06F);
    run_cpu();
    if(trap !== 1'b0 || pc_value !== 32'd4 || redirect_cycles != 2)
        $fatal(1,"Error: speculative fetch fault survived a redirect");
    $display("PASS: wrong-path instruction-fetch fault flush");

    // Reset while instructions are in flight must discard pending side effects.
    reset_cpu();
    load_instruction(0,32'h06300C93);
    load_instruction(1,32'h01902023);
    load_instruction(2,32'h00100073);
    cpu1.dmem.memory[0] = 32'h12345678;
    @(negedge clk);
    rst = 1'b0;
    repeat(3) @(posedge clk);
    reset_cpu(1'b0);
    load_instruction(0,32'h00100073);
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
    reset_cpu();
    load_instruction(0,32'h100000B7);
    load_instruction(1,32'h04D00113);
    load_instruction(2,32'h1020A023);
    load_instruction(3,32'h1000A183);
    load_instruction(4,32'h00118213);
    load_instruction(5,32'h0040A283);
    load_instruction(6,32'h00C0006F);
    load_instruction(7,32'h1020A223);
    load_instruction(8,32'h0020A023);
    load_instruction(9,32'h00100073);
    run_cpu();
    if(trap !== 1'b0 || pc_value !== 32'd36 ||
       cpu1.rf.registers[3] !== 32'd77 || cpu1.rf.registers[4] !== 32'd78 ||
       cpu1.rf.registers[5] !== 32'd0)
        $fatal(1,"Error: MMIO read or load forwarding");
    if(cpu1.sorter.loaded !== 64'd1 || cpu1.sorter.busy !== 1'b0)
        $fatal(1,"Error: wrong-path MMIO store changed the accelerator");
    $display("PASS: MMIO routing, load forwarding and wrong-path write suppression");

    test_mmio_fault(32'h00408303,"byte MMIO read");

    test_mmio_fault(32'h0060A223,"read-only MMIO write");

    test_mmio_fault(32'h0100A303,"reserved MMIO offset");

    test_mmio_fault(32'h0060A023,"start before all 64 inputs");

    test_mmio_fault(32'h1010A303,"misaligned MMIO access");

    test_mmio_fault(32'h2000A303,"unmapped address after MMIO");

    $display("All CPU tests passed");
    $finish;
end

initial begin
    #20000;
    $fatal(1,"Error: CPU testbench timed out");
end

endmodule: cpu_tb
