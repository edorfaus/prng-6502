; This file implements a regular Fisher-Yates shuffle, as a macro that
; works on a given array variable directly (not via a pointer).
;
; It only works on byte arrays that are at most 256 bytes long.
;
; It assumes you have a subroutine for getting uniform random numbers in
; a given range, where the range goes from 0 to the value of a variable,
; inclusive. That subroutine and variable are given as macro arguments.

; Example usage:
; ShuffleTheArray:
;   mShuffleArray TheArray, MaxInclusive, GetRandomByteInRange
;   rts
; ...
; jsr ShuffleTheArray

; mShuffleArray expands into code for shuffling the given array, using
; the given PRNG. The prngMax variable must set the maximum value that
; the prngNext subroutine returns, which it must return in A.
; Clobbers: A, X, Y, prngMax, and whatever prngNext clobbers.
.macro mShuffleArray array, prngMax, prngNext
	.if .sizeof(array) <= 1
		.warning "the array has too few elements to be shuffled"
		.exitmacro
	.endif
	ldy #.sizeof(array)-1
	sty prngMax
	.local @loop
	@loop:
		jsr prngNext
		tax

		ldy prngMax ; Can be removed if prngNext does not clobber Y
		lda array, y

		ldy array, x
		sta array, x
		tya

		ldy prngMax
		sta array, y

		dey
		sty prngMax
	bne @loop
.endmacro

; Assuming the array and prngMax are in ZP, then the above loop takes
; 2+3+4+4+4+2+3+5+2+3+3 = 35 cycles (plus the call to prngNext) per
; iteration. The additional fixed cost is 2+3-1 = 4 cycles.
; The loop runs for one less iteration than there are array elements.
; Thus, this code takes at minimum 4+6+6+35 = 51 cycles, plus whatever
; code is in prngNext (beyond its rts).
; This register-juggling version is the fastest I've found; doing the
; swap with a ZP temporary takes one more cycle (per iteration), with
; the stack takes two more, and doing an XOR swap takes 7 more cycles.
