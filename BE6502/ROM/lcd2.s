PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E = %10000000 ; Enable
RW = %01000000 ; Read/Write
RS = %00100000 ; Register Select

 .org $8000 ; ROM start address at top of memory

reset:
 lda #%11111111 ; set all pints of port B to output
 sta DDRB

 lda #%11100000 ; Set P5, P6, P7 to output
 sta DDRA

 lda #%00111000 ; Set 8 bit mode, 2 line display, 5x8 font size
 sta PORTB

 lda #%0 ; Clean display
 sta PORTA

 lda #E ; Enable the display
 sta PORTA

 lda #%0 ; Clean display
 sta PORTA

 lda #%00001110 ; Display on, cursor on, blinking off
 sta PORTB

 lda #%0 ; Clean display
 sta PORTA

 lda #E ; Enable the display
 sta PORTA

 lda #%0 ; Clean display
 sta PORTA

 lda #%00000110 ; Increment cursor, no display shift
 sta PORTB

 lda #%0 ; Clean display
 sta PORTA

 lda #E ; Enable the display
 sta PORTA

 lda #%0 ; Clean display
 sta PORTA

; Print the message, "Hello,         Alayacare!"
 lda #"H"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"e"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA

 lda #"l"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"l"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA

 
 lda #"o"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA

 lda #" "
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA

 lda #"A"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA

 lda #"l"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"a"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"y"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"a"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"C"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"a"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"r"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
 
 lda #"e"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA

 lda #"!"
 sta PORTB
 lda #RS ; Set to data mode
 sta PORTA
 lda #(RS | E) ; Enable the display
 sta PORTA
 lda #RS ; Set to data mode
 sta PORTA
loop:
 jmp loop

 .org $fffc ; Reset vector
 .word reset
 .word $0000 
