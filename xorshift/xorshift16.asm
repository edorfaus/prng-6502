.segment "RAM"

; Xorshift16_State is the internal state of the Xorshift16 PRNG.
; This must be initialized to a non-zero value before the PRNG is used.
; After a call to Xorshift16_Next, this holds the generated value.
Xorshift16_State: .res 2

.segment "LIBCODE"

; Xorshift16_Next generates the next PRNG value, returning it in the
; value of Xorshift16_State.
; On entry, Xorshift16_State must be non-zero.
; Clobbers: A
Xorshift16_Next:
	; xs ^= xs << 7
	lda Xorshift16_State+1
	lsr                    ; carry = bit 0 of high byte
	lda Xorshift16_State+0
	ror                    ; A = HLLL_LLLL, carry = bit 0 of low byte
	eor Xorshift16_State+1
	sta Xorshift16_State+1

	; xs ^= xs >> 9 ; combined with bottom bit of the above xs << 7
	lda Xorshift16_State+1
	ror                    ; A = LHHH_HHHH
	eor Xorshift16_State+0
	sta Xorshift16_State+0

	; xs ^= xs << 8
	;lda Xorshift16_State+0 ; this value is already in A
	eor Xorshift16_State+1
	sta Xorshift16_State+1

	; return xs
	rts
