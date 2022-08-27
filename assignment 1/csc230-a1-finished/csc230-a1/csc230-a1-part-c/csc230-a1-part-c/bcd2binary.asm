; bcd2binary.asm
; CSC 230: Summer 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-May-18)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: Given a binary-coded decimal (BCD) number stored in
; R16, conver this number into the usual binary representation,
; and store in BCD2BINARY.
;

    .cseg
    .org 0

    .equ TEST1=0x99 ; 99 decimal, equivalent to 0b01100011
    .equ TEST2=0x81 ; 81 decimal, equivalent to 0b01010001
	.equ TEST3=0x20 ; 20 decimal, equivalent to 0b00010100
	 
	ldi r16, TEST3

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
	//Student Name:QingZe Luo, Student Number: V00953873

	.def copy = r20
	mov copy, r16
	.def counter = r17
	ldi counter, 0x00
	.def last_4 = r18
	clr last_4
	clr first_4
	.def first_4 = r19
	.def ten = r21
	
	
	loop: 
		inc counter
		bst r16, 0
		bld last_4, 7

		cpi counter, 0x04
		breq swap_position_1

		ror r16
		ror last_4

		jmp loop

	
	swap_position_1:

		swap last_4
		

	loop2:
		inc counter
		bst copy, 7
		bld first_4, 0

		cpi counter, 0x08
		breq copy_ten

		rol copy
		rol first_4

		jmp loop2

	copy_ten:
		mov ten, first_4
	mulptiply:
		
		inc counter

		add first_4, ten

		cpi counter, 0x11
		breq add_together

		jmp mulptiply
	

	add_together:

		add first_4, last_4

		sts BCD2BINARY, first_4

; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
end:
	rjmp end


.dseg
.org 0x200
BCD2BINARY: .byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
