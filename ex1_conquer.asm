.text
.globl conquer

conquer:
	sub $sp, $sp, -16
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	
	slt $t0, $a0, $a1
	bne $t0, 1, finish
	jr $ra
	
finish:
	jal divide
	add $t1, $v0, 0
	sw $t1, 12($sp)
	
	lw $a0, 4($sp)
	addi $a1, $t1, -1
	jal conquer
	
	lw $a1, 8($sp)
	lw $t1, 12($sp)
	jal conquer
	
	lw $ra, 0($sp) 	  # relaods the original return address
	addi $sp, $sp, 16 # restores the stack
	jr $ra
	
