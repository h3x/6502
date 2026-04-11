PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E = %10000000 ; Enable
RW = %01000000 ; Read/Write
RS = %00100000 ; Register Select

 .org $8000 ; ROM start address at top of memory

reset:
 ldx #$ff 
 txs ; Clear the stack

 lda #%11111111 ; set all pints of port B to output
 sta DDRB
 lda #%11100000 ; Set P5, P6, P7 to output
 sta DDRA

 lda #%00111000 ; Set 8 bit mode, 2 line display, 5x8 font size
 jsr lcd_instruction

 lda #%00001110 ; Display on, cursor on, blinking off
 jsr lcd_instruction

 lda #%00000110 ; Increment cursor, no display shift
 jsr lcd_instruction
 
 lda #%00000001 ; Clear display
 jsr lcd_instruction
 
 lda #%00000010 ; Return home
 jsr lcd_instruction

; Print the message, "Hello, world!!"
 lda #"F"
 jsr print_character
 lda #"u"
 jsr print_character
 lda #"c"
 jsr print_character
 lda #"k"
 jsr print_character
 lda #" "
 jsr print_character
 lda #"C"
 jsr print_character
 lda #"u"
 jsr print_character
 lda #"r"
 jsr print_character
 lda #"s"
 jsr print_character
 lda #"o"
 jsr print_character
 lda #"r"
 jsr print_character
 lda #"!"
 jsr print_character
 lda #"!"
 jsr print_character
 lda #"!"
 jsr print_character

loop:
 jmp loop

print_character:
 jsr lcd_wait
 sta PORTB
 lda #RS ; Set to data mode
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 rts

lcd_wait:
 pha
 lda #%00000000 ; Set port b to input
 sta DDRB

lcd_busy:
 lda #RW
 sta PORTA
 lda #(RW | E)
 sta PORTA
 lda PORTB
 and #%10000000 ; check if bust flag set
 bne lcd_busy

 lda #RW
 sta PORTA
 lda #%11111111
 sta DDRB
 pla
 rts
 
lcd_instruction:
 jsr lcd_wait
 sta PORTB
 lda #%0 ; Clean display
 sta PORTA
 lda #E ; Enable the display
 sta PORTA
 lda #%0 ; Clean display
 sta PORTA
 rts

 .org $fffc ; Reset vector
 .word reset
 .word $0000 
