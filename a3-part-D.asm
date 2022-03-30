# This code assumes the use of the "Bitmap Display" tool.
#
# Tool settings must be:
#   Unit Width in Pixels: 32
#   Unit Height in Pixels: 32
#   Display Width in Pixels: 512
#   Display Height in Pixels: 512
#   Based Address for display: 0x10010000 (static data)
#
# In effect, this produces a bitmap display of 16x16 pixels.


	.include "bitmap-routines.asm"

	.data
TELL_TALE:
	.word 0x12345678 0x9abcdef0	# Helps us visually detect where our part starts in .data section
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
BOX_ROW:
	.word	0x0
BOX_COLUMN:
	.word	0x0

	.eqv LETTER_a 97
	.eqv LETTER_d 100
	.eqv LETTER_w 119
	.eqv LETTER_x 120
	.eqv BOX_COLOUR 0x0099ff33
	
	.globl main
	
	.text	
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	# initialize variables
	
	# Must enable the keyboard device (i.e., in the "MMIO" simulator) to
	# generate interrupts. 0xffff0000 is the location in kernel memory
	# mapped to the control register of the keybaord.
	
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)	

	addi $a0, $zero, 0                    # assignment says box needs to be in the top left so here it is
	addi $a1, $zero, 0
	addi $a2, $zero, 0x00ffffff
	jal draw_bitmap_box	

forever_loop:
	beq $t7, LETTER_a, press_a            #checks against all the given letters and branches if
	beq $t7, LETTER_d, press_d            #letter is given that moves box
	beq $t7, LETTER_w, press_w            # a = left, w = up, x = down, d = right
	beq $t7, LETTER_x, press_x
	beq $zero, $zero, forever_loop
	
press_a:
	jal destroy_old_box                   #key was pressed so destroy current location 
	nop
	addi $a1, $a1, -1                     # move starting location
	addi $a2, $zero, 0x00ffffff           # color changes to white
	jal draw_bitmap_box                   #draw box at new location
	nop
	li $t7, 0                             # reset $t7 to avoid infinitely moving
	j forever_loop                        #ready for next command
	
press_d:
	jal destroy_old_box                   #all these are the same but will move different directions.
	nop
	addi $a1, $a1, 1
	addi $a2, $zero, 0x00ffffff
	jal draw_bitmap_box
	nop
	li $t7, 0
	j forever_loop

press_w:
	jal destroy_old_box
	nop
	addi $a0, $a0, -1
	addi $a2, $zero, 0x00ffffff
	jal draw_bitmap_box
	nop
	li $t7, 0
	j forever_loop

press_x:
	jal destroy_old_box
	nop
	addi $a0, $a0, 1
	addi $a2, $zero, 0x00ffffff
	jal draw_bitmap_box
	nop
	li $t7, 0
	j forever_loop 
	
	
check_for_event:

	beq $zero, $zero, check_for_event

	# Should never, *ever* arrive at this point
	# in the code.	

	addi $v0, $zero, 10

.data
    .eqv BOX_COLOUR_BLACK 0x00000000       
.text

	addi $v0, $zero, BOX_COLOUR_BLACK
	syscall


destroy_old_box:

	addi $sp, $sp, -20                    #save values due to paranoia
	sw $s0, 0($sp)                        #upon further thought I only ahve to save the ra value i think
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)

	addi $a2, $zero, 0x00000000           #0x00000000 is black so basically removes boxes
	jal draw_bitmap_box                   # draw new box over old box
		
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20                     #reload values again
	jr $ra

# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

draw_bitmap_box:
#
# You can copy-and-paste some of your code from part (c)
# to provide the procedure body.
#
	addi $sp, $sp, -20                    # save values due to paranoia
	sw $a0, 0($sp)                        # magic happens here. save the original values of a0 and a1 
	sw $a1, 4($sp)                        # so when we destroy the old box we are still in correct location
	sw $s2, 8($sp)                        # new starting location is set in the "press" functions
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	jal set_pixel
	nop
	addi $a0, $a0 1
	jal set_pixel
	nop
	addi $a1, $a1 1
	jal set_pixel
	nop
	addi $a0, $a0 -1
	jal set_pixel
	nop
	
			
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20                     #reload values again
	jr $ra


	.kdata

	.ktext 0x80000180
#
# You can copy-and-paste some of your code from part (a)
# to provide elements of the interrupt handler.
#
kernelentry:
	mfc0 $k0, $13		                  # $13 is the "cause" register in Coproc0
	andi $k1, $k0, 0x7c	                  # bits 2 to 6 are the ExcCode field (0 for interrupts)
	srl  $k1, $k1, 2	                  # shift ExcCode bits for easier comparison
	beq $zero, $k1, __is_interrupt
	
__is_interrupt:
	andi $k1, $k0, 0x0100	# examine bit 8
	bne $k1, $zero, keyboard_interrupt	   # if bit 8 set, then we have a keyboard interrupt.
	
	beq $zero, $zero, exit_exception	   # otherwise, we return exit kernel
	
keyboard_interrupt:
	la $k0, 0xffff0004
	lw $t7, 0($k0)	
	
	beq $zero, $zero, exit_exception	   # Kept here in case we add more handlers.
	
	
exit_exception:
	eret


.data

# Any additional .text area "variables" that you need can
# be added in this spot. The assembler will ensure that whatever
# directives appear here will be placed in memory following the
# data items at the top of this file.

	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE


.eqv BOX_COLOUR_WHITE 0x00FFFFFF
	
