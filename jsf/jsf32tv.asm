; This variant of 32-bit JSF uses some temporary variables instead of
; the stack, which is a bit smaller and faster - but requires having
; those variables available for use when called.
;
; These variables are required: TmpA, TmpB, TmpC, TmpD.
; Only the first byte of each variable is used.

.segment "RAM"

; JSF32_State is the internal state of the JSF32 PRNG.
; This should not be changed, except just before a call to JSF32_Init.
; After a call to JSF32_Next, the first word holds the generated value.
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
; Clobbers: A, X, Y, TmpA, TmpB, TmpC, TmpD
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
; Clobbers: A, X, TmpA, TmpB, TmpC, TmpD
JSF32_Next:
	_set_jsf32_state_vars

	; Progression of which word contains what value:
	; a      b   c   d   e     | Action leading to next row
	; A0     B0  C0  D0  -     | e = rot(b, 3*8) ; 27 = 3*8 + 3
	; A0     B0  C0  D0  B0r24 | e = rot(e, 3) = rot(b, 27)
	; A0     B0  C0  D0  B0r27 | e = a - e = a - rot(b, 27)
	; -      B0  C0  D0  E     | a = rot(c, 17) ; 17 = 2*8 + 1
	; C0r17  B0  C0  D0  E     | a = b ^ a = b ^ rot(c, 17)
	; A1     -   C0  D0  E     | b = c + d
	; A1     B1  -   D0  E     | c = d + e
	; A1     B1  C1  -   E     | d = e + a
	; A1     B1  C1  D1  -     |

	; e = rot(b, 3*8) ; 27 = 3*8 + 3 ; also, left 3*8 == right 1*8
	lda @b+1
	sta TmpA
	lda @b+2
	sta TmpB
	lda @b+3
	sta TmpC
	lda @b+0
	sta TmpD

	; e = rot(e, 3) = rot(b, 27)
	;lda TmpD
	ldx #3
	:
		asl
		rol TmpA
		rol TmpB
		rol TmpC
		rol TmpD
	dex
	bne :-

	; e = a - e = a - rot(b, 27)
	sec
	lda @a+0
	sbc TmpA
	sta TmpA
	lda @a+1
	sbc TmpB
	sta TmpB
	lda @a+2
	sbc TmpC
	sta TmpC
	lda @a+3
	sbc TmpD
	sta TmpD

	; a = rot(c, 17) ; 17 = 2*8 + 1
	lda @c+3
	asl
	.repeat 4, i
		lda @c+i
		rol
		sta @a+((2+i) .mod 4)
	.endrepeat

	; a = b ^ a = b ^ rot(c, 17)
	.repeat 4, i
		lda @b+i
		eor @a+i
		sta @a+i
	.endrepeat

	; b = c + d
	clc
	.repeat 4, i
		lda @c+i
		adc @d+i
		sta @b+i
	.endrepeat

	; c = d + e
	clc
	lda @d+0
	adc TmpA
	sta @c+0
	lda @d+1
	adc TmpB
	sta @c+1
	lda @d+2
	adc TmpC
	sta @c+2
	lda @d+3
	adc TmpD
	sta @c+3

	; d = a + e
	clc
	lda @a+0
	adc TmpA
	sta @d+0
	lda @a+1
	adc TmpB
	sta @d+1
	lda @a+2
	adc TmpC
	sta @d+2
	lda @a+3
	adc TmpD
	sta @d+3

	; return d
	rts

.delmacro _set_jsf32_state_vars
