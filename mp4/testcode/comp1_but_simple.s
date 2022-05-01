#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:

lui	  x2,0x84000
addi  x2,x2,-16
sw	  x1,12(x2)
sw	  x8,8(x2)
sw	  x26,4(x2)
lui	  x26,0xdeffe
addi  x26,x26,-257
auipc x1,0x0
jalr  372(x1)
or	  x12,x12,x10
jal   x18, DONE
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
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1
addi x8, x8, 1

TEST_FUNC:
auipc x15, %pcrel_hi(NEGTWO)
addi x2, x2, 5
sw x2, 44(x15)
lw x16, 44(x15)
li x10, 12
ret

TO_JMP:
addi x2, x2, 3
addi x3, x3, 5
addi x5, x5, 6
addi x6, x6, 1
ret

DONE:
auipc x9, %pcrel_hi(NEGTWO)
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