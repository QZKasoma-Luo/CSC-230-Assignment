; a3part2.asm
; CSC 230: Summer 2022
;
; Student name:QingZe Luo
; Student ID:V00953873
; Date of completed work:7/17/2022
;
; *******************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Jul-02)
; 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#3. As with A#2, there are 
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
;
; In this "DO NOT TOUCH" section are:
;
; (1) assembler directives setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants we can use later in the
;     program
;
; (4) code for initial setup of the Analog Digital Converter (in the
;     same manner in which it was set up for Lab #4)
;     
; (5) code for setting up our three timers (timer1, timer3, timer4)
;
; After all this initial code, your own solution's code may start.
;

.cseg
.org 0
	jmp reset

; location in vector table for TIMER1 COMPA
;
.org 0x22
	jmp timer1

; location in vector table for TIMER4 COMPA
;
.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd_function_defs.inc"
.include "lcd_function_code.asm"

.cseg

; These two constants can help given what is required by the
; assignment.
;
#define MAX_PATTERN_LENGTH 10
#define BAR_LENGTH 6

; All of these delays are in seconds
;
#define DELAY1 0.5
#define DELAY3 0.1
#define DELAY4 0.01


; The following lines are executed at assembly time -- their
; whole purpose is to compute the counter values that will later
; be stored into the appropriate Output Compare registers during
; timer setup.
;

#define CLOCK 16.0e6 
.equ PRESCALE_DIV=1024  ; implies CS[2:0] is 0b101
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))

.if TOP1>65535
.error "TOP1 is out of range"
.endif

.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif


