param(
    [string]$Source = 'main.cpp',
    [uint32]$ExpectedResult = 1,
    [string]$ToolchainBin = (Join-Path $env:USERPROFILE '.local\tools\xpack-riscv-none-elf-gcc-15.2.0-1\bin')
)

$ErrorActionPreference = 'Stop'
$compiler = Join-Path $ToolchainBin 'riscv-none-elf-g++.exe'
$objdump = Join-Path $ToolchainBin 'riscv-none-elf-objdump.exe'
if(-not (Test-Path -LiteralPath $compiler)) { throw "Compiler not found: $compiler" }

# Resolve a user-supplied source relative to the caller before changing folders.
if($Source -eq 'main.cpp') {
    $sourcePath = Join-Path $PSScriptRoot 'main.cpp'
}
else {
    $sourcePath = (Resolve-Path -LiteralPath $Source).Path
}
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$testbench = Join-Path $projectRoot 'tb\cpp_tb.sv'

Push-Location -LiteralPath $PSScriptRoot
try {
    New-Item -ItemType Directory -Force -Path build | Out-Null
    & $compiler -march=rv32i -mabi=ilp32 -O1 -g -ffreestanding -fno-builtin `
        -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-use-cxa-atexit `
        -fno-stack-protector -mno-relax -msmall-data-limit=0 -nostdlib `
        '-Wl,-T,link.ld,-Map,build/program.map' start.S $sourcePath -lgcc -o build/program.elf
    if($LASTEXITCODE -ne 0) { throw 'C++ compilation/linking failed; no new testbench generated' }

    $listing = & $objdump -d -S build/program.elf
    if($LASTEXITCODE -ne 0) { throw 'Disassembly failed' }
    $listing | Set-Content -LiteralPath build/program.lst -Encoding utf8

    & python (Join-Path $PSScriptRoot 'elf_to_tb.py') build/program.elf $testbench --expected $ExpectedResult
    if($LASTEXITCODE -ne 0) { throw 'Program loading testbench generation failed' }

    Write-Host "Built program.elf and generated $testbench"
    Write-Host "Expected result: $ExpectedResult"
    Write-Host 'In Vivado: use cpp_tb as the simulation top and run all.'
}
finally {
    Pop-Location
}
