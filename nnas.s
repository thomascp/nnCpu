	add		r1, r0, r0
	add		r2, r0, r0
	add		r3, r0, r0
	luil	r3, 0x80
	add		r4, r0, r0
	luih	r4, 0x8000
	add		r5, r0, r0
	luih	r5, 0x8000
	luil	r5, 0x4
	add		r6, r0, r0
	luil	r6, 0x1
	luil	r10, 0x1
	# set initial value
	str		r10, r5, r0

START:

	ldr		r7, r4, r0
	add		r8, r0, r0
	luil	r8, 0x1
	and		r8, r8, r7
	luil	r9, low(LEFT_SHIFT)
	luih	r9, high(LEFT_SHIFT)
	jne		r9, r8, r0
	luil	r8, 0x2
	and		r8, r8, r7
	luil	r9, low(RIGHT_SHIFT)
	luih	r9, high(RIGHT_SHIFT)
	jne		r9, r8, r0
	luil	r9, low(NO_SHIFT)
	luih	r9, high(NO_SHIFT)
	jne		r9, r31, r0

LEFT_SHIFT:

	ldr		r7, r5, r0
	lls		r7, r7, r6
	str		r7, r5, r0
	luil	r9, low(NO_SHIFT)
	luih	r9, high(NO_SHIFT)
	jne		r9, r31, r0

RIGHT_SHIFT:

	ldr		r7, r5, r0
	lrs		r7, r7, r6
	str		r7, r5, r0

NO_SHIFT:

	add		r2, r0, r0
	luil	r9, low(TIME_DELAY)
	luih	r9, high(TIME_DELAY)

TIME_DELAY:

	add		r2, r2, r6
	jlt		r9, r2, r3

	add		r9, r0, r0
	luil	r9, low(START)
	luih	r9, high(START)
	jne		r9, r31, r0
