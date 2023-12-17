PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000
value  = $0200 ; 2bytes
mod10  = $0202 ; 2 bytes
message = $0204 ; 6 bytes

    .org $8000

reset:
    ldx #$ff
    txs      ; stack pointer to 01ff
    lda #%11111111 ; set all pin on port B as output
    sta DDRB
    lda #%11100000 ; set pin 0-2 on port A as output
    sta DDRA

    lda #%00111000 ; set lcd 8-bit mode; 2 line; 5x8 font
    jsr lcd_instruction
    lda #%00001110 ; display on, cursor on; blink off
    jsr lcd_instruction
    lda #%00000110 ; increment and shift cursor, no scroll
    jsr lcd_instruction
    lda #$00000001 ; clear screen
    jsr lcd_instruction

    lda #0
    sta message
    ; init value to number to convert
    lda number
    sta value
    lda number +1
    sta value +1
divide:
    ; init the remainder to zero
    lda #0
    sta mod10
    sta mod10 +1
    clc ; clear carry bit


    ldx #16
divloop:    
    ; rotate quotient and remainder
    rol value
    rol value +1
    rol mod10
    rol mod10 +1

    ;a,y = divident - divisor
    sec 
    lda mod10
    sbc #10
    tay ; save low byte in Y
    lda mod10 + 1
    sbc #0
    bcc ignore_result ; branch if dividend < divisor
    sty mod10
    sta mod10 + 1

ignore_result:
    dex ; dec x
    bne divloop 
    rol value; shit in the last bit of the quotient
    rol value +1

    lda mod10
    clc
    adc #"0"
    jsr push_char

    ; if value !=0, continue
    lda value
    ora value +1
    bne divide ; branch of value not zero

    ldx #0
print:
    lda message,x
    beq loop
    jsr lcd_write_char
    inx
    jmp print

    
loop:
    jmp loop

number: .word 1729

; add char in A of the beginning of message
push_char:
    pha ; push char onto stack
    ldy #0
char_loop:

    lda message,y
    tax
    pla
    sta message,y
    iny
    txa
    pha
    bne char_loop
    pla
    sta message,y 
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

	.org $fffc
	.word reset
	.word $0000

