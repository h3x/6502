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
 jsr lcd_init
 lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
 jsr lcd_instruction
 lda #%00001110 ; Display on; cursor on; blink off
 jsr lcd_instruction
 lda #%00000110 ; Increment and shift cursor; don't shift display
 jsr lcd_instruction
 lda #%00000001 ; Clear display
 jsr lcd_instruction
 lda #%11111111 ; Set all pins on port a to output
 sta DDRA
 lda #0
 sta PORTA ; Set all pins on port a to 0
 sta toggle_time
 jsr init_timer

loop:
 jsr update_led
 jsr update_lcd
 ; other stuff
 jmp loop

update_led:
 sec
 lda ticks
 sbc toggle_time
 cmp #25 ; Have 250ms elapsed?
 bcc exit_update_led
 lda #$01
 eor PORTA
 sta PORTA
 lda ticks
 sta toggle_time
exit_update_led:
 rts

update_lcd:
 sec
 lda ticks
 sbc toggle_time
 cmp #100 ; Have 250ms elapsed?
 bcc exit_update_lcd
 sei
 lda ticks
 sta value
 lda ticks + 1
 lda value + 1
 cli
 lda #%00000001 ; clear display
 jsr lcd_instruction
 jsr print_num
 lda ticks
 sta lcd_time
exit_update_lcd:
 rts

init_timer:
 lda #0
 sta ticks
 sta ticks + 1
 lda #%01000000
 sta ACR ; Set aux control register to free run mode timer
 lda #$0e ; Set the clock for 10ms
 sta T1CL
 lda #$27
 sta T1CH 
 lda #%11000000 ; Enable interupts, enable timer 1 interupt
 sta IER
 cli ; Enable interups on the 6502
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

print_num:
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
