PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003
LCD_E  = %10000000
LCD_RW = %01000000
LCD_RS = %00100000

    .org $8000


loop:
    jmp loop


    .org $fffc
	.word reset
	.word $0000