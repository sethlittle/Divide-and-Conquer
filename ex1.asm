# Starter file for ex1.asm

.data 0x0

newline:	.asciiz "\n"
		.align 2
array: 		.space 200 
        
.text 0x3000

.globl main
main: 
	ori     $sp, $0, 0x2ffc       # Initialize stack pointer to the top word below .text
                                # The first value on stack will actually go at 0x2ff8
                                #   because $sp is decremented first.
  	addi    $fp, $sp, -4          # Set $fp to the start of main's stack frame
  	
  	
  	li $v0, 5
  	syscall
  	add $s0, $v0, $0	# num is stored in s0
  	
  	addi $t0, $0, 0		# j = 0
  	
for:
	beq $t0, $s0, toConquer		#if j = num, jump to toConquer
  	li $v0, 5			# reads in an integer and puts it in $v0
  	syscall
  	la $t1, array			# load address of array
  	sll $t2, $t0, 2			# multiplies j times 4 to advance along whole words
  	add $t3, $t2, $t1		# puts the address of array j * 4 into t3
  	sw $v0, ($t3)			# stores v0 in that address
  	addi $t0, $t0, 1		# j++
  	j for				# jumps back to the for loop
	 
toConquer:
	add $a0, $0, $0			# puts 0 into a0
	addi $a1, $s0, -1		# puts num - 1 into a1
	jal conquer			# jump and link to conquer (method call)
	
	j toPrint
	
	
swap:
	sll $t0, $a0, 2			# takes a*4 and stores it in t0
	sll $t1, $a1, 2			# takes b*4 and stores it in t1
	
	la $t2, array			# gets the address of the array into t2
	
	add $t3, $t2, $t0		#  array + a*4 into t3
	add $t4, $t2, $t1		# array + b*4 into t4
	
	lw $t5, ($t3)			# loads array[a] into t5
	lw $t6, ($t4)			# loads the array[b] into t6
	
	sw $t5, ($t4)			# stores array[a] at array[b] location
	sw $t6, ($t3)			# stores array[b] into array[a] location
	
	jr $ra
	
	
conquer:
	sub $sp, $sp, 16		# stack space for 4 variable	
	sw $ra, 0($sp)			# ra
	sw $a0, 4($sp)			# a0 - s
	sw $a1, 8($sp)			# a1 - f
	
	slt $t0, $a0, $a1		# sets t0 to 1 if s < f
	beq $t0, 1, finish		# jumps to finish if s < f
	jr $ra				# else returns to the jal method call
	
finish:
	jal divide			# jal to divide
	add $t1, $v0, 0			# t1 now has b
	sw $t1, 12($sp)			# stores b on the stack - int i = b
	
	lw $a0, 4($sp)			# loads back s into a0
	addi $a1, $t1, -1		# loads i - 1 into a1
	jal conquer			# conquer(s, i - 1)
	
	lw $a1, 8($sp)			# loads f into a1
	lw $t1, 12($sp)
	addi $a0, $t1, 1		# i + 1 into a0			
	jal conquer			# conquer(i + 1, f)
	
	lw $ra, 0($sp) 	  # relaods the original return address
	addi $sp, $sp, 16 # restores the stack
	jr $ra
	
divide:
	sub $sp, $sp, 12		# now adds 12 onto the already stack of 16
	sw $ra, 0($sp)			# ra
	sw $a0, 4($sp)			# a0 - s
	sw $a1, 8($sp)			# a1 - f
	
	add $t0, $0, $a0		# int b = s
	add $t1, $0, $a0		# int a = s
	
for1:
	beq $t1, $a1, out		# branch to out if a = f
	
if:
	la $t2, array			# loads the address of array into t2
	sll $t3, $t1, 2			# a * 4
	add $t4, $t3, $t2		# address of array + a*4 into t4
	sll $t5, $a1, 2			# puts the value of f*4 into t5
	add $t6, $t5, $t2		# address of the array + f*4 into t6
	lw $s3, ($t6)			# puts array[f] into s3
	lw $s4, ($t4)			# puts array[a] into s4
	slt $t7, $s3, $s4		# sets t7 equal to 1 if s3 < s4 or if array[f] < array[a] = array[a] <= array[f]
	beq $t7, 1, then		# if they are equal, it jummps to the then portion
	addi $t1, $t1, 1		# a++
	j for1				# for loop again

then:
	addi $sp, $sp, -16		# takes another 16 spots on the stack
	sw $t0, 0($sp)			# stores t0 on the stack - need it later - b
	sw $t1, 4($sp)			# stores t1 on the stack - need it later - a
	sw $a0, 8($sp)			# stores a0 on the stack - s
	sw $a1, 12($sp)			# stores a1 on the stack - f
	add $a0, $t1, $0		# sets a0 to a
	add $a1, $t0, $0		# sets a1 to b
	jal swap			# jump and link to swap
	lw $t0, 0($sp)			# restores t0 to b
	lw $t1, 4($sp)			# restores t1 to a
	lw $a0, 8($sp)			# restores a0 to s
	lw $a1, 12($sp)			# restores a1 to f
	addi $sp, $sp, 16		# restores the stack
	addi $t0, $t0, 1		# b++
	addi $t1, $t1, 1		# a++
	j for1				# jumps back to the for loop
	
out:
	add $a0, $0, $a1		# a0 = f
	add $a1, $t0, $0		# a1 = b
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal swap			# jal swap again
	lw $t0, 0($sp)			# restores b
	addi $sp, $sp, 4
	lw $a1, 8($sp)			# restores a1 to f
	lw $a0, 4($sp)			# restores a0 to s
	add $v0, $0, $t0		# return b
	
	lw $ra, 0($sp) 	  # relaods the original return address
	addi $sp, $sp, 12 # restores the stack
	jr $ra

toPrint:
	la $t1, array		# puts the address of the array into t1
	addi $s1, $s0, -1		# int i = num - 1
	
loop:
	beq $s1, -1, end		# branch to the end if i < 0 or i = -1
	sll $t2, $s1, 2			# i * 4 into t2
	add $t3, $t2, $t1		# address of array + i*4 into t3
	lw $a0, ($t3)			# loads the word array[i] into a0
	
	li $v0, 1			# puts 1 into v0 - syscall to print an integer
	syscall
	
	li $v0, 4
  	la $a0, newline			# prints a newline
  	syscall
	
	addi $s1, $s1, -1		# i--
	j loop				# jumps back to the loop

end: 
	ori   $v0, $0, 10     # system call 10 for exit
	syscall               # exit