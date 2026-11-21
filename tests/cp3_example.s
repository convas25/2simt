<<<<<<< HEAD
# ============================================================
#   RISC‑V Branch + Jump Testbench
#   Valid memory range: 0xAAAAA000 – 0xFFFFFFFF
# ============================================================

.section .text
.globl _start

_start:
    # --------------------------------------------------------
    # Base pointer = 0xAAAAA000
    # --------------------------------------------------------
    lui   x10, 0xAAAAA          # x10 = 0xAAAAA000

    # --------------------------------------------------------
    # Initialize test data
    # --------------------------------------------------------
    li    x11, 1
    li    x12, 2
    li    x13, 0xFFFFFFFF       # signed -1
    li    x14, 0x00000001

    sw    x11, 0(x10)           # [0xAAAAA000] = 1
    sw    x12, 4(x10)           # [0xAAAAA004] = 2
    sw    x13, 8(x10)           # [0xAAAAA008] = -1
    sw    x14, 12(x10)          # [0xAAAAA00C] = 1

# ============================================================
# Test 1: BEQ taken + flush
# ============================================================
test_beq_taken:
    lw    x1, 0(x10)            # x1 = 1
    lw    x2, 0(x10)            # x2 = 1
    beq   x1, x2, beq_target
    li    x3, 0xBAD             # must be flushed
    j     beq_after

beq_target:
    li    x3, 0x600D            # taken path

beq_after:
    sw    x3, 16(x10)

# ============================================================
# Test 2: BEQ not taken
# ============================================================
test_beq_not_taken:
    lw    x1, 0(x10)
    lw    x2, 4(x10)
    beq   x1, x2, beq_nt_target
    li    x4, 0x1234            # correct path
    j     beq_nt_after

beq_nt_target:
    li    x4, 0xDEAD            # must NOT execute

beq_nt_after:
    sw    x4, 20(x10)

# ============================================================
# Test 3: BNE taken
# ============================================================
test_bne_taken:
    lw    x1, 0(x10)
    lw    x2, 4(x10)
    bne   x1, x2, bne_target
    li    x5, 0xBAD             # must be flushed
    j     bne_after

bne_target:
    li    x5, 0xBEEF

bne_after:
    sw    x5, 24(x10)

# ============================================================
# Test 4: BLT signed
# ============================================================
test_blt_signed:
    lw    x1, 8(x10)            # x1 = -1
    lw    x2, 0(x10)            # x2 = 1
    blt   x1, x2, blt_target
    li    x6, 0xBAD
    j     blt_after

blt_target:
    li    x6, 0x1111

blt_after:
    sw    x6, 28(x10)

# ============================================================
# Test 5: BGEU unsigned
# ============================================================
test_bgeu_unsigned:
    lw    x1, 8(x10)            # x1 = 0xFFFFFFFF (unsigned big)
    lw    x2, 0(x10)            # x2 = 1
    bgeu  x1, x2, bgeu_target
    li    x7, 0xBAD
    j     bgeu_after

bgeu_target:
    li    x7, 0x2222

bgeu_after:
    sw    x7, 32(x10)

# ============================================================
# Test 6: JAL (unconditional jump + link)
# ============================================================
test_jal:
    jal   x8, jal_target
    li    x8, 0xBAD             # must be flushed

jal_target:
    sw    x8, 36(x10)           # x8 = return address

# ============================================================
# Test 7: JALR (rs1 + imm)
# ============================================================
test_jalr:
    addi  x9, x10, 48           # target = base + 48
    jalr  x9, 0(x9)             # jump to (x9 + 0)
    li    x9, 0xBAD             # must be flushed

# Jump lands here:
jalr_target:
    sw    x9, 40(x10)

# ============================================================
# Test 8: Branch hazard (load → branch)
# ============================================================
test_load_branch:
    lw    x1, 0(x10)            # x1 = 1
    beq   x1, x11, lb_target    # must stall 1 cycle
    li    x2, 0xBAD
    j     lb_after

lb_target:
    li    x2, 0x3333

lb_after:
    sw    x2, 44(x10)

# ============================================================
# End of test
# ============================================================
test_done:
    slti x0, x0, -256           # magic halt
=======
.section .text
.globl _start
_start:
    addi x1, x0, 4
    addi x3, x1, 8

    slti x0, x0, -256 # this is the magic instruction to end the simulation
    nop               # preventing fetching illegal instructions
    nop
    nop
    nop
    nop
>>>>>>> release/main
