; a2_morse.asm
; CSC 230: Summer 2022
;
; Student name:QingZe Luo
; Student ID:V00953873
; Date of completed work:6/24/2022
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2019-Jun-12)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are 
; "DO NOT TOUCH" sections. You are *not* to modify the lines
; within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; I have added for this assignment an additional kind of section
; called "TOUCH CAREFULLY". The intention here is that one or two
; constants can be changed in such a section -- this will be needed
; as you try to test your code on different messages.
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

.include "m2560def.inc"

.cseg
.equ S_DDRB=0x24
.equ S_PORTB=0x25
.equ S_DDRL=0x10A
.equ S_PORTL=0x10B

	
.org 0
	; Copy test encoding (of 'sos') into SRAM
	;
	ldi ZH, high(TESTBUFFER)
	ldi ZL, low(TESTBUFFER)
	ldi r16, 0x30
	st Z+, r16
	ldi r16, 0x37
	st Z+, r16
	ldi r16, 0x30
	st Z+, r16
	clr r16
	st Z, r16

	; initialize run-time stack
	ldi r17, high(0x21ff)
	ldi r16, low(0x21ff)
	out SPH, r17
	out SPL, r16

	; initialize LED ports to output
	ldi r17, 0xff
	sts S_DDRB, r17
	sts S_DDRL, r17

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION **** 
; ***************************************************

   
; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The only things you can change in this section is
; the message (i.e., MESSAGE01 or MESSAGE02 or MESSAGE03,
; etc., up to MESSAGE09).
;

	; encode a message
	;
	ldi r17, high(MESSAGE03 << 1)
	ldi r16, low(MESSAGE03 << 1)
	push r17
	push r16
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall encode_message
	pop r16
	pop r16
	pop r16
	pop r16

; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
	; display the message three times
	;
	ldi r18, 3
main_loop:
	ldi r17, high(BUFFER01)
	ldi r16, low(BUFFER01)
	push r17
	push r16
	rcall flash_message
	dec r18
	tst r18
	brne main_loop


stop:
	rjmp stop
; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION **** 
; ****************************************************


flash_message:

; | 0xEE |  parameter n1 (Z + 10)
; | 0xCC |  parameter n2 (Z + 9)
; | ret  |  return address
; | ret  |  return address
; | ret  |  return address
; | ZL   |  saved register
; | ZH   |  saved register
; | YL   |  
; | YH   | 
; | p1   |  saved register <- register n1 is going to be used in the subroutine, preserve its value on stack
; | p2   |  saved register <- register n2 is going to be used in the subroutine, preserve its value on stack
; |      | <- Z and SP
	.def p1 = r19

	push ZL
	push ZH
	push YL
	push YH
	push p1
	in YH, SPH
	in YL, SPL
	ldd ZH, Y+10
	ldd ZL, Y+9
	push r16
	loop:
		ld p1, Z+
		cpi p1, 0x00
		breq reset
		mov r16, p1
		rcall morse_flash
		clr r16
		rjmp loop

	reset:
		pop r16
		pop p1
		pop YH
		pop YL
		POP ZH
		pop ZL
		ret



