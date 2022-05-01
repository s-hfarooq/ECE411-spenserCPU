#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

addi x1, x1, 1
addi x2, x1, 1
addi x3, x1, 1
addi x4, x1, 1
addi x5, x1, 1
addi x6, x1, 1
auipc x7, %pcrel_hi(NEGTWO)
jalr x1, x7, 128
jalr x1, x7, 164
addi x1, x1, 1
addi x2, x1, 1
addi x3, x1, 1
addi x4, x1, 1
addi x5, x1, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1

JALR_JUMP_BUT_2:
addi x9, x9, 3
addi x10, x10, 5
beqz x0, BEQ_MV
addi x11, x11, 6
BEQ_MV:
addi x12, x12, 1
ret

JALR_JUMP:
addi x2, x2, 3
addi x3, x3, 5
addi x5, x5, 6
addi x6, x6, 1
auipc x13, %pcrel_hi(NEGTWO)
sw x1, 24(x13)
jalr x1, x13, -40
lw x1, 24(x13)
ret

DONE:
auipc x15, %pcrel_hi(NEGTWO)
nop
nop
nop
nop
nop
nop
nop


.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD
BYTES:  .word 0x04030201
HALF:   .word 0x0020FFFF
