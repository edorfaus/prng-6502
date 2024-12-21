.segment "RAM"

; JSF32_State is the internal state of the JSF32 PRNG.
; This should not be changed, except just before a call to JSF32_Init.
; After a call to JSF32_Next, the first dword holds the generated value.
JSF32_State: .res 4*4

.segment "LIBDATA"

; Initial value for the A dword of the state when initializing the PRNG.
_JSF32_InitialA: .dword $F1EA5EED

.segment "LIBCODE"

.macro _set_jsf32_state_vars
	; These are in reverse order because that makes it easier for other
	; code to use the D dword as the produced PRNG value (and for giving
	; the seed value when initializing the PRNG).
	@d = JSF32_State+4*0
	@c = JSF32_State+4*1
	@b = JSF32_State+4*2
	@a = JSF32_State+4*3
.endmacro

; JSF32_Init initializes the PRNG with the given seed.
; On entry, the intended seed must be in the first dword of JSF32_State.
; Clobbers: A, X, Y
JSF32_Init:
	_set_jsf32_state_vars

	ldx #4-1
	:
		; a = 0xF1EA5EED
		lda _JSF32_InitialA, x
		sta @a, x
		; b = c = d = seed
		lda @d, x
		sta @c, x
		sta @b, x
		dex
	bpl :-

	; Advance the state 20 times.
	ldy #20
	:
		jsr JSF32_Next
		dey
	bne :-

	rts

; JSF32_Next generates the next PRNG value, returning it in the first
; dword of JSF32_State.
; Clobbers: A, X
JSF32_Next:
	_set_jsf32_state_vars

	; Progression of which word contains what value:
	; a      b      c   d   s  | Action leading to next row
	; A0     B0     C0  D0  -  | s = b
	; A0     B0     C0  D0  B0 | b = rot(b, 27)
	; A0     B0r27  C0  D0  B0 | b = a - b { = a - rot(b, 27) }
	; -      E      C0  D0  B0 | a = rot(c, 17)
	; C0r17  E      C0  D0  B0 | a = a ^ s { = b ^ rot(c, 17) }
	; A1     E      C0  D0  -  | s = c + d
	; A1     E      -   D0  B1 | c = d + b = d + e
	; A1     E      C1  -   B1 | d = b + a = e + a
	; A1     -      C1  D1  B1 | b = s
	; A1     B1     C1  D1  -  |

	; s = b
	lda @b+3
	pha
	lda @b+2
	pha
	lda @b+1
	pha
	lda @b+0
	pha

	; b = rot(b, 3*8) ; 27 = 3*8 + 3 ; 3*8 left = 1*8 right
	;lda @b+0
	ldx @b+1
	stx @b+0
	ldx @b+2
	stx @b+1
	ldx @b+3
	stx @b+2
	sta @b+3

	; b = rot(b, 3) ; 27 = 3*8 + 3
	;lda @b+3
	ldx #3
	:
		asl
		rol @b+0
		rol @b+1
		rol @b+2
		rol @b+3
	dex
	bne :-

	; b = a - b { = a - rot(b, 27) }
	sec
	.repeat 4, i
		lda @a+i
		sbc @b+i
		sta @b+i
	.endrepeat

	; a = rot(c, 17) ; 17 = 2*8 + 1
	lda @c+3
	asl
	.repeat 4, i
		lda @c+i
		rol
		sta @a+((2+i) .mod 4)
	.endrepeat

	; a = a ^ s { = b ^ rot(c, 17) }
	.repeat 4, i
		pla
		eor @a+i
		sta @a+i
	.endrepeat

	; s = c + d
	clc
	.repeat 4, i
		lda @c+i
		adc @d+i
		pha
	.endrepeat

	; c = d + b = d + e
	clc
	.repeat 4, i
		lda @d+i
		adc @b+i
		sta @c+i
	.endrepeat

	; d = b + a = e + a
	clc
	.repeat 4, i
		lda @b+i
		adc @a+i
		sta @d+i
	.endrepeat

	; b = s
	pla
	sta @b+3
	pla
	sta @b+2
	pla
	sta @b+1
	pla
	sta @b+0

	; return d
	rts

.delmacro _set_jsf32_state_vars