morse_flash:

		.def flash_counter = r25
		.def slash_counter = r23
		.def key = r21
		.def buffer = r20
		.def loop_counter = r22
		push flash_counter
		push slash_counter
		push key
		push buffer
		push loop_counter

		clr flash_counter
		clr slash_counter
		clr key
		clr buffer
		clr loop_counter

	reset_buffer:
		clr buffer
		mov buffer, r16
		cpi key, 0x01
		breq for_low_bytes
	for_high_bytes:
		inc key
		andi buffer, 0b11110000
		swap buffer
		mov flash_counter, buffer
		rjmp reset_buffer
		
	for_low_bytes:
		clr key
		andi buffer, 0b00001111
		mov slash_counter, buffer
		clr buffer
		

	cpi flash_counter, 0b00001111
	brne not_space
	cpi slash_counter, 0b00001111
	brne not_space
	rcall leds_off
	rcall delay_long
	rcall delay_long
	rcall delay_long



	not_space:
		push r16
		ldi r16, 0x06

		cpi flash_counter, 0x00
		brne check_index
		rjmp pop_all

	check_index:
		cpi flash_counter, 0x01
		breq start_index_1

		cpi flash_counter, 0x02
		breq start_index_2
		brne check_3
	start_index_1:
			cp loop_counter, flash_counter
			brne keep_going_1
			rjmp pop_all
			

		keep_going_1:

			inc loop_counter
			bst slash_counter, 0
			bld key, 0
			rol slash_counter
			andi key, 0b00000001
			cpi key, 0b00000001
			breq long_light_1
			rcall leds_on
			rcall delay_short
			rcall leds_off
			rcall delay_long
			rjmp start_index_1

		long_light_1:
			rcall leds_on
			rcall delay_long
			rcall leds_off
			rcall delay_long
			rjmp start_index_1

	start_index_2:
			cp loop_counter, flash_counter
			brne keep_going_2
			rjmp pop_all
	

		keep_going_2:
			inc loop_counter
			bst slash_counter, 1
			bld key, 0
			rol slash_counter
			andi key, 0b00000001
			cpi key, 0b00000001
			breq long_light_2
			rcall leds_on
			rcall delay_short
			rcall leds_off
			rcall delay_long
			rjmp start_index_2

		long_light_2:
			rcall leds_on
			rcall delay_long
			rcall leds_off
			rcall delay_long
			rjmp start_index_2
	check_3:

		cpi flash_counter, 0x03
		breq start_index_3
	check_4:
		cpi flash_counter, 0x04
		breq start_index_4
		rjmp pop_all

	start_index_3:
		
			cp loop_counter, flash_counter
			brne keep_going_3
			rjmp pop_all

		

		keep_going_3:
			inc loop_counter
			bst slash_counter, 2
			bld key, 0
			rol slash_counter
			andi key, 0b00000001
			cpi key, 0b00000001
			breq long_light_3
			rcall leds_on
			rcall delay_short
			rcall leds_off
			rcall delay_long
			rjmp start_index_3

		long_light_3:
			rcall leds_on
			rcall delay_long
			rcall leds_off
			rcall delay_long
			rjmp start_index_3

	start_index_4:
		
			cp loop_counter, flash_counter
			brne keep_going_4
			rjmp pop_all

		keep_going_4:
			inc loop_counter
			bst slash_counter, 3
			bld key, 0
			rol slash_counter
			andi key, 0b00000001
			cpi key, 0b00000001
			breq long_light_4
			rcall leds_on
			rcall delay_short
			rcall leds_off
			rcall delay_long
			rjmp start_index_4

		long_light_4:
			rcall leds_on
			rcall delay_long
			rcall leds_off
			rcall delay_long
			rjmp start_index_4

		pop_all:
			pop r16
			pop loop_counter
			pop buffer
			pop key
			pop slash_counter
			pop flash_counter
			
			ret
		
			
				

leds_on:				
		
		push r24
		
		cpi r16, 0x01
		breq turn_one_on

		cpi r16, 0x02
		breq turn_two_on

		cpi r16, 0x03
		breq turn_three_on

		cpi r16, 0x04
		breq turn_four_on

		cpi r16, 0x05
		breq turn_five_on

		cpi r16, 0x06
		breq turn_six_on

		ret

	turn_one_on:
		ldi r24, 0b00000010
		sts S_PORTL, r24
		pop r24 
		ret

	turn_two_on:
		ldi r24, 0b00001010
		sts S_PORTL, r24
		pop r24
		ret

	turn_three_on:
		ldi r24, 0b00101010
		sts S_PORTL, r24
		pop r24
		ret

	turn_four_on:
		ldi r24, 0b10101010
		sts S_PORTL, r24
		pop r24
		ret

	turn_five_on:
		ldi r24, 0b10101010
		sts S_PORTL, r24
		ldi r24, 0b00000010
		sts S_PORTB, r24
		pop r24
		ret

	turn_six_on:
		ldi r24, 0b10101010
		sts S_PORTL, r24
		ldi r17, 0b00001010
		sts S_PORTB, r24
		pop r24
		ret




leds_off:
	push r24
	ldi r24, 0x00
	sts S_PORTL, r24
	sts S_PORTB, r24
	pop r24
	ret



encode_message:

	push ZL
	push ZH
	push YL
	push YH
	push r17 ;r17 check the value on the message
	push XH
	push XL
	push r0
	clr r0
	in YH, SPH
	in YL, SPL
	ldd ZH, Y+15
	ldd ZL, Y+14
	ldd XH, Y+13
	ldd XL, Y+12

	loop_:
		lpm r17, Z+
		push r17
		rcall alphabet_encode
		pop r17
		st X+, r0
		clr r0
		cpi r17, 0x00
		brne loop_
	
	pop r0
	pop XL
	pop XH
	pop r17
	pop YH
	pop YL
	pop ZH
	pop ZL



