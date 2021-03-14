.text
	.global vector_start
	.global vector_end

	vector_start:
		mov	x0, x1
	vector_end:
		.space 1024, 0
.end
