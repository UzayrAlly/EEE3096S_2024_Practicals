/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
MOVS R2, #0

check_buttons:
	LDR R3, GPIOA_BASE @check for freeze
	LDR R3, [R3, #0x10]
	MOVS R4, #8
	ANDS R4, R3
	BEQ freeze

	MOVS R4, #4 @check for setting pattern
	ANDS R4, R3
	BEQ pattern

	STR R2, [R1, #0x14]

	MOVS R4, #2 @check for setting pattern
	ANDS R4, R3
	BEQ short_delay

	LDR R3, LONG_DELAY_CNT
	B start_pattern

short_delay:
	LDR R3, SHORT_DELAY_CNT

start_pattern:
	SUBS R3, #1
	BNE start_pattern

	LDR R3, GPIOA_BASE @check for freeze
	LDR R3, [R3, #0x10]
	MOVS R4, #1
	ANDS R4, R3
	BNE inc

	ADDS R2, #2
	B continue

inc:
	ADDS R2, #1

continue:
	B check_buttons

pattern:
	MOVS R2, #0xAA
	STR R2, [R1, #0x14]

hold_SW2:
	LDR R3, GPIOA_BASE @check for pattern hold
	LDR R3, [R3, #0x10]
	MOVS R4, #4
	ANDS R4, R3
	BEQ hold_SW2
	B check_buttons

freeze:
	STR R2, [R1,#0x14]

hold_SW3:
	LDR R3, GPIOA_BASE @check for freeze
	LDR R3, [R3, #0x10]
	MOVS R4, #8
	ANDS R4, R3
	BEQ hold_SW3
	B check_buttons


write_leds:
	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 600000
