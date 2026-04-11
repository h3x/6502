PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %01000000 ; Enable
RW = %00100000 ; Read/Write
RS = %00010000 ; Register Select

; 6502 interupts
PCR = $600c ; peripheral control register
IFR = $600d ; interupt flags register
IER = $600e ; interupt enable register

value = $0200 ; 2 bytes
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes
counter = $020a ; 2 bytes

 .org $8000 ; ROM start address at top of memory

reset:
 ldx #$ff 
 txs ; Clear the stack
 cli ; enable interupts
 
 lda #$82 ; Set interupts
 sta IER

 lda #$00 ; set all pins of peripheral control register for falling edge
 sta PCR

 lda #%11111111 ; set all pints of port B to output
 sta DDRB
 lda #%00000000 ; Set all pins of port A to input
 sta DDRA

 jsr lcd_init
 lda #%00101000 ; Set LCD to 4 bit mode, 2 line display, 5x8 font size
 jsr lcd_instruction

 lda #%00001110 ; Display on, cursor on, blinking off
 jsr lcd_instruction

 lda #%00000110 ; Increment cursor, no display shift
 jsr lcd_instruction
 
 lda #%00000001 ; Clear display
 jsr lcd_instruction

 lda #0
 sta counter
 sta counter + 1

loop:
 lda #%00000010 ; Home
 jsr lcd_instruction
 lda #0
 sta message
 
; Initialise the value for the number to convert
 lda counter
 sta value
 lda counter + 1
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
 lda #%11110000 ; LCD Data is input
 sta DDRB

lcd_busy:
 lda #RW
 sta PORTB
 lda #(RW | E)
 sta PORTB
 lda PORTB ; Read high nibble
 pha
 lda #RW
 sta PORTB
 lda #(RW | E)
 sta PORTB
 lda PORTB ; Read high nibble
 pla
 and #%00001000 ; check if bust flag set
 bne lcd_busy

 lda #RW
 sta PORTB
 lda #%11111111
 sta DDRB
 pla
 rts

lcd_init:
 lda #%00000010 ; set to 4 bit mode
 sta PORTB
 ora #E
 sta PORTB
 and #%00001111
 sta PORTB
 rts
lcd_instruction:
 jsr lcd_wait
 pha
 lsr
 lsr
 lsr
 lsr            ; Send high 4 bits
 sta PORTB
 ora #E         ; Set E bit to send instruction
 sta PORTB
 eor #E         ; Clear E bit
 sta PORTB
 pla
 and #%00001111 ; Send low 4 bits
 sta PORTB
 ora #E         ; Set E bit to send instruction
 sta PORTB
 eor #E         ; Clear E bit
 sta PORTB
 rts 

nmi:
irq:
 inc counter
 bne exit_irq
 inc counter + 1
 
exit_irq:
 bit PORTA ; Clear the interupt. Will do a 'read' of PORT A without having to push a to the stack first.
 rti       ; rti will restore the processor flags

 .org $fffa ; Reset vector
 .word nmi
 .word reset
 .word irq
