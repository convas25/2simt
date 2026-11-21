# Comprehensive RISC-V RV32I Instruction Test Program
# Tests all base instructions with 4 NOPs between each
# Valid address range: 0xAAAAA000 to 0xFFFFFFFF
# NO PSEUDO-INSTRUCTIONS, NO .data SECTION

.text
.globl _start

_start:
#=============================================================================
# Initialize Test Registers
#=============================================================================
    addi x1, x0, 100
    nop
    nop
    nop
    nop
    
    addi x2, x0, 50
    nop
    nop
    nop
    nop
    
    addi x3, x0, -10
    nop
    nop
    nop
    nop
    
    addi x4, x0, 15
    nop
    nop
    nop
    nop
    
    lui x5, 0x12345
    nop
    nop
    nop
    nop
    
    addi x5, x5, 0x678
    nop
    nop
    nop
    nop

#=============================================================================
# Integer Arithmetic Instructions
#=============================================================================

# ADD - Add
test_add:
    add x6, x1, x2      # x6 = 100 + 50 = 150
    nop
    nop
    nop
    nop

# SUB - Subtract
test_sub:
    sub x7, x1, x2      # x7 = 100 - 50 = 50
    nop
    nop
    nop
    nop

# ADDI - Add Immediate
test_addi:
    addi x8, x1, 25     # x8 = 100 + 25 = 125
    nop
    nop
    nop
    nop

# ADDI with negative immediate
test_addi_neg:
    addi x9, x1, -30    # x9 = 100 - 30 = 70
    nop
    nop
    nop
    nop

#=============================================================================
# Logical Instructions
#=============================================================================

# AND - Logical AND
test_and:
    and x10, x1, x2     # x10 = 100 & 50 = 0x64 & 0x32 = 0x20 = 32
    nop
    nop
    nop
    nop

# OR - Logical OR
test_or:
    or x11, x1, x2      # x11 = 100 | 50 = 0x64 | 0x32 = 0x76 = 118
    nop
    nop
    nop
    nop

# XOR - Logical XOR
test_xor:
    xor x12, x1, x2     # x12 = 100 ^ 50 = 0x64 ^ 0x32 = 0x56 = 86
    nop
    nop
    nop
    nop

# ANDI - AND Immediate
test_andi:
    andi x13, x1, 0x0F  # x13 = 100 & 15 = 0x64 & 0x0F = 0x04 = 4
    nop
    nop
    nop
    nop

# ORI - OR Immediate
test_ori:
    ori x14, x1, 0x0F   # x14 = 100 | 15 = 0x64 | 0x0F = 0x6F = 111
    nop
    nop
    nop
    nop

# XORI - XOR Immediate
test_xori:
    xori x15, x1, 0xFF  # x15 = 100 ^ 255 = 0x64 ^ 0xFF = 0x9B = 155
    nop
    nop
    nop
    nop

#=============================================================================
# Shift Instructions
#=============================================================================

# SLL - Shift Left Logical
test_sll:
    sll x16, x1, x4     # x16 = 100 << 15
    nop
    nop
    nop
    nop

# SRL - Shift Right Logical
test_srl:
    srl x17, x1, x2     # x17 = 100 >> (50 & 0x1F) = 100 >> 18 = 0
    nop
    nop
    nop
    nop

# SRA - Shift Right Arithmetic
test_sra:
    sra x18, x3, x2     # x18 = -10 >> (50 & 0x1F) (sign extended)
    nop
    nop
    nop
    nop

# SLLI - Shift Left Logical Immediate
test_slli:
    slli x19, x1, 3     # x19 = 100 << 3 = 800
    nop
    nop
    nop
    nop

# SRLI - Shift Right Logical Immediate
test_srli:
    srli x20, x1, 2     # x20 = 100 >> 2 = 25
    nop
    nop
    nop
    nop

# SRAI - Shift Right Arithmetic Immediate
test_srai:
    srai x21, x3, 1     # x21 = -10 >> 1 = -5 (sign extended)
    nop
    nop
    nop
    nop

#=============================================================================
# Comparison Instructions
#=============================================================================

