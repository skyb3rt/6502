PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000

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
    jsr lcd_clear

write:
    ldx #0
write_1:
    lda message_1,x
    beq write_2
    jsr lcd_write_char
    inx
    jmp write_1 

write_2:    
    ldx #0
    jsr lcd_line_2
write_2_next:
    lda message_2,x
    beq loop
    jsr lcd_write_char
    inx
    jmp write_2_next 
    
loop:
    jmp loop

message_1: .asciiz 'TLF:'
message_2: .asciiz '  95555588'

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


lcd_line_2:
    lda #%11000001 ; line2 pos1
    jsr lcd_instruction
    rts
lcd_clear:
    lda #$00000001 ; clear screen
    jsr lcd_instruction
    rts


	.org $fffc
	.word reset
	.word $0000