reset:
	; initialize the ADC converter (which is neeeded
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer4 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16


	; timer1 is for the heartbeat -- i.e., part (1)
	;
    ldi r16, high(TOP1)
    sts OCR1AH, r16
    ldi r16, low(TOP1)
    sts OCR1AL, r16
    ldi r16, 0
    sts TCCR1A, r16
    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, temp
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; timer3 is for the LCD display updates -- needed for all parts
	;
    ldi r16, high(TOP3)
    sts OCR3AH, r16
    ldi r16, low(TOP3)
    sts OCR3AL, r16
    ldi r16, 0
    sts TCCR3A, r16
    ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
    sts TCCR3B, temp

	; timer4 is for reading buttons at 10ms intervals -- i.e., part (2)
    ; and part (3)
	;
    ldi r16, high(TOP4)
    sts OCR4AH, r16
    ldi r16, low(TOP4)
    sts OCR4AL, r16
    ldi r16, 0
    sts TCCR4A, r16
    ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
    sts TCCR4B, temp
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

    ; flip the switch -- i.e., enable the interrupts
    sei

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================


; *********************************************
; **** BEGINNING OF "STUDENT CODE" SECTION **** 
; *********************************************
	rcall lcd_init
	ldi r17, high(0x21ff)
	ldi r16, low(0x21ff)
	out SPH, r17
	out SPL, r16
	clr r16
	clr r17
start:
	push r20
	ldi r20, 0
	sts BUTTON_COUNT, r20
	sts BUTTON_COUNT+1, r20
	pop r20
	clr temp
	sts DISPLAY_TEXT, temp

main_loop:
	
	in temp, TIFR3
	sbrs temp, OCF3A;check if the temp reaches the 0.5s
	rjmp main_loop
	ldi temp, 1<<OCF3A ;clear the timer for the next round
	out TIFR3, temp
	rcall heart
	rcall button_press_number
	starts:
	
	push r16
	push r17
	lds r17, BUTTON_CURRENT
	cpi r17, 0x01
	brne start_exit
	ldi r16, 1
	ldi r17, 0
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16
	pop r17
	pop r16

	ldi r16, '*'
	push r16
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar

	pop r16
	rjmp again

start_exit:
	push r16
	push r17
	ldi r16, 1
	ldi r17, 0
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	rcall lcd_putchar
	pop r16
	

again:
	rjmp main_loop



stop:
    rjmp stop



heart:
	push r16
	push r17
	ldi r16, 0
	ldi r17, 14
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	lds r16, PULSE
	cpi r16, 0x01
	breq heart_symbol
	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16
	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16
	pop r16
	pop r17
	ret

	heart_symbol:
		ldi r16, '<'
		push r16
		rcall lcd_putchar
		pop r16
		ldi r16, '>'
		push r16
		rcall lcd_putchar
		pop r16
		pop r16
		pop r17
		ret

button_press_number:
	push r16
	push r17
	push XH
	push XL


	ldi r16, 1
	ldi r17, 11
	push r16
	push r17
	rcall lcd_gotoxy
	pop r16
	pop r17


	ldi XH, high(BUTTON_COUNT)
	ldi XL, low(BUTTON_COUNT)

	ld r16, X+
	ld r17, X
	push r17
	push r16

	ldi r17, high(DISPLAY_TEXT)
	push r17
	ldi r16, low(DISPLAY_TEXT)
	push r16
	rcall to_decimal_text
	pop r16
	pop r17
	pop r16
	pop r17

	lds r16,DISPLAY_TEXT+0
	push r16
	rcall lcd_putchar
	pop r16

	lds r16,DISPLAY_TEXT+1
	push r16
	rcall lcd_putchar
	pop r16

	lds r16,DISPLAY_TEXT+2
	push r16
	rcall lcd_putchar
	pop r16

	lds r16,DISPLAY_TEXT+3
	push r16
	rcall lcd_putchar
	pop r16

	lds r16,DISPLAY_TEXT+4
	push r16
	rcall lcd_putchar
	pop r16

	pop XL
	pop XH
	pop r17
	pop r16

	ret

to_decimal_text:;reference: hex_to_decimal from Zester
	push r16//countH
	push r17//countL
	push r18//factorH
	push r24//factorL
	push r20//multiple
	push r21//pos
	push r22//zero
	push r23//ascii_zero
	push YH
	push YL
	push ZH
	push ZL

	in YH,SPH
	in YL,SPL
	ldd r16,Y+19
	ldd r17,Y+18

	andi r16,0b01111111
	clr r22
	clr r21
	ldi r23,'0'
	to_decimal_next:
		clr r20

	to_decimal_10000:
		cpi r21,0
		brne to_decimal_1000
		ldi r24,low(10000)
		ldi r18,high(10000)
		rjmp to_decimal_loop

	to_decimal_1000:
		cpi r21,1
		brne to_decimal_100
		ldi r24,low(1000)
		ldi r18,high(1000)
		rjmp to_decimal_loop

	to_decimal_100:
		cpi r21,2
		brne to_decimal_10
		ldi r24,low(100)
		ldi r18,high(100)
		rjmp to_decimal_loop

	to_decimal_10:
		cpi r21,3
		brne to_decimal_1
		ldi r24,low(10)
		ldi r18,high(10)
		rjmp to_decimal_loop

	to_decimal_1:
		mov r20,r17
		rjmp to_decimal_write

	to_decimal_loop:
		inc r20
		sub r17,r24
		sbc r16,r18
		brpl to_decimal_loop
		dec r20
		add r17,r24
		adc r16,r18

	to_decimal_write:
		ldd ZH,Y+17
		ldd ZL,Y+16
		add ZL,r21
		adc ZH,r22
		add r20,r23

	st Z,r20

	inc r21
	cpi r21,5
	breq to_decimal_exit
	rjmp to_decimal_next

	to_decimal_exit:
		pop ZL
		pop ZH
		pop YL
		pop YH
		pop r23
		pop r22
		pop r21
		pop r20
		pop r24
		pop r18
		pop r17
		pop r16

	ret

timer1:

	push r16
	push r17
	in r16, SREG
	push r16
	lds r16, PULSE
	push r17
	ldi r17, 0x01
	eor r16, r17
	sts PULSE, r16
	out SREG, r16
	pop r17
	pop r16
	pop r17
	pop r16
		
	reti

; Note there is no "timer3" interrupt handler as we must use this
; timer3 in a polling style within our main program.


	
timer4:
	push ZH
	push ZL
	push r16
	push r17
	push r18
	push r19
	in ZH, SPH
	in ZL, SPL

	in r16, SREG
	push r16

	lds r16, ADCSRA
	ori r16, 0x40
	sts ADCSRA, r16

timer_4_delay:
	lds r16, ADCSRA
	andi r16, 0x40
	brne timer_4_delay

	lds r16, BUTTON_CURRENT
	sts BUTTON_PREVIOUS, r16

	lds r16, ADCH
	cpi r16, 0x03
	brlo button_push
	clr r16

	sts BUTTON_CURRENT, r16

	rjmp timer4_exit

button_push:
	ldi r16, 0x01
	sts BUTTON_CURRENT, r16
	lds r17, BUTTON_PREVIOUS
	cp r16, r17
	breq timer4_exit

	ldi r18, 0x01
	clr r19
	lds ZL, BUTTON_COUNT
	lds ZH, BUTTON_COUNT+1
	add ZL, r18
	adc ZH, r19
	sts BUTTON_COUNT, ZL 
	sts BUTTON_COUNT+1, ZH

timer4_exit:
	pop r16
	out SREG, r16
	pop r19
	pop r18
	pop r17
	pop r16
	pop ZL
	pop ZH
    reti




; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION ********** 
; ***************************************************


; ################################################
; #### BEGINNING OF "TOUCH CAREFULLY" SECTION ####
; ################################################

; The purpose of these locations in data memory are
; explained in the assignment description.
;

.dseg

PULSE: .byte 1
COUNTER: .byte 2
DISPLAY_TEXT: .byte 16
BUTTON_CURRENT: .byte 1
BUTTON_PREVIOUS: .byte 1
BUTTON_COUNT: .byte 2
BUTTON_LENGTH: .byte 1
DOTDASH_PATTERN: .byte MAX_PATTERN_LENGTH


; ##########################################
; #### END OF "TOUCH CAREFULLY" SECTION ####
; ##########################################
