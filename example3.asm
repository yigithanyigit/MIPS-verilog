nor $r2,$r0,$r1
addi $r0, $r0, 0x01
sw $r0, 0($r0)
beq $r0,$r1, 0xfffe
bne $r0,$r1, 0xfffb
