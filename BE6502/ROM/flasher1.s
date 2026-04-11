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

ticks = $00
toggle_time = $02


 .org $8000 ; ROM start address at top of memory

reset:
 lda #%11111111 ; Set all pins on port a to output
 sta DDRA
 lda #0
 sta PORTA ; Set all pins on port a to 0
 sta toggle_time
 jsr init_timer

loop:
 jsr update_led:
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
