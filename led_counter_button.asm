PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
button  = $0200 ; 1bytes
	.org $8000

reset:
	lda #$ff
	sta DDRB
	lda #$E0 ; %11100000 set pin 0-2 on port A as output
	sta DDRA
	lda #$00
	sta button

update_led:
	lda button
	sta PORTB
	jsr read_button
	jmp update_led

read_button:
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    beq read_button; button not pressed 
wait_button_release:    
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    bne wait_button_release ; button not released
	inc button
    rts	


	.org $fffc
	.word reset
	.word $0000
