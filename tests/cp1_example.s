<<<<<<< HEAD
# RISC-V Load Hazard Test
# Tests various load-use data hazards
# Memory range: 0xAAAAA000 - 0xFFFFFFFF

.section .text
.globl _start
_start:
  # Base pointer in valid RAM: 0xAAAAA000
  lui   x5, 0xAAAAA          # x5 = 0xAAAAA000

  # Loop count
  addi  x6, x0, 64           # x6 = 64 iterations

  # Constants (no pseudo-ops)
  lui   x7, 0x01010
  addi  x7, x7, 0x101        # x7 = 0x01010101

  lui   x8, 0x02020
  addi  x8, x8, 0x202        # x8 = 0x02020202

  lui   x9, 0x03030
  addi  x9, x9, 0x303        # x9 = 0x03030303

  # Seed scratch words: [0..40] from base
  sw    x7,  0(x5)
  sw    x8,  4(x5)
  sw    x9,  8(x5)
  sw    x7, 12(x5)
  sw    x8, 16(x5)

  addi  x30, x5, 32
  sw    x9,  0(x30)          # [base+32] = 0x03030303

  addi  x29, x0, 0           # x29 = 0

loop:
  # --- Store / load / branch chain with tight dependencies ---
  lw    x10, 0(x5)           # x10 = mem[base+0]
  addi  x10, x10, 1          # x10 = x10 + 1        (load->use)
  sw    x10, 0(x5)           # mem[base+0] = x10    (use->store)

  lw    x11, 0(x5)           # x11 = mem[base+0]    (store->load)
  beq   x11, x10, ok0        # compare immediately  (load->branch)
  addi  x0,  x0,  0          # (executed only if mismatch; keeps running)
ok0:
  andi  x29, x11, 1          # x29 = parity of x11  (load->use)
  beq   x29, x0, br1_taken   # if even, take path   (load->branch)

load_site:
  # This is the "where the load would be" site we will branch back to.
  lw    x12, 4(x5)           # x12 = mem[base+4]
  add   x13, x12, x11        # x13 depends on x12
  sw    x13, 8(x5)           # mem[base+8] = x13

  jal   x1, subr             # control hazard + link reg use
after_call0:
  lw    x14, 8(x5)           # x14 = mem[base+8]
  xor   x15, x14, x13
  bne   x15, x0, after_br    # ALU->branch (close)
  addi  x15, x15, 1          # wrong-path if branch taken (must be flushed)
after_br:
  jal   x0, after_paths

br1_taken:
  # Branch1 lands here, then immediately Branch2 decides whether to do the load+branch-back trick.
  andi  x16, x11, 3          # cycles 0..3 based on just-loaded x11
  beq   x16, x0, br2         # Branch2 (taken every 4 iters on average)

  sw    x7, 12(x5)           # wrong-path store if Branch2 is taken (must be killed)
  jal   x0, after_paths

br2:
  # Branch2 performs a load, then branches back to the load_site above.
  lw    x17, 8(x5)           # load on this path
  add   x17, x17, x10        # load->use, and uses x10 from earlier load/store chain
  beq   x17, x17, load_site  # always taken: redirect back to where the load would be

after_paths:
  # --- Extra forwarding pressure: load->store->load + ALU chains + branch ---
  addi  x30, x5, 32
  lw    x18, 0(x30)          # x18 = mem[base+32]
  sw    x18, 4(x30)          # mem[base+36] = x18
  lw    x19, 4(x30)          # x19 = mem[base+36] (store->load)

  add   x20, x19, x18
  sub   x21, x20, x19
  bne   x21, x18, skip_x0    # branch depends on fresh ALU chain
  addi  x0,  x0,  123        # attempts to clobber x0 (should have no effect)
skip_x0:
  addi  x6, x6, -1
  bne   x6, x0, loop

  slti  x0, x0, -256         # required "program completes with" instruction


subr:
  # Subroutine: tight load->branch and store/load ordering again.
  lw    x22, 16(x5)
  beq   x22, x8, subr_taken  # load->branch
  add   x23, x22, x9
  sw    x23, 16(x5)
  jal   x0, subr_ret
subr_taken:
  lw    x24, 12(x5)
  add   x24, x24, x22
  sw    x24, 12(x5)
subr_ret:
  jalr  x0, 0(x1)            # return (jalr)
=======
.section .text
.globl _start
_start:
    addi x1, x0, 4
    nop             # nops in between to prevent hazard
    nop
    nop
    nop
    nop
    addi x3, x1, 8
    nop
    nop
    nop
    nop
    nop

    slti x0, x0, -256 # this is the magic instruction to end the simulation
    nop               # preventing fetching illegal instructions
    nop
    nop
    nop
    nop
>>>>>>> release/main
