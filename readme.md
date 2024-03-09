65c22
PORTB  = $6000
PORTA  = $6001
DDRB   = $6002
DDRA   = $6003



buttons:
pull high 1k -> VCC
push -> VSS /GND
PA0 : button - middle
PA1 : button - up
PA2 : button - down
PA3 : button - left
PA4 : button - right

LED:
PB0
PB7


	lda %11100000; / #$E0 set pin 5,6,7 as output and 4,3,2,1,0 as input
	sta DDRA