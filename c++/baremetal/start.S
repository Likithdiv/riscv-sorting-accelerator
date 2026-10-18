.option norelax
.section .text.start,"ax",@progbits
.globl _start
.type _start,@function

_start:
    la sp, __stack_top
    la t0, __bss_start
    la t1, __bss_end

clear_bss:
    bgeu t0, t1, call_main
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss

call_main:
    call main
    ebreak

stopped:
    j stopped

.size _start, .-_start