# SLT - Set Less Than (signed)
test_slt:
    slt x22, x3, x1     # x22 = (-10 < 100) = 1
    nop
    nop
    nop
    nop

# SLTU - Set Less Than Unsigned
test_sltu:
    sltu x23, x3, x1    # x23 = (0xFFFFFFF6 < 100) = 0 (unsigned)
    nop
    nop
    nop
    nop

# SLTI - Set Less Than Immediate
test_slti:
    slti x24, x1, 200   # x24 = (100 < 200) = 1
    nop
    nop
    nop
    nop

# SLTIU - Set Less Than Immediate Unsigned
test_sltiu:
    sltiu x25, x3, 100  # x25 = (0xFFFFFFF6 < 100) = 0 (unsigned)
    nop
    nop
    nop
    nop

#=============================================================================
# Upper Immediate Instructions
#=============================================================================

# LUI - Load Upper Immediate
test_lui:
    lui x26, 0xABCDE    # x26 = 0xABCDE000
    nop
    nop
    nop
    nop

# AUIPC - Add Upper Immediate to PC
test_auipc:
    auipc x27, 0x1000   # x27 = PC + 0x1000000
    nop
    nop
    nop
    nop

#=============================================================================
# Branch Instructions
#=============================================================================

# BEQ - Branch if Equal
test_beq:
    addi x28, x0, 42
    nop
    nop
    nop
    nop
    
    addi x29, x0, 42
    nop
    nop
    nop
    nop
    
    beq x28, x29, beq_target
    nop
    nop
    nop
    nop
    
    addi x30, x0, 255   # Should not execute
    nop
    nop
    nop
    nop

beq_target:
    addi x30, x0, 1     # Should execute
    nop
    nop
    nop
    nop

# BNE - Branch if Not Equal
test_bne:
    bne x1, x2, bne_target
    nop
    nop
    nop
    nop
    
    addi x31, x0, 255   # Should not execute
    nop
    nop
    nop
    nop

bne_target:
    addi x31, x0, 1     # Should execute
    nop
    nop
    nop
    nop

# BLT - Branch if Less Than
test_blt:
    blt x2, x1, blt_target  # 50 < 100
    nop
    nop
    nop
    nop
    
    addi x6, x0, 255    # Should not execute
    nop
    nop
    nop
    nop

blt_target:
    addi x6, x0, 2      # Should execute
    nop
    nop
    nop
    nop

# BGE - Branch if Greater or Equal
test_bge:
    bge x1, x2, bge_target  # 100 >= 50
    nop
    nop
    nop
    nop
    
    addi x7, x0, 255    # Should not execute
    nop
    nop
    nop
    nop

bge_target:
    addi x7, x0, 2      # Should execute
    nop
    nop
    nop
    nop

# BLTU - Branch if Less Than Unsigned
test_bltu:
    bltu x2, x1, bltu_target  # 50 < 100 (unsigned)
    nop
    nop
    nop
    nop
    
    addi x8, x0, 255    # Should not execute
    nop
    nop
    nop
    nop

bltu_target:
    addi x8, x0, 2      # Should execute
    nop
    nop
    nop
    nop

# BGEU - Branch if Greater or Equal Unsigned
test_bgeu:
    bgeu x1, x2, bgeu_target  # 100 >= 50 (unsigned)
    nop
    nop
    nop
    nop
    
    addi x9, x0, 255    # Should not execute
    nop
    nop
    nop
    nop

bgeu_target:
    addi x9, x0, 2      # Should execute
    nop
    nop
    nop
    nop

#=============================================================================
# Jump Instructions
#=============================================================================

# JAL - Jump and Link
test_jal:
    jal x10, jal_target
    nop
    nop
    nop
    nop
    
    addi x11, x0, 255   # Should not execute
    nop
    nop
    nop
    nop

jal_target:
    addi x11, x0, 3     # Should execute, x10 has return address
    nop
    nop
    nop
    nop

