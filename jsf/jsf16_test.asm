.feature underline_in_numbers

.segment "INESHDR"
	; Mapper 0, 32K PRG, 0K CHR, no wram/bram, H mirroring, NTSC
	.byte $4E, $45, $53, $1A, $02, 0, 0, $08, 0, 0, 0, $07, 0, 0, 0, 0

.segment "VECTORS"
	.word IRQ, RESET, IRQ

.include "jsf16.asm"

.segment "ZEROPAGE"
curTest: .res 1
ptrTest: .res 2
curIndex: .res 1
testCount: .res 1

.segment "CODE"

IRQ:
	rti

RESET:
	sei
	cld
	ldx #$FF
	txs

	lda #0
	sta curTest

TestLoop:
	jsr InitTest
	beq DoneOK

	jsr LoadState

	jsr JSF16_Init
	jsr VerifyState

	lda #4
	sta testCount
	:
		jsr JSF16_Next
		jsr VerifyState

		dec testCount
	bne :-

	inc curTest
	jmp TestLoop

DoneOK:
	brk
	nop ; because brk skips a byte
DoneOKLoop:
	jmp DoneOKLoop

InitTest:
	lda curTest
	asl
	tax
	lda Tests+0, x
	sta ptrTest+0
	lda Tests+1, x
	sta ptrTest+1
	rts

LoadState:
	ldy #0
	:
		lda (ptrTest), y
		sta JSF16_State, y
		iny
		cpy #.sizeof(JSF16_State)
	bne :-
	sty curIndex
	rts

VerifyState:
	ldy curIndex
	ldx #0
	:
		lda (ptrTest), y
		cmp JSF16_State, x
		bne VerifyStateFailed
		iny
		inx
		cpx #.sizeof(JSF16_State)
	bne :-
	sty curIndex
	rts

VerifyStateFailed:
	brk
	nop ; because brk skips a byte
VerifyStateFailedLoop:
	jmp VerifyStateFailedLoop

.segment "DATA"

Tests:
	.word Test0
	.word Test0b
	.word Test1
	.word Test1b
	.word 0

Test0:
	.word $0000, $0000, $0000, $0000
	.word $5DB9, $2E65, $64AA, $57B0
	.word $0C9F, $68D4, $8C1E, $0184
	.word $8877, $3CA0, $7573, $5876
	.word $BF17, $723F, $C517, $D54F
	.word $D712, $9BC4, $3156, $FA65

Test0b:
	.word $0000, $1234, $FEDC, $789A
	.word $5DB9, $2E65, $64AA, $57B0
	.word $0C9F, $68D4, $8C1E, $0184
	.word $8877, $3CA0, $7573, $5876
	.word $BF17, $723F, $C517, $D54F
	.word $D712, $9BC4, $3156, $FA65

Test1:
	.word $CCCC, $0000, $0000, $0000
	.word $3864, $5B77, $2BDA, $F164
	.word $086A, $E44D, $93DB, $5C81
	.word $C845, $F270, $ECB7, $DE3F
	.word $7CEE, $A8EE, $BAB5, $9C45
	.word $390C, $61DD, $25DC, $541D

Test1b:
	.word $CCCC, $1234, $FEDC, $789A
	.word $3864, $5B77, $2BDA, $F164
	.word $086A, $E44D, $93DB, $5C81
	.word $C845, $F270, $ECB7, $DE3F
	.word $7CEE, $A8EE, $BAB5, $9C45
	.word $390C, $61DD, $25DC, $541D
