PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
button  = $0200 ; 1 byte
wait_1  = $0201 ; 1 byte
wait_2  = $0202 ; 1 byte

	.org $8000

reset:
	lda #$ff
	sta DDRB
	lda #$E0 ; %11100000 set pin 0-2 on port A as output
	sta DDRA
	lda #$00
	sta button
	sta wait_1
	sta wait_2

update_led:
	lda button
	sta PORTB
	jsr wait
	inc button
	jmp update_led

wait:
	inc wait_1
	lda wait_1
	cmp #$ff
    bne wait;
	lda #$00
	sta wait_1
	inc wait_2
	lda wait_2
	cmp #$ff
    bne wait;
    rts

	.org $fffc
	.word reset
	.word $0000
