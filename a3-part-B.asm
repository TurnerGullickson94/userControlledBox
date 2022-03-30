	.data
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
KEYBOARD_COUNTS:
	.space  128
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
	#need help with the pending event message. I see the given method of check for event
	# but I dont understand how I can flash the message as soon as an interupt occurs
	#before the kernal is entered. is there a way to branch to display the message before
	#we immediately enter the kernal? or is there another way?
	
	
	.eqv 	LETTER_a 97
	.eqv	LETTER_b 98
	.eqv	LETTER_c 99
	.eqv 	LETTER_D 100
	.eqv 	LETTER_space 32
	
	
	.text  
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	# Must enable the keyboard device (i.e., in the "MMIO" simulator) to
	# generate interrupts. 0xffff0000 is the location in kernel memory
	# mapped to the control register of the keybaord.
	
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)


forever_loop:
	beq $t7, LETTER_a, press_tracker_a              #checks against all the given letters and branches if
	beq $t7, LETTER_b, press_tracker_b              #one of the letters is in t7
	beq $t7, LETTER_c, press_tracker_c
	beq $t7, LETTER_D, press_tracker_d
	beq $t7, LETTER_space display_counts            #branches to display count if space is entered

	beq $zero, $zero, forever_loop

press_tracker_a:
	addi $s2, $s2, 1                                #count increments on a only.
	li $t7, 0                                       #resets letter in t7 so no overcounting
	j forever_loop
	
press_tracker_b:
	addi $s3, $s3, 1                                #count increments on b only.
	li $t7, 0                                       #resets letter in t7 so no overcounting
	j forever_loop
	
press_tracker_c:
	addi $s4, $s4, 1                                #count increments on c only.
	li $t7, 0                                       #resets letter in t7 so no overcounting
	j forever_loop
	
press_tracker_d:
	addi $s5, $s5, 1                                #count increments on d only.
	li $t7, 0                                       #resets letter in t7 so no overcounting
	j forever_loop

display_counts:
	move $a0, $s2                                   # prints number of "a"s
	addi $v0, $zero, 1                              #as integer
	syscall
	
	la $a0, SPACE
	addi $v0, $zero, 4
	syscall
	
	move $a0, $s3                                   #prints number of "b"s
	addi $v0, $zero, 1                              #as integer
	syscall
	
	la $a0, SPACE
	addi $v0, $zero, 4
	syscall
	
	move $a0, $s4                                   #prints number of "c"s
	addi $v0, $zero, 1                              #as integer
	syscall
	
	la $a0, SPACE
	addi $v0, $zero, 4
	syscall
	
	move $a0, $s5                                   #prints number of "d"s
	addi $v0, $zero, 1                              #as integer
	syscall
	                                      
	la $a0, NEWLINE                                 #new line so it looks pretty
	addi $v0, $zero, 4
	syscall
	
	li $t7, 0                                       #reset t7 so no infinite looping
	j forever_loop

	.kdata

	.ktext 0x80000180
kernelentry:
	mfc0 $k0, $13		                         ## $13 is the "cause" register in Coproc0
	andi $k1, $k0, 0x7c	                         ## bits 2 to 6 are the ExcCode field (0 for interrupts)
	srl  $k1, $k1, 2	                         ## shift ExcCode bits for easier comparison
	beq $zero, $k1, is_interrupt
	
is_interrupt:
	andi $k1, $k0, 0x0100	                          # examine bit 8
	bne $k1, $zero, keyboard_interrupt	          # if bit 8 set, then we have a keyboard interrupt.
	
	beq $zero, $zero, exit_exception	          # otherwise, we return exit kernel
	
keyboard_interrupt:
	la $k0, 0xffff0004
	lw $t7, 0($k0)		
	beq $zero, $zero, exit_exception	          # Kept here in case we add more handlers.
	
	
exit_exception:
	eret
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

	
