; Via registers
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004 ; Timer control low
T1CH = $6005 ; Timer control high
ACR = $600B ; Auxilerty control register
IFR = $600D ; Interupt flag register
IER = $600E ; Interupt enable register

; lcd display
E  = %01000000
RW = %00100000
RS = %00010000

ticks = $00
toggle_time = $02
lcd_time = $04
value = $06

 .org $8000 ; ROM start address at top of memory

reset:
 ldx #$ff
 txs
 lda #%11111111 ; Set all pins on port B to output
 sta DDRB
 lda #%10111111
 sta DDRA

 jsr lcd_init
 lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
 jsr lcd_instruction
 lda #%00001110 ; Display on; cursor on; blink off
 jsr lcd_instruction
 lda #%00000110 ; Increment and shift cursor; don't shift display
 jsr lcd_instruction
 lda #%00000001 ; Clear display
 jsr lcd_instruction


rx_wait:
 bit PORTA ; Put port a bit 6 into V flag
 bvs rx_wait ; loop if no start bit yet
 jsr half_bit_delay
 ldx #8
read_bit:
 jsr bit_delay
 bit PORTA ; port a bit 6 into the overflow flag
 bvs recv_1
 clc
 jmp rx_done
recv_1:
 sec ; We read a 1, put 1 into carry flag
 nop ; These just make the timing match for either a 1 or a 0, it will take 40 clock cycles
 nop 
rx_done:
 ror ; rotate a register right, putting carry flag as new MSB
 dex
 bne read_bit
 ; All 8 bits are now in A register
 jsr print_char
 jsr bit_delay ; wait for the stop bit
 jmp rx_wait

bit_delay:
 phx
 ldx #13
bit_delay1:
 dex
 bne bit_delay1
 plx
 rts

half_bit_delay:
 phx
 ldx #6
half_bit_delay1:
 dex
 bne bit_delay1
 plx
 rts

lcd_wait:
 pha
 lda #%11110000  ; LCD data is input
 sta DDRB
lcdbusy:
 lda #RW
 sta PORTB
 lda #(RW | E)
 sta PORTB
 lda PORTB       ; Read high nibble
 pha             ; and put on stack since it has the busy flag
 lda #RW
 sta PORTB
 lda #(RW | E)
 sta PORTB
 lda PORTB       ; Read low nibble
 pla             ; Get high nibble off stack
 and #%00001000
 bne lcdbusy

 lda #RW
 sta PORTB
 lda #%11111111  ; LCD data is output
 sta DDRB
 pla
 rts

lcd_init:
 lda #%00000010 ; Set 4-bit mode
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

print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts


nmi:
irq:
 bit T1CL ; Read the timer to clear the interupt
 inc ticks
 bne exit_irq
 inc ticks + 1
exit_irq:
 rti


 .org $fffa ; Reset vector
 .word nmi
 .word reset
 .word irq
