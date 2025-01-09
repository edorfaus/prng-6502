; This file implements a regular Fisher-Yates shuffle, as a subroutine
; that works on an array pointed to by a specific pointer.
;
; It only works on byte arrays that are at most 256 bytes long.
;
; It assumes you have a subroutine for getting uniform random numbers in
; a given range, where the range goes from 0 to the value of a variable,
; inclusive. See the top of the Shuffle routine for the default names of
; this PRNG subroutine and variable, or to change which ones are used.

; Example usage:
; lda #.lobyte(DataArray)
; sta ptrShuffleData+0
; lda #.hibyte(DataArray)
; sta ptrShuffleData+1
; lda #.sizeof(DataArray)-1
; sta MaxInclusive
; jsr Shuffle

.segment "ZEROPAGE"

; Pointer to the data to be shuffled by the Shuffle subroutine.
ptrShuffleData: .res 2

.segment "LIBCODE"

; Shuffle shuffles the data pointed to by ptrShuffleData, up to and
; including the index given in @prngMax, by using the PRNG defined by
; @prngNext. The @prngMax variable must also set the maximum value that
; the @prngNext subroutine returns, which it must return in A.
; Clobbers: A, X, Y, @prngMax, and whatever @prngNext clobbers.
Shuffle:
	@prngNext = GetRandomByteInRange
	@prngMax  = MaxInclusive

	ldy @prngMax
	beq @done

	@loop:
		lda (ptrShuffleData), y
		pha

		jsr @prngNext
		tay

		lda (ptrShuffleData), y
		tax

		pla
		sta (ptrShuffleData), y

		ldy @prngMax
		txa
		sta (ptrShuffleData), y

		dey
		sty @prngMax
	bne @loop
	@done:

	rts

; Assuming @prngMax is in ZP, then the above loop takes
; 5+3+2+5+2+4+6+3+2+6+2+3+3 = 46 cycles (plus the call to @prngNext) per
; iteration. The additional fixed cost is 6+3+2-1+6 = 16 cycles, with a
; special case for the one-element case that takes 6+3+3+6 = 18 cycles.
; The loop runs for one less iteration than there are array elements.
