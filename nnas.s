	add		r1, r0, r0
	add		r2, r0, r0
	# r4 key in
	luih		r4, 0x8000
	luil		r4, 0x0000
	# r5 vga x
	luih		r5, 0x8000
	luil		r5, 0x1000
	# r6 vga y
	luih		r6, 0x8000
	luil		r6, 0x1004
	# r7 imm 1
	add		r7, r0, r0
	luil		r7, 1
	# r8 imm 16
	add		r8, r0, r0
	luil		r8, 16

	# set initial value
	luil		r1, 0
	luih		r1, 20
	str		r1, r5, r0
	str		r1, r6, r0
START:

	ldr		r1, r4, r0
	add		r2, r0, r0
	# judge left move
	luil		r2, 0x1
	and		r2, r2, r1
	luil		r3, low(LEFT_MOVE)
	luih		r3, high(LEFT_MOVE)
	jne		r3, r2, r0
	# judge right move
	luil		r2, 0x2
	and		r2, r2, r1
	luil		r3, low(RIGHT_MOVE)
	luih		r3, high(RIGHT_MOVE)
	jne		r3, r2, r0
	# judge up move
	luil		r2, 0x4
	and		r2, r2, r1
	luil		r3, low(UP_MOVE)
	luih		r3, high(UP_MOVE)
	jne		r3, r2, r0
	# judge down move
	luil		r2, 0x8
	and		r2, r2, r1
	luil		r3, low(DOWN_MOVE)
	luih		r3, high(DOWN_MOVE)
	jne		r3, r2, r0
	# no move
	luil		r3, low(NO_MOVE)
	luih		r3, high(NO_MOVE)
	jne		r3, r31, r0

LEFT_MOVE:

	ldr		r1, r5, r0
	add		r2, r0, r0
	luil		r2, 0xffff
	and		r3, r2, r1
	sub		r3, r3, r7
	lrs		r2, r1, r8
	sub		r2, r2, r7
	lls		r2, r2, r8
	or		r1, r2, r3
	str		r1, r5, r0

	luil		r3, low(NO_MOVE)
	luih		r3, high(NO_MOVE)
	jne		r3, r31, r0

RIGHT_MOVE:

	ldr		r1, r5, r0
	add		r2, r0, r0
	luil		r2, 0xffff
	and		r3, r2, r1
	add		r3, r3, r7
	lrs		r2, r1, r8
	add		r2, r2, r7
	lls		r2, r2, r8
	or		r1, r2, r3
	str		r1, r5, r0

	luil		r3, low(NO_MOVE)
	luih		r3, high(NO_MOVE)
	jne		r3, r31, r0

UP_MOVE:

	ldr		r1, r6, r0
	add		r2, r0, r0
	luil		r2, 0xffff
	and		r3, r2, r1
	sub		r3, r3, r7
	lrs		r2, r1, r8
	sub		r2, r2, r7
	lls		r2, r2, r8
	or		r1, r2, r3
	str		r1, r6, r0

	luil		r3, low(NO_MOVE)
	luih		r3, high(NO_MOVE)
	jne		r3, r31, r0

DOWN_MOVE:

	ldr		r1, r6, r0
	add		r2, r0, r0
	luil		r2, 0xffff
	and		r3, r2, r1
	add		r3, r3, r7
	lrs		r2, r1, r8
	add		r2, r2, r7
	lls		r2, r2, r8
	or		r1, r2, r3
	str		r1, r6, r0

	luil		r3, low(NO_MOVE)
	luih		r3, high(NO_MOVE)
	jne		r3, r31, r0

NO_MOVE:

	add		r2, r0, r0
	luil		r3, low(TIME_DELAY)
	luih		r3, high(TIME_DELAY)
	add		r1, r0, r0
	luil		r1, 0x80

TIME_DELAY:

	add		r2, r2, r7
	jlt		r3, r2, r1

	add		r3, r0, r0
	luil		r3, low(START)
	luih		r3, high(START)
	jne		r3, r31, r0

