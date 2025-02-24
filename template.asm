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

write_lcd:
    ldx #0
write_next:
    lda message, x
    beq loop            ;branch on equal (zero set)
    jsr lcd_write_char
    inx
    jmp write_next


loop:
    jmp loop

message: .asciiz "Hello, World!"     ; Null-terminated string


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



    .org $fffc
	.word reset
	.word $0000