
	.data
ARRAY_A:
	.word	21, 210, 49, 4
ARRAY_B:
	.word	21, -314159, 0x1000, 0x7fffffff, 3, 1, 4, 1, 5, 9, 2
ARRAY_Z:
	.space	28
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
		
	
	.text  
main:	
	la $a0, ARRAY_A
	addi $a1, $zero, 4
	jal dump_array
	
	la $a0, ARRAY_B
	addi $a1, $zero, 11
	jal dump_array
	
	la $a0, ARRAY_Z
	lw $t0, 0($a0)
	addi $t0, $t0, 1
	sw $t0, 0($a0)
	addi $a1, $zero, 9
	jal dump_array
#		
	addi $v0, $zero, 10
	syscall

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	
dump_array:
	
	addi $sp, $sp, -20                    #save values due to paranoia
	sw $s0, 0($sp)                      
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)

	move $a2, $a0                         #need to move address so we can perform syscalls using a0
	li $a3, 0                             #set compare counter to 0
	
dump_array_loop:
	
	lw $a0, 0($a2)                        #load up first byte has to be unsigned. going to be a problem later.
	li $v0, 1                             # "print integer" command
	syscall
	la $a0, SPACE                         #space so it looks pretty
	addi $v0, $zero, 4                    #
	syscall                               # 
	addi $a2, $a2, 4                      #next byte
	addi $a3, $a3, 1
	beq $a1, $a3, dump_array_exit
	j dump_array_loop
	
	
	
dump_array_exit:

	la $a0, NEWLINE                       # print new line at end as per the assignment
	addi $v0, $zero, 4
	syscall
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20                     #reload values again
	jr $ra
	
	
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