alphabet_encode:
	.def return_value = r0
	
	push ZL
	push ZH
	push YL
	push YH
	push r25 ;r25 stores the parameters
	push r19 ;r19 loop through the ITU_MORSE table
	push r17 ;r17 record the flash time
	push r20 ;r20 temp stores the dot and flash
	push r21 ;r21 stores the reference of the dot and slash
	in YH, SPH
	in YL, SPL	
	ldd r25, Y+13
	ldi ZL, low(ITU_MORSE << 1)
	ldi ZH, high(ITU_MORSE << 1)
	clr r17
	clr r21
	ldi r21, 0b00000001

	cpi r25, ' '
	brne compare
	ldi r25, 0xff
	mov r0, r25
	rjmp reset_pop

	compare:
		lpm r19, Z+
		cp r25, r19
		breq load_morse
		adiw Z, 7
		rjmp compare

	load_morse:
		lpm r19, Z+
		cpi r19, 0x00
		breq re_format
		inc r17
		cpi r19, 0x2e
		breq load_bits
		cpi r19, 0x2d
		breq load_slash
	load_bits:
		bst r21, 1
		bld r20, 3
		rol r20
		rjmp load_morse

	load_slash:
		bst r21, 0
		bld r20, 3
		rol r20
		rjmp load_morse

	re_format:
		bst r17, 3
		bld return_value, 7
		bst r17, 2
		bld return_value, 6
		bst r17, 1
		bld return_value, 5
		bst r17, 0
		bld return_value, 4
		bst r20, 7
		bld return_value, 3
		bst r20, 6
		bld return_value, 2
		bst r20, 5
		bld return_value, 1
		bst r20, 4
		bld return_value, 0
		
	reset_pop:
		pop r21
		pop r20
		pop r17
		pop r19
		pop r25
		pop YH
		pop YL
		pop ZH
		pop ZL
		ret
	


; **********************************************
; **** END OF SECOND "STUDENT CODE" SECTION **** 
; **********************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

delay_long:
	rcall delay
	rcall delay
	rcall delay
	ret

delay_short:
	rcall delay
	ret

; When wanting about a 1/5th of second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit
	
	ldi r17, 0xff
delay_busywait_loop2:
	dec	r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret



.org 0x1000

ITU_MORSE: .db "a", ".-", 0, 0, 0, 0, 0
	.db "b", "-...", 0, 0, 0
	.db "c", "-.-.", 0, 0, 0
	.db "d", "-..", 0, 0, 0, 0
	.db "e", ".", 0, 0, 0, 0, 0, 0
	.db "f", "..-.", 0, 0, 0
	.db "g", "--.", 0, 0, 0, 0
	.db "h", "....", 0, 0, 0
	.db "i", "..", 0, 0, 0, 0, 0
	.db "j", ".---", 0, 0, 0
	.db "k", "-.-", 0, 0, 0, 0
	.db "l", ".-..", 0, 0, 0
	.db "m", "--", 0, 0, 0, 0, 0
	.db "n", "-.", 0, 0, 0, 0, 0
	.db "o", "---", 0, 0, 0, 0
	.db "p", ".--.", 0, 0, 0
	.db "q", "--.-", 0, 0, 0
	.db "r", ".-.", 0, 0, 0, 0
	.db "s", "...", 0, 0, 0, 0
	.db "t", "-", 0, 0, 0, 0, 0, 0
	.db "u", "..-", 0, 0, 0, 0
	.db "v", "...-", 0, 0, 0
	.db "w", ".--", 0, 0, 0, 0
	.db "x", "-..-", 0, 0, 0
	.db "y", "-.--", 0, 0, 0
	.db "z", "--..", 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0

MESSAGE01: .db "a a a", 0
MESSAGE02: .db "sos", 0
MESSAGE03: .db "a box", 0
MESSAGE04: .db "dairy queen", 0
MESSAGE05: .db "the shape of water", 0, 0
MESSAGE06: .db "top gun maverick", 0, 0
MESSAGE07: .db "obi wan kenobi", 0, 0
MESSAGE08: .db "oh canada our own and native land", 0
MESSAGE09: .db "is that your final answer", 0

; First message ever sent by Morse code (in 1844)
MESSAGE10: .db "what god hath wrought", 0


.dseg
.org 0x200
BUFFER01: .byte 128
BUFFER02: .byte 128
TESTBUFFER: .byte 4
;0x01000,prog
; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================
