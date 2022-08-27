; main.asm for Hamming assignment
;
; CSC 230: Summer 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-May-18)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (a). In this and other
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
;
; Your task: To compute the Hamming distance between two byte values,
; one in R16, the other in R17. If the first byte is:
;    0b10101101
; and the second byte is:
;    0b10010111
; then the Hamming distance -- that is, the number of corresponding
; bits that are different -- would be 4 (i.e., here bits 5, 4, 3,
; and 1 are different).
;
; In your code, store the computed Hamming-distance value in DISTANCE.
;
; Your solution is free to modify the original values in R16
; and R17.

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========
	ldi r16, 0xAC
	ldi r17, 0xBD

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
//Student Name: QingZe Luo, Student Number: V00953873


	
	
	.def number_1 = r16
	.def number_2 = r17
	.def check_point_1 = r18
	.def check_point_2 = r19
	.def loop_counter = r20
	.def humming_counter = r21
	reset:
		ldi check_point_1, 0x01
		ldi check_point_2, 0x01

	loop:
		
		AND check_point_1, number_1
		AND check_point_2, number_2

		inc loop_counter
		cpi loop_counter, 0x08
		breq save

		LSR number_1
		LSR number_2

		eor check_point_1, check_point_2
		cpi check_point_1, 0x01
		breq add_on
		


		jmp reset

		

	save:

		sts DISTANCE, humming_counter

		jmp stop
		
	
	add_on:

		inc humming_counter
		jmp reset

; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
stop:
    rjmp stop

    .dseg
    .org 0x202
DISTANCE: .byte 1  ; result of computing Hamming distance of r16 & r17
; ==== END OF "DO NOT TOUCH" SECTION ==========
