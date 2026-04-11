PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E = %10000000 ; Enable
RW = %01000000 ; Read/Write
RS = %00100000 ; Register Select

value = $0200 ; 2 bytes
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes

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

 lda #0
 sta message
 
; Initialise the value for the number to convert
 lda number
 sta value
 lda number + 1
 sta value + 1

; Initialise the remainder to 0
divide:
 clc ; clear the carry bit
 lda #0
 sta mod10
 sta mod10 + 1

 ldx #16
divloop:
; Rotate all 4 bytes
 rol value
 rol value + 1
 rol mod10
 rol mod10 + 1

; a,y = dividend - divisor
 sec
 lda mod10
 sbc #10
 tay ; save the low byte in Y
 lda mod10 + 1
 sbc #0
 bcc ignore_result ; branch if dividend < divisor
 sty mod10
 sta mod10 + 1

ignore_result:
 dex
 bne divloop
 rol value
 rol value + 1

 lda mod10
 clc
 adc #"0"
 jsr push_character


 ; if value is not 0, the run again
 lda value
 ora value + 1
 bne divide

 ldx #0
print:
 lda message, x
 beq loop
 jsr print_character
 inx
 jmp print

loop:
 jmp loop

number: .word 1729

push_character:
 ; Add the character in the A register to the beginning of the null-terminated string 'message'
 pha ; Push new first char to the stack
 ldy #0

char_loop: 
 lda message,y ; Get char on string and put into X
 tax
 pla
 sta message,y ; Pull char off stach and add it to the string
 iny
 txa
 pha
 bne char_loop
 
 pla
 sta message, y ; Pull the null off the stack and add to the end of the string
 rts

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
