; This is an implementation of the Fast Dice Roller algorithm, that
; generates a random number within a range in an unbiased way, given
; the output of a PRNG that generates random bits.
;
; This version of it is intended to be simple and straightforward, to
; aid in readability, rather than trying to be fast or featureful.
;
; As such, it uses named variables, does not try to optimize, and only
; supports ranges that start at 0, and ends at a value less than 0x80.
;
; This assumes that you have a GetNextRandomBitInA subroutine that
; generates a random bit and returns it in the low bit of A.

.segment "RAM"

; The maximum value that can be returned by this call to the algorithm.
MaxInclusive: .res 1

TmpX: .res 1
TmpY: .res 1

.segment "LIBCODE"

FDR7_Simple:
	lda #1
	sta TmpX
	lda #0
	sta TmpY
@loop:
	asl TmpX ; x = x * 2

	jsr GetNextRandomBitInA
	lsr a

	rol TmpY ; y = y * 2 + randomBit

	; if x > maxInclusive (otherwise go back up to the loop)
	lda MaxInclusive
	cmp TmpX
	bcs @loop

	; if y <= maxInclusive, then we're done
	lda MaxInclusive
	cmp TmpY
	bcs @done

	; Rejection
	; x = x - maxInclusive - 1
	lda TmpX
	sec
	sbc MaxInclusive
	sbc #1
	sta TmpX

	; y = y - maxInclusive - 1
	lda TmpY
	sec
	sbc MaxInclusive
	sbc #1
	sta TmpY

	jmp @loop

@done:
	lda TmpY ; Return the generated value in A
	rts
