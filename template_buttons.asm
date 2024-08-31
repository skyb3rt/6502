PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000

;middle pa0
;up pa1
;down pa2
;left pa3
;right pa4
button  = $0200 ; 1bytes
output  = $0201

    .org $8000
reset:
    ldx #$ff
    txs                 ; stack pointer to 01ff
via:
    lda #$ff
    sta DDRB            ; PORTB: set all pins as output
    lda #%11100000
    sta DDRA            ; PORTA: set pin 0-2 as output and 3-7 as input
lcd:
    lda #%00111000      ; set lcd 8-bit mode; 2 line; 5x8 font
    jsr lcd_instruction
    lda #%00001110      ; display on, cursor on; blink off
    jsr lcd_instruction
    lda #%00000110      ; increment and shift cursor, no scroll
    jsr lcd_instruction
    jsr lcd_clear       ; clear LCD


loop:
    jsr read_port_a
middle:
    lda button
    cmp #%00011110
    bne up
    lda #"M"
    sta output
    jsr lcd_write_output
    jmp loop
up:
    lda button
    cmp #%00011101
    bne down
    jsr lcd_clear
    lda #"U"
    jsr lcd_write_char
    jmp loop
down:
    lda button
    cmp #%00011011
    bne left
    jsr lcd_clear
    lda #"D"
    jsr lcd_write_char
    jmp loop
left:
    lda button
    cmp #%00010111
    bne right
    jsr lcd_clear
    lda #"L"
    jsr lcd_write_char
    jmp loop
right:
    lda button
    cmp #%00001111
    bne loop
    jsr lcd_clear
    lda #"R"
    jsr lcd_write_char
    jmp loop


read_port_a:
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    beq read_port_a
    sta button
wait:    
    lda PORTA
    and #%00011111 ;# mask pa7-pa5
    cmp #%00011111
    bne wait
    rts





lcd_instruction:
    jsr lcd_wait_ready
    sta PORTB
    lda #0              ; Clear LCD_RS / LCD_RW/ LCD_E bits
    sta PORTA
    lda #LCD_E          ; set LCD_E (to send instruction)
    sta PORTA
    lda #0              ; Clear LCD_RS / LCD_RW/ LCD_E bits
    sta PORTA
    rts 

lcd_clear:
    lda #$00000001 ; clear screen
    jsr lcd_instruction
    rts

lcd_wait_ready:
  pha
  lda #%00000000         ; PORTB: set all pins as input
  sta DDRB
lcd_busy:
  lda #LCD_RW
  sta PORTA
  lda #(LCD_RW | LCD_E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcd_busy

  lda #LCD_RW
  sta PORTA
  lda #%11111111          ; PORTB: set all pins as output
  sta DDRB
  pla
  rts

lcd_write_char:
    jsr lcd_wait_ready
    sta PORTB
    lda #LCD_RS             ; Set LCD_RS and clear LCD_RW and LCD_E bits
    sta PORTA
    lda #(LCD_RS | LCD_E)   ; set LCD_RS and LCD_E
    sta PORTA
    lda #LCD_RS             ; Set LCD_RS  clear LCD_E
    sta PORTA
    rts 

lcd_write_output:
    jsr lcd_clear
    sta output
    jsr lcd_wait_ready
    sta PORTB
    lda #LCD_RS             ; Set LCD_RS and clear LCD_RW and LCD_E bits
    sta PORTA
    lda #(LCD_RS | LCD_E)   ; set LCD_RS and LCD_E
    sta PORTA
    lda #LCD_RS             ; Set LCD_RS  clear LCD_E
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
