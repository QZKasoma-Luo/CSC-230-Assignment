; reverse.asm
; CSC 230: Summer 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-May-18)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
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
; Your task: To reverse the bits in the word IN1:IN2 and to store the
; result in OUT1:OUT2. For example, if the word stored in IN1:IN2 is
; 0xA174, then reversing the bits will yield the value 0x2E85 to be
; stored in OUT1:OUT2.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
    ; These first lines store a word into IN1:IN2. You may
    ; change the value of the word as part of your coding and
    ; testing.
    ;
    ldi R16, 0x9A
    sts IN1, R16
    ldi R16, 0xFD
    sts IN2, R16
    
    ; This code only swaps the order of the bytes from the
    ; input word to the output word. This clearly isn't enough
    ; so you may modify or delete these lines as you wish.
    ;

	//Student Name: QingZe Luo, Student Number: V0953873

	
    lds R16, IN1

	.def counter = r20
	.def reverse_1 = r18
	.def reverse_2 = r19
	
	loop_number_1:
		bst r16, 0
		bld reverse_1, 7

		ror r16
		rol reverse_1
	
		inc counter
		cpi counter, 0x08
		breq reset

		jmp loop_number_1

	reset:

		lds r16, IN2
		lds counter, 0x00

	loop_number_2:
		
		bst r16, 0
		bld reverse_2, 7

		ror r16
		rol reverse_2
	
		inc counter
		cpi counter, 0x08
		breq save

		jmp loop_number_2



	save:

		sts OUT1, reverse_1
		sts OUT2, reverse_2

		jmp stop

; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x200
IN1:	.byte 1
IN2:	.byte 1
OUT1:	.byte 1
OUT2:	.byte 1
; ==== END OF "DO NOT TOUCH" SECTION ==========
