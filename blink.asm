	.org $8000
reset:
	lda #$ff
	sta $6002
blink:
	lda #$55
	sta $6000
	lda #$aa
	sta $6000
	jmp blink

	.org $fffc
	.word reset
	.word $0000
