.text
.globl divide

divide:
	sub $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	
	add $t0, $0, $a0		# int b = s
	
for1:
	add $t1, $0, $a0		# int a = s
	beq $t1, $a1, out
	
if:
	la $t2, array
	sll $t3, $t1, 2
	add $t4, $t3, $t2
	lw $a1, 8($sp)
	sll $t5, $a1, 2
	add $t6, $t5, $t2
	slt $t7, $t6, $t4
	beq $t7, 1, then
	j for1
	
	

then:
	add $a0, $t1, $0
	add $a1, $t0, $0
	jal swap
	addi $t0, $t0, 1
	j for1
	
	
	
out:
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp) 	  # relaods the original return address
	addi $sp, $sp, 12 # restores the stack
	
	add $a0, $0, $a1
	add $a1, $t0, $0
	jal swap
	add $v0, $0, $t0
	
	lw $ra, 0($sp) 	  # relaods the original return address
	addi $sp, $sp, 12 # restores the stack
	jr $ra
	