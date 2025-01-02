or $r1,$r0,$r2
j 0x0c
nor $r0, $r1, $r2
beq $r0,$r1, 0xfffe
addi $r1, $r0, 0x00
bne $r0,$r1, 0xfffe
