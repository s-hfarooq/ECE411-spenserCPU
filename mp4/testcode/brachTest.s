#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

addi x1, x1, 1
nop
nop
nop
nop
nop
nop
beq x1, x1, BR_TARGET
nop
nop
nop
nop
nop
nop
nop
nop

BR_TARGET:
addi x2, x2, 3
addi x3, x3, 5
addi x5, x5, 6
nop
nop
nop
nop
nop
nop
nop


