.segment "RAM"

; JSF16_State is the internal state of the JSF16 PRNG.
; This should not be changed, except just before a call JSF16_Init.
; After a call to JSF16_Next, the first word holds the generated value.
JSF16_State: .res 2*4

.segment "LIBCODE"

.macro _set_jsf16_state_vars
	; These are in reverse order because that makes it easier for other
	; code to use the D value as the produced PRNG value (and for giving
	; the seed value when initializing the PRNG).
	@d = JSF16_State+2*0
	@c = JSF16_State+2*1
	@b = JSF16_State+2*2
	@a = JSF16_State+2*3
.endmacro

; JSF16_Init initializes the PRNG with the given seed.
; On entry, the intended seed must be in the first word of JSF16_State.
; Clobbers: A, X, Y
JSF16_Init:
	_set_jsf16_state_vars
	; a = 0x5EED
	lda #$ED
	sta @a+0
	lda #$5E
	sta @a+1
	; b = c = d = seed
	lda @d+0
	sta @c+0
	sta @b+0
	lda @d+1
	sta @c+1
	sta @b+1
	; advance the state 20 times
	lda #20
	:
		pha
		jsr JSF16_Next
		pla
		sec
		sbc #1
	bne :-
	rts

; JSF16_Next generates the next PRNG value, returning it in the first
; word of JSF16_State.
; Clobbers: A, X, Y
JSF16_Next:
	_set_jsf16_state_vars
	; save B so we can use it as temporary storage for the rotation
	lda @b+1
	pha
	lda @b+0
	pha

	; tmp = rot(b, 13) = rotRight(b, 16-13) = rotRight(b, 3)
	.repeat 3
		lsr
		ror @b+1
		ror @b+0
	.endrepeat
	; e = a - tmp ; thus e = a - rot(b, 13)
	sec
	lda @a+0
	sbc @b+0
	tax
	lda @a+1
	sbc @b+1
	tay

	; a = b ^ rot(c, 8) ; rot(c, 8) is just swapping its bytes
	pla
	eor @c+1
	sta @a+0
	pla
	eor @c+0
	sta @a+1

	; b = c + d
	clc
	lda @c+0
	adc @d+0
	sta @b+0
	lda @c+1
	adc @d+1
	sta @b+1

	; c = e + d
	clc
	txa
	adc @d+0
	sta @c+0
	tya
	adc @d+1
	sta @c+1

	; d = e + a
	clc
	txa
	adc @a+0
	sta @d+0
	tya
	adc @a+1
	sta @d+1

	; return d
	rts

.delmacro _set_jsf16_state_vars
