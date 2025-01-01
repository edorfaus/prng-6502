.feature underline_in_numbers

.segment "INESHDR"
	; Mapper 0, 32K PRG, 0K CHR, no wram/bram, H mirroring, NTSC
	.byte $4E, $45, $53, $1A, $02, 0, 0, $08, 0, 0, 0, $07, 0, 0, 0, 0

.segment "VECTORS"
	.word IRQ, RESET, IRQ

.include "fdr7.asm"

.segment "ZEROPAGE"
; curTest is used as the current range being tested
curTest: .res 1

; testCount is used as the iteration counter for the FDR7 calls,
; and is also the RandomData value for that iteration.
testCount: .res 1

RandomData: .res 1

CountMin: .res 1
CountMax: .res 1

Counts: .res 128

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

	jsr TestRange

	jsr VerifyCountMinMax

	inc curTest
	bpl TestLoop

BeforeSecondTest:
	; Done with the first test, now re-test using the cache instead.
	brk
	nop

	lda #0
	sta curTest
	sta RandomData

TestLoop2:
	jsr InitTest

	jsr TestRange2

	jsr VerifyCountMinMax

	inc curTest
	bpl TestLoop2

DoneOK:
	brk
	nop ; because brk skips a byte
	@DoneOKLoop:
	jmp @DoneOKLoop

GetRandomByte:
	lda RandomData
	ldx #0
	stx RandomData
	rts

VerifyCountMinMax:
	lda Counts+0
	sta CountMin
	sta CountMax

	ldx curTest
	beq @loopDone
	@loop:
		lda Counts, x
		cmp CountMin
		bcs :+
			sta CountMin
		:
		cmp CountMax
		bcc :+
			sta CountMax
		:
	dex
	bne @loop
	@loopDone:

	; Check that the min is as expected
	ldx curTest
	lda ExpectedMin, x
	cmp CountMin
	bne @failedMin

	; Check that the max is at most 5 above the min
	lda CountMax
	sec
	sbc CountMin
	cmp #5+1
	bcs @failedMax

	rts

	@failedMin:
	brk
	nop
	@failedMinLoop:
	jmp @failedMinLoop

	@failedMax:
	brk
	nop
	@failedMaxLoop:
	jmp @failedMaxLoop

InitTest:
	lda #0
	sta testCount
	ldx curTest
	stx MaxInclusive

	beq @loopDone
	@loop:
		sta Counts, x
		dex
	bne @loop
	@loopDone:
	sta Counts+0

	rts

TestRange:
	@loop:
		lda testCount
		sta RandomData

		jsr FDR7_Init ; To clear the cache

		jsr FDR7

		cmp curTest
		beq :+
			bcs @failedOutOfRange
		:

		tax
		inc Counts, x

	inc testCount
	bne @loop

	rts

	@failedOutOfRange:
	brk
	nop
	@failedOutOfRangeLoop:
	jmp @failedOutOfRangeLoop

TestRange2:
	@loop:
		lda testCount
		sta FDR7_prngByte
		lda #8
		sta FDR7_prngBits

		jsr FDR7

		cmp curTest
		beq :+
			bcs @failedOutOfRange2
		:

		tax
		inc Counts, x

	inc testCount
	bne @loop

	rts

	@failedOutOfRange2:
	brk
	nop
	@failedOutOfRangeLoop2:
	jmp @failedOutOfRangeLoop2

.segment "DATA"

ExpectedMin:
	.byte 0
	.repeat 127, i
		.byte 256 / (i+1+1)
	.endrepeat
