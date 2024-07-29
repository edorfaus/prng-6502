.segment "INESHDR"
	; Mapper 0, 32K PRG, 0K CHR, no wram/bram, H mirroring, NTSC
	.byte $4E, $45, $53, $1A, $02, 0, 0, $08, 0, 0, 0, $07, 0, 0, 0, 0

.segment "VECTORS"
	.word IRQ, RESET, IRQ

.include "xorshift16.asm"

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

	;jsr Xorshift16_Init
	;jsr VerifyState

	lda #4
	sta testCount
	:
		jsr Xorshift16_Next
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
		sta Xorshift16_State, y
		iny
		cpy #.sizeof(Xorshift16_State)
	bne :-
	sty curIndex
	rts

VerifyState:
	ldy curIndex
	ldx #0
	:
		lda (ptrTest), y
		cmp Xorshift16_State, x
		bne VerifyStateFailed
		iny
		inx
		cpx #.sizeof(Xorshift16_State)
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
	.word Test1
	.word Test2
	.word Test3
	.word 0

Test0:
	.word $0000
	.word $0000
	.word $0000
	.word $0000
	.word $0000

Test1:
	.word $0001
	.word $8181
	.word $6021
	.word $E999
	.word $2E0B

Test2:
	.word $CCCC
	.word $3399
	.word $9966
	.word $5973
	.word $6383

Test3:
	.word $5555
	.word $55AA
	.word $6AEA
	.word $FAE5
	.word $A921
