; Via registers
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004 ; Timer control low
T1CH = $6005 ; Timer control high
ACR = $600B ; Auxilerty control register
IFR = $600D ; Interupt flag register


 .org $8000 ; ROM start address at top of memory

reset:
 lda #%11111111 ; Set all pins on port a to output
 sta DDRA
 lda #0
 sta PORTA ; Set all pins on port a to 0
 sta ACR ; Set aux control register to 0: Timed interrupt each time timer is loaded (One shot mode)

loop:
 inc PORTA ; Turn LED on
 jsr delay
 dec PORTA ; Turn LED off
 jsr delay
 jmp loop

delay:
 lda #$50 ; Set the clock for 50ms
 sta T1CL
 lda #$c3
 sta T1CH 
delay1:
 bit IFR
 bvc delay1
 lda T1CL
 rts


nmi:
irq:
exit_irq:
 rti


 .org $fffa ; Reset vector
 .word nmi
 .word reset
 .word irq