# JALR - Jump and Link Register
test_jalr:
    auipc x12, 0        # Get PC
    nop
    nop
    nop
    nop
    
    addi x12, x12, 80   # Calculate target address
    nop
    nop
    nop
    nop
    
    jalr x13, x12, 0    # Jump to x12
    nop
    nop
    nop
    nop
    
    addi x14, x0, 255   # Should not execute
    nop
    nop
    nop
    nop

jalr_target:
    addi x14, x0, 3     # Should execute, x13 has return address
    nop
    nop
    nop
    nop

#=============================================================================
# Load/Store Instructions - Setup memory address
#=============================================================================

setup_mem_ptr:
    lui x15, 0xFFFF0    # Point to high memory address in valid range
    nop
    nop
    nop
    nop
    
    addi x15, x15, 0x000  # x15 = 0xFFFF0000 (base address for load/store)
    nop
    nop
    nop
    nop

#=============================================================================
# Store Instructions
#=============================================================================

# SW - Store Word
test_sw:
    addi x16, x0, 100
    nop
    nop
    nop
    nop
    
    sw x16, 0(x15)      # Store 100 at mem[x15]
    nop
    nop
    nop
    nop

# SH - Store Halfword
test_sh:
    lui x17, 0x1
    nop
    nop
    nop
    nop
    
    addi x17, x17, 0x234
    nop
    nop
    nop
    nop
    
    sh x17, 4(x15)      # Store halfword at mem[x15+4]
    nop
    nop
    nop
    nop

# SB - Store Byte
test_sb:
    addi x18, x0, 0xAB
    nop
    nop
    nop
    nop
    
    sb x18, 8(x15)      # Store byte at mem[x15+8]
    nop
    nop
    nop
    nop

#=============================================================================
# Load Instructions
#=============================================================================

# LW - Load Word
test_lw:
    lw x19, 0(x15)      # Load word from mem[x15]
    nop
    nop
    nop
    nop

# LH - Load Halfword (sign-extended)
test_lh:
    lh x20, 4(x15)      # Load halfword from mem[x15+4]
    nop
    nop
    nop
    nop

# LHU - Load Halfword Unsigned
test_lhu:
    lhu x21, 4(x15)     # Load halfword unsigned from mem[x15+4]
    nop
    nop
    nop
    nop

# LB - Load Byte (sign-extended)
test_lb:
    lb x22, 8(x15)      # Load byte from mem[x15+8]
    nop
    nop
    nop
    nop

# LBU - Load Byte Unsigned
test_lbu:
    lbu x23, 8(x15)     # Load byte unsigned from mem[x15+8]
    nop
    nop
    nop
    nop

#=============================================================================
# Additional Edge Cases
#=============================================================================

# Test with x0 (hardwired zero)
test_x0_read:
    add x24, x0, x1     # x24 = 0 + 100 = 100
    nop
    nop
    nop
    nop

test_x0_write:
    addi x0, x1, 100    # Write to x0 (should have no effect)
    nop
    nop
    nop
    nop
    
    add x25, x0, x0     # x25 = 0 (verify x0 is still 0)
    nop
    nop
    nop
    nop

# Test maximum positive and negative immediates
test_max_imm:
    addi x26, x0, 2047  # Maximum positive 12-bit immediate
    nop
    nop
    nop
    nop
    
    addi x27, x0, -2048 # Maximum negative 12-bit immediate
    nop
    nop
    nop
    nop

# Test shift by 0
test_shift_zero:
    slli x28, x1, 0     # x28 = 100 << 0 = 100
    nop
    nop
    nop
    nop

# Test shift by max (31)
test_shift_max:
    slli x29, x1, 31    # x29 = 100 << 31
    nop
    nop
    nop
    nop

#=============================================================================
# Completion Marker
#=============================================================================

test_complete:
    lui x30, 0xDEADC    # Completion marker
    nop
    nop
    nop
    nop
    
    addi x30, x30, -273 # x30 = 0xDEADBEEF
    nop
    nop
    nop
    nop

#=============================================================================
# Magic Halt Instruction
#=============================================================================

end_program:
    slti x0, x0, -256   # END OF RANDOM ASM - MAGIC HALT INST HERE
    nop
    nop
    nop
    nop
    nop
