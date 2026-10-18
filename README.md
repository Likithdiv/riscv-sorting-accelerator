# Five-stage RISC-V processor

An educational RV32I processor in SystemVerilog with a memory-mapped engine that sorts 64 signed integers.

Instructions pass through **Fetch → Decode → Execute → Memory → Writeback**. Forwarding handles data dependencies, load-use hazards stall the pipeline, and taken branches/jumps flush younger instructions.

## Files

| Location | Purpose |
| --- | --- |
| `rtl/cpu_top.sv` | Pipeline registers, forwarding, stalls, flushes, and connections |
| `rtl/alu.sv`, `decoder.sv`, `immediate_generator.sv` | Arithmetic and instruction decoding |
| `rtl/pc.sv`, `reg_file.sv`, `branch_unit.sv` | Program counter, registers, and branch decisions |
| `rtl/instruction_memory.sv`, `data_memory.sv`, `load_store_unit.sv` | Instruction storage and data accesses |
| `rtl/sort_engine.sv` | 64-element signed sorting accelerator |
| `tb/` | ALU, CPU, sorting-engine, and generated C++ testbenches |
| `c++/baremetal/main.cpp` | C++ accelerator demo and result checks |
| `c++/baremetal/sort_software.cpp` | Software sorting baseline |
| `c++/baremetal/start.S` | Sets stack, clears BSS, calls main, then stops |
| `c++/baremetal/link.ld` | Places code, data, and stack in memory |
| `c++/baremetal/build.ps1` | Compiles C++ and generates its testbench |
| `c++/baremetal/elf_to_tb.py` | Converts compiled ELF into testbench memory assignments |
| `RISC-V/` | Vivado project and timing constraints |
| `img/` | Saved screenshots, including earlier versions |

## Run

Requires Python and a RISC-V GCC toolchain with `riscv-none-elf-g++`. From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\c++\baremetal\build.ps1
```

The script defaults to the installed xPack toolchain under your user folder. Use `-ToolchainBin "C:\path\to\bin"` for another installation.

Open `RISC-V/RISC-V.xpr` in Vivado. Set **cpu_top** as the design top and **cpp_tb** as the simulation top. Run behavioral simulation and enter `run all` in the simulation Tcl console. Edit `main.cpp` and rebuild when the program changes; `cpp_tb.sv` is generated automatically.

Select `cpu_tb`, `alu_tb`, or `sort_engine_tb` as simulation top to run their separate tests.

## Sorting engine

C++ loads 64 words, starts sorting, polls DONE, then reads back the results. The engine alternates even and odd compare-swap passes for 64 clock cycles.

| Address | Purpose |
| --- | --- |
| `0x10000000` | Control: write 1 to start, 2 to clear DONE |
| `0x10000004` | Status: bit 0 BUSY, bit 1 DONE, bit 2 READY |
| `0x10000008` | Accelerator cycle count |
| `0x10000100`–`0x100001FC` | 64 signed 32-bit integers |

Use aligned 32-bit accesses. Load all 64 words before starting.

## Scope

Supports RV32I integer operations, branches, jumps, and byte/halfword/word loads and stores. ECALL/EBREAK halt this teaching design; invalid or misaligned accesses halt with `trap` asserted. No interrupts, privileged CSRs, caches, or hardware multiply/divide.

The default instruction memory contains a fixed demo. The C++ testbench loads the compiled program for simulation. Timing constraints and screenshots do not establish timing closure for the current design.

Generated Vivado runs, caches, logs, and compiler output stay local and are ignored by Git.
