#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

addi x1, x1, 1
addi x1, x1, 1
auipc x1, %pcrel_hi(NEGTWO)
jalr x0, x1, 48
nop
nop
nop
nop
nop

addi x2, x2, 3
addi x3, x3, 5
addi x5, x5, 6
addi x1, x1, 1
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