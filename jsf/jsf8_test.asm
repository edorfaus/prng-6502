.feature underline_in_numbers

.segment "INESHDR"
	; Mapper 0, 32K PRG, 0K CHR, no wram/bram, H mirroring, NTSC
	.byte $4E, $45, $53, $1A, $02, 0, 0, $08, 0, 0, 0, $07, 0, 0, 0, 0

.segment "VECTORS"
	.word IRQ, RESET, IRQ

.include "jsf8.asm"

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

	jsr JSF8_Init
	jsr VerifyState

	lda #4
	sta testCount
	:
		jsr JSF8_Next
		jsr VerifyValue
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
		sta JSF8_State, y
		iny
		cpy #.sizeof(JSF8_State)
	bne :-
	sty curIndex
	rts

VerifyState:
	ldy curIndex
	ldx #0
	:
		lda (ptrTest), y
		cmp JSF8_State, x
		bne VerifyStateFailed
		iny
		inx
		cpx #.sizeof(JSF8_State)
	bne :-
	sty curIndex
	rts

VerifyStateFailed:
	brk
	nop ; because brk skips a byte
VerifyStateFailedLoop:
	jmp VerifyStateFailedLoop

VerifyValueFailed:
	brk
	nop ; because brk skips a byte
VerifyValueFailedLoop:
	jmp VerifyValueFailedLoop

VerifyValue:
	ldy curIndex
	cmp (ptrTest), y
	bne VerifyValueFailed
	rts

.segment "DATA"

Tests:
	.word Test0
	.word Test0b
	.word Test1
	.word Test1b
	.word 0

Test0:
	.byte $00, $00, $00, $00
	.byte $09, $9F, $C6, $37
	.byte $E9, $B3, $A8, $3F
	.byte $81, $D7, $9C, $93
	.byte $3B, $DB, $58, $E1
	.byte $16, $6C, $16, $E5

Test0b:
	.byte $00, $12, $FE, $78
	.byte $09, $9F, $C6, $37
	.byte $E9, $B3, $A8, $3F
	.byte $81, $D7, $9C, $93
	.byte $3B, $DB, $58, $E1
	.byte $16, $6C, $16, $E5

Test1:
	.byte $CC, $00, $00, $00
	.byte $29, $A6, $EC, $90
	.byte $3D, $E0, $CF, $86
	.byte $A8, $24, $1D, $C1
	.byte $E6, $2F, $CC, $5F
	.byte $04, $AC, $15, $3E

Test1b:
	.byte $CC, $12, $FE, $78
	.byte $29, $A6, $EC, $90
	.byte $3D, $E0, $CF, $86
	.byte $A8, $24, $1D, $C1
	.byte $E6, $2F, $CC, $5F
	.byte $04, $AC, $15, $3E
