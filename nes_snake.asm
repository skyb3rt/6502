reset:
	lda #$05
	sta $0020 ; antall
	lda #$00
	sta $0021 ; posisjon
	lda #$03
	sta $0022 ; wait

first:
	ldx $0021
	lda #$05
	sta $0200,x
	inc $0021
	iny
	cpy $0020
	bne first
	jmp clear
loop:
	ldx $0021
	lda #$05
	sta $0200,x
	inc $0021
	ldy #$00 
	jsr wait_sub
clear:
	lda #$11
	sta $00
	ldx $0021
	txa
	sbc $0020
	tax
	lda #$00
	sta $0200,x
	sta $00
	jmp loop

done:
	jmp done

wait_sub:
	lda #$00
	sta $0010
	sta $0011
wait:	
	inc $0010
	lda $0010
	cmp #$20
	bne wait
	lda #$00
	sta $0010
	inc $0011
	lda $0011
	cmp $0022
	bne wait 
	rts
	