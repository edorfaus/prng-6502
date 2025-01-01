; This is an implementation of the Fast Dice Roller algorithm, that
; generates a random number within a range in an unbiased way, given
; the output of a PRNG that generates random bits.

; This version of it is limited to generating numbers from 0 to the max
; value of the range, which must be below $80.
;
; This assumes that you have a GetRandomByte subroutine that generates a
; random byte and returns it in A.
;
; This version does not cache random bits between calls, and therefore
; always calls GetRandomByte at least once per call.

.segment "ZEROPAGE"

; The maximum value that can be returned by this call to FDR7.
; This must be below $80 (cannot have the high bit set).
MaxInclusive: .res 1

; Temporary variables used inside the subroutine. Can be replaced with
; your own temporaries by changing the locals at the top of the routine.
TmpResult: .res 1
TmpRngVal: .res 1
TmpScale:  .res 1

.segment "LIBCODE"

; FDR7 returns a random integer in the range 0 through @maxInclusive, by
; running the Fast Dice Roller algorithm on the output of GetRandomByte.
; Note: if @maxInclusive is negative, this will run forever.
; On exit, the generated value will be in A.
; Clobbers: A, X, @result, @prngByte, @valScale, what GetRandomByte does
FDR7:
	; Variable assignment, in case you have usable temporaries already.
	@maxInclusive = MaxInclusive ; input: target range (max value)
	@result   = TmpResult ; temp+output: generated result value
	@prngByte = TmpRngVal ; temp: value gotten from the PRNG
	@valScale = TmpScale  ; temp: scale of the current working value

	lda #1
	sta @valScale
	lda #0
	sta @result

@getRandomByte:
	jsr GetRandomByte
	sta @prngByte
	ldx #8-1 ; bits remaining in @prngByte, after the code we jump to
	jmp @gotRandomBit ; 3 cycles is faster than 2*2

@loop:
	; Get the next random bit
	dex
	bmi @getRandomByte

@gotRandomBit:
	lsr @prngByte ; move next random bit into carry
	rol @result   ; y = y * 2 + randomBit

	asl @valScale ; x = x * 2

	; if x > maxInclusive (otherwise loop to add the next bit)
	lda @maxInclusive
	cmp @valScale
	bcs @loop

	; if y <= maxInclusive, then we're done
	;lda @maxInclusive
	cmp @result
	bcc @rejected

	lda @result
	rts

@rejected:
	; Rejection: we have enough bits, but the value was too large

	; x = x - maxInclusive - 1
	lda @valScale
	; clc ; Clear to get the -1 ; Carry is clear here (due to bcs above)
	sbc @maxInclusive
	sta @valScale

	; y = y - maxInclusive - 1
	lda @result
	clc ; Clear to get the -1
	sbc @maxInclusive
	sta @result

	jmp @loop
