	.org $8000
reset:
	lda #$ff
	sta $6002
blink:
	lda #$55
	sta $6000

wait_button:
	lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    bne wait_button
	lda #$aa
	sta $6000

wait_button2:
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    bne wait_button_2
    jmp blink

loop:
	jmp loop
	.org $fffc
	.word reset
	.word $0000
