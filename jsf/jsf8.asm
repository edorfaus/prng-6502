.segment "RAM"

; JSF8_State is the internal state of the JSF8 PRNG.
; This should not be changed, except just before a call JSF8_Init.
; After a call to JSF8_Next, the first byte holds the generated value.
JSF8_State: .res 4

.segment "LIBCODE"

; JSF8_Init initializes the PRNG with the given seed.
; On entry, the intended seed must be in the first byte of JSF8_State.
; Clobbers: A, X, Y
JSF8_Init:
	; a = 0xED
	lda #$ED
	sta JSF8_State+3
	; b = c = d = seed
	lda JSF8_State+0
	sta JSF8_State+1
	sta JSF8_State+2
	; advance the state 20 times
	ldy #20
	:
		jsr JSF8_Next
		dey
	bne :-
	rts

; JSF8_Next generates the next PRNG value, returning it in A.
; That value will also be available as the first byte of JSF8_State.
; Clobbers: A, X
JSF8_Next:
	; These are in reverse order because that makes it easier for other
	; code to use the D value as the produced PRNG value (and for giving
	; the seed value when initializing it).
	@d = JSF8_State+0
	@c = JSF8_State+1
	@b = JSF8_State+2
	@a = JSF8_State+3
	; tmp = rot(b, 1)
	; 6502 only has rotate through carry, which is not what we want.
	lda @b
	asl
	lda @b
	rol
	; tmp = -tmp
	eor #$FF
	sec
	; e = tmp + a ; thus e = a - rot(b, 1)
	adc @a
	tax

	; tmp = rot(c, 4) ; using a as scratch space
	lda @c
	sta @a
	.repeat 4
		asl @a
		rol
	.endrepeat
	; a = tmp ^ b ; thus a = b ^ rot(c, 4)
	eor @b
	sta @a

	; b = c + d
	clc
	lda @c
	adc @d
	sta @b

	; c = e + d
	clc
	txa
	adc @d
	sta @c

	; d = e + a
	clc
	txa
	adc @a
	sta @d

	; return d
	rts
