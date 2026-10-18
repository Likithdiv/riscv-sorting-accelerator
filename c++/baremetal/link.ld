OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 8K
    RAM (rw) : ORIGIN = 0x00002000, LENGTH = 8K
}

SECTIONS {
    .text : {
        KEEP(*(.text.start))
        *(.text*)
    } > ROM

    /* Loads use data memory, so constants must be placed in RAM too. */
    .rodata : {
        . = ALIGN(4);
        *(.rodata*) *(.srodata*)
        . = ALIGN(4);
    } > RAM

    /* The simulation loader initializes .data directly; no ROM copy needed. */
    .data : {
        . = ALIGN(4);
        *(.data*) *(.sdata*)
        . = ALIGN(4);
    } > RAM

    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss*) *(.sbss*) *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > RAM

    .preinit_array : { KEEP(*(.preinit_array*)) } > RAM
    .init_array : { KEEP(*(.init_array*)) } > RAM
    .fini_array : { KEEP(*(.fini_array*)) } > RAM

    __stack_top = ORIGIN(RAM) + LENGTH(RAM);
    __stack_limit = __stack_top - 2048;

    ASSERT(__bss_end <= __stack_limit, "Static data overlaps the reserved 2 KB stack")
    ASSERT(SIZEOF(.preinit_array) == 0, "Preinitialization functions are not supported")
    ASSERT(SIZEOF(.init_array) == 0, "Global constructors are not supported yet")
    ASSERT(SIZEOF(.fini_array) == 0, "Global destructors are not supported yet")

    /DISCARD/ : { *(.eh_frame*) *(.comment*) }
}
