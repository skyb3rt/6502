;65c22
PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
PCR    = $600c
IFR    = $600d
IER    = $600e
;LCD
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000
;middle pa0
;up pa1
;down pa2
;left pa3
;right pa4
button  = $0200 ; 1bytes

    .org $8000

reset:
    ldx #$ff
    txs      ; stack pointer to 01ff
    lda #%11111111 ; set all pin on port B as output
    sta DDRB
    lda #%11100000 ; set pin 0-2 on port A as output and 3-7 as input
    sta DDRA

    lda #%00111000 ; set lcd 8-bit mode; 2 line; 5x8 font
    jsr lcd_instruction
    lda #%00001110 ; display on, cursor on; blink off
    jsr lcd_instruction
    lda #%00000110 ; increment and shift cursor, no scroll
    lda #0
    sta button
    jsr lcd_instruction
    jsr lcd_clear
    ;lda #"W"
    ;jsr lcd_write_char
main: 
    jsr read_port_a
middle:
    lda button
    cmp #%00011110
    BNE up
    jsr lcd_clear
    lda #"M"
    jsr lcd_write_char
    jmp main
up:
    lda button
    cmp #%00011101
    BNE down
    jsr lcd_clear
    lda #"U"
    jsr lcd_write_char
    jmp main
down:
    lda button
    cmp #%00011011
    BNE left
    jsr lcd_clear
    lda #"D"
    jsr lcd_write_char
    jmp main
left:
    lda button
    cmp #%00010111
    BNE right
    jsr lcd_clear
    lda #"L"
    jsr lcd_write_char
    jmp main
right:
    lda button
    cmp #%00001111
    BNE main
    jsr lcd_clear
    lda #"R"
    jsr lcd_write_char
    jmp main


loop:
    jmp loop

read_port_a:
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    beq read_port_a
    sta button
    ;jsr lcd_clear
    ;lda #"?"
    ;jsr lcd_write_char
wait:    
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    bne wait
    rts


lcd_clear:
    lda #$00000001 ; clear screen
    jsr lcd_instruction
    rts

lcd_wait_ready:
    pha
    lda #%00000000 ; set portb to input
    sta DDRB
read_BS:
    lda #LCD_RW 
    sta PORTA
    lda #(LCD_RW | LCD_E)
    sta PORTA 
    lda PORTB ; read port p
    and #%10000000
    bne read_BS ; branch if zeroflag is not set
    lda #LCD_RW
    sta PORTA
    lda #%11111111 ; set portb to output
    sta DDRB
    pla
    rts

lcd_instruction:
    jsr lcd_wait_ready
    sta PORTB
    lda #0
    sta PORTA
    lda #LCD_E
    sta PORTA
    lda #0
    sta PORTA
    rts 

lcd_write_char:
    jsr lcd_wait_ready
    sta PORTB
    lda #LCD_RS
    sta PORTA
    lda #(LCD_RS|LCD_E)
    sta PORTA
    lda #LCD_RS
    sta PORTA
    rts 

nmi:
    rti
irq:
    rti

    .org $fffa
    .word nmi
	.word reset
	.word irq

