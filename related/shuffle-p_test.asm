.feature underline_in_numbers

.segment "INESHDR"
	; Mapper 0, 32K PRG, 0K CHR, no wram/bram, H mirroring, NTSC
	.byte $4E, $45, $53, $1A, $02, 0, 0, $08, 0, 0, 0, $07, 0, 0, 0, 0

.segment "VECTORS"
	.word IRQ, RESET, IRQ

.include "shuffle-p.asm"

.segment "ZEROPAGE"
curTest: .res 1
ptrTest: .res 2
curIndex: .res 1
testCount: .res 1

ptrVerifyData: .res 2

MaxInclusive: .res 1

ExpectedMaxInc: .res 1

.segment "RAM"
.align 256
DataArray: .res 256

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
	sta testCount

	lda #.lobyte(DataArray)
	sta ptrShuffleData+0
	lda #.hibyte(DataArray)
	sta ptrShuffleData+1

TestLoop:
	jsr InitTest
	beq @doneOK

	jsr LoadState

	jsr Shuffle

	jsr VerifyState
	jsr VerifyValue

	inc curTest
	jmp TestLoop

	@doneOK:
	brk
	nop ; because brk skips a byte
	@doneOKLoop:
	jmp @doneOKLoop

InitTest:
	lda curTest
	asl
	tax
	lda Tests+0, x
	sta ptrTest+0
	lda Tests+1, x
	sta ptrTest+1
	beq @done

	ldy #0
	lda ptrTest+0
	sec ; for another +1
	adc (ptrTest), y
	sta ptrVerifyData+0
	lda ptrTest+1
	adc #0
	sta ptrVerifyData+1

	@done:
	rts

LoadState:
	ldy #0
	lda (ptrTest), y
	sta ExpectedMaxInc
	sta MaxInclusive
	iny
	sty curIndex

	ldx #0
	lda #10
	@loop:
		sta DataArray, x
		clc
		adc #1
		inx
	bne @loop

	rts

VerifyState:
	ldy #0
	lda (ptrTest), y
	clc
	adc #1
	cmp curIndex
	bne @verifyStateFailed

	ldy #1
	lda ExpectedMaxInc
	cmp #0
	bne @verifyStateFailed

	ldy #2
	lda ptrShuffleData+0
	cmp #.lobyte(DataArray)
	bne @verifyStateFailed
	lda ptrShuffleData+1
	cmp #.hibyte(DataArray)
	bne @verifyStateFailed

	rts

	@verifyStateFailed:
	brk
	nop ; because brk skips a byte
	@verifyStateFailedLoop:
	jmp @verifyStateFailedLoop

VerifyValue:
	ldy #0
	lda (ptrTest), y
	tax
	inx
	@loop:
		lda (ptrVerifyData), y
		cmp DataArray, y
		bne @verifyValueFailed

		iny
		dex
	bne @loop
	rts

	@verifyValueFailed:
	brk
	nop ; because brk skips a byte
	@verifyValueFailedLoop:
	jmp @verifyValueFailedLoop

GetRandomByteInRange:
	lda MaxInclusive
	beq @failedMaxInclusive
	cmp ExpectedMaxInc
	bne @failedMaxInclusive

	dec ExpectedMaxInc

	ldy curIndex
	lda (ptrTest), y
	iny
	sty curIndex

	rts

	@failedMaxInclusive:
	brk
	nop
	@failedMaxInclusiveLoop:
	jmp @failedMaxInclusiveLoop

.segment "DATA"

Tests:
	.word Test0
	.word Test1
	.word Test2
	.word Test3
	.word Test4
	.word Test5
	.word Test6
	.word 0

Test0:
	.byte :++ - :+
	:
	: .byte 10

Test1:
	.byte :++ - :+
	: .byte 0
	: .byte 11, 10

Test2:
	.byte :++ - :+
	: .byte 1
	: .byte 10, 11

Test3:
	.byte :++ - :+
	: .byte 7, 6, 5, 4, 3, 2, 1
	: .byte 10, 11, 12, 13, 14, 15, 16, 17

Test4:
	.byte :++ - :+
	: .byte 0, 0, 0, 0, 0, 0, 0
	: .byte 11, 12, 13, 14, 15, 16, 17, 10

Test5:
	.byte :++ - :+
	: .byte 3, 3, 2, 2, 1, 1, 0
	: .byte 14, 10, 16, 11, 15, 12, 17, 13

Test6:
	.byte :++ - :+
	: .byte 127, 127, 126, 126, 125, 125, 124, 124, 123, 123, 122, 122
	.byte 121, 121, 120, 120, 119, 119, 118, 118, 117, 117, 116, 116
	.byte 115, 115, 114, 114, 113, 113, 112, 112, 111, 111, 110, 110
	.byte 109, 109, 108, 108, 107, 107, 106, 106, 105, 105, 104, 104
	.byte 103, 103, 102, 102, 101, 101, 100, 100, 99, 99, 98, 98, 97, 97
	.byte 96, 96, 95, 95, 94, 94, 93, 93, 92, 92, 91, 91, 90, 90, 89, 89
	.byte 88, 88, 87, 87, 86, 86, 85, 85, 84, 84, 83, 83, 82, 82, 81, 81
	.byte 80, 80, 79, 79, 78, 78, 77, 77, 76, 76, 75, 75, 74, 74, 73, 73
	.byte 72, 72, 71, 71, 70, 70, 69, 69, 68, 68, 67, 67, 66, 66, 65, 65
	.byte 64, 64, 63, 63, 62, 62, 61, 61, 60, 60, 59, 59, 58, 58, 57, 57
	.byte 56, 56, 55, 55, 54, 54, 53, 53, 52, 52, 51, 51, 50, 50, 49, 49
	.byte 48, 48, 47, 47, 46, 46, 45, 45, 44, 44, 43, 43, 42, 42, 41, 41
	.byte 40, 40, 39, 39, 38, 38, 37, 37, 36, 36, 35, 35, 34, 34, 33, 33
	.byte 32, 32, 31, 31, 30, 30, 29, 29, 28, 28, 27, 27, 26, 26, 25, 25
	.byte 24, 24, 23, 23, 22, 22, 21, 21, 20, 20, 19, 19, 18, 18, 17, 17
	.byte 16, 16, 15, 15, 14, 14, 13, 13, 12, 12, 11, 11, 10, 10, 9, 9
	.byte 8, 8, 7, 7, 6, 6, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1, 0
	: .byte 138, 10, 202, 11, 170, 12, 234, 13, 154, 14, 186, 15, 218
	.byte 16, 250, 17, 146, 18, 162, 19, 178, 20, 194, 21, 210, 22, 226
	.byte 23, 242, 24, 2, 25, 142, 26, 150, 27, 158, 28, 166, 29, 174
	.byte 30, 182, 31, 190, 32, 198, 33, 206, 34, 214, 35, 222, 36, 230
	.byte 37, 238, 38, 246, 39, 254, 40, 6, 41, 140, 42, 144, 43, 148
	.byte 44, 152, 45, 156, 46, 160, 47, 164, 48, 168, 49, 172, 50, 176
	.byte 51, 180, 52, 184, 53, 188, 54, 192, 55, 196, 56, 200, 57, 204
	.byte 58, 208, 59, 212, 60, 216, 61, 220, 62, 224, 63, 228, 64, 232
	.byte 65, 236, 66, 240, 67, 244, 68, 248, 69, 252, 70, 0, 71, 4, 72
	.byte 8, 73, 139, 74, 141, 75, 143, 76, 145, 77, 147, 78, 149, 79
	.byte 151, 80, 153, 81, 155, 82, 157, 83, 159, 84, 161, 85, 163, 86
	.byte 165, 87, 167, 88, 169, 89, 171, 90, 173, 91, 175, 92, 177, 93
	.byte 179, 94, 181, 95, 183, 96, 185, 97, 187, 98, 189, 99, 191, 100
	.byte 193, 101, 195, 102, 197, 103, 199, 104, 201, 105, 203, 106
	.byte 205, 107, 207, 108, 209, 109, 211, 110, 213, 111, 215, 112
	.byte 217, 113, 219, 114, 221, 115, 223, 116, 225, 117, 227, 118
	.byte 229, 119, 231, 120, 233, 121, 235, 122, 237, 123, 239, 124
	.byte 241, 125, 243, 126, 245, 127, 247, 128, 249, 129, 251, 130
	.byte 253, 131, 255, 132, 1, 133, 3, 134, 5, 135, 7, 136, 9, 137
