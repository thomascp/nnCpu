
	add		r1, r0, r0
	add		r2, r0, r0
	add		r3, r0, r0
	luil	r3, low(VALUE)
	luih	r3, high(VALUE)
	luil	r4, 1

START:

	ldr		r7, r3, r0
	add		r7, r7, r4
	str		r7, r3, r0
	luil		r5, low(START)
	luih		r5, high(START)
	jne		r5, r31, r0

VALUE:
	add		r1, r0, r0
