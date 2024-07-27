.segment "INESHDR"
	; Mapper 0, 32K PRG, 0K CHR, no wram/bram, H mirroring, NTSC
	.byte $4E, $45, $53, $1A, $02, 0, 0, $08, 0, 0, 0, $07, 0, 0, 0, 0

.segment "VECTORS"
	.word IRQ, RESET, IRQ

.include "jsf32.asm"

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

	jsr JSF32_Init
	jsr VerifyState

	lda #4
	sta testCount
	:
		jsr JSF32_Next
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
		sta JSF32_State, y
		iny
		cpy #.sizeof(JSF32_State)
	bne :-
	sty curIndex
	rts

VerifyState:
	ldy curIndex
	ldx #0
	:
		lda (ptrTest), y
		cmp JSF32_State, x
		bne VerifyStateFailed
		iny
		inx
		cpx #.sizeof(JSF32_State)
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
	.dword $00000000, $00000000, $00000000, $00000000
	.dword $7A484BC9, $44D68D47, $0D3D55A3, $1B517AA6
	.dword $1A9B6C07, $7D2FDBC2, $BF1ED910, $17B3DC0E
	.dword $9A550895, $AC56514D, $97CB47C9, $089A234F
	.dword $F12BE876, $5630D1A6, $46AB59E2, $35501F65
	.dword $0902BA19, $1446AD0C, $475CBA1C, $E5E7F583

Test0b:
	.dword $00000000, $12345678, $FEDCBA98, $456789AB
	.dword $7A484BC9, $44D68D47, $0D3D55A3, $1B517AA6
	.dword $1A9B6C07, $7D2FDBC2, $BF1ED910, $17B3DC0E
	.dword $9A550895, $AC56514D, $97CB47C9, $089A234F
	.dword $F12BE876, $5630D1A6, $46AB59E2, $35501F65
	.dword $0902BA19, $1446AD0C, $475CBA1C, $E5E7F583

Test1:
	.dword $CCCCCCCC, $00000000, $00000000, $00000000
	.dword $AFF36E5C, $9AF75A93, $835EFC20, $466DEA35
	.dword $78CCBC22, $F24660B0, $4AEAC8EF, $3679C9CE
	.dword $47AD9FEA, $34EF2FA9, $6B131CD2, $8B8B2C63
	.dword $2C740889, $3FE03367, $7C9CCF93, $3441750C
	.dword $B2AF3EE3, $C4D09719, $6C543BF0, $1A52B053

Test1b:
	.dword $CCCCCCCC, $12345678, $FEDCBA98, $456789AB
	.dword $AFF36E5C, $9AF75A93, $835EFC20, $466DEA35
	.dword $78CCBC22, $F24660B0, $4AEAC8EF, $3679C9CE
	.dword $47AD9FEA, $34EF2FA9, $6B131CD2, $8B8B2C63
	.dword $2C740889, $3FE03367, $7C9CCF93, $3441750C
	.dword $B2AF3EE3, $C4D09719, $6C543BF0, $1A52B053
