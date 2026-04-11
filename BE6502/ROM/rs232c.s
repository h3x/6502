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

; RS232 Registers
ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003

 .org $8000 ; ROM start address at top of memory

reset:
 ldx #$ff
 txs

 ; VIA setup
 lda #%11111111 ; Set all pins on port B to output
 sta DDRB
 lda #%10111111
 sta DDRA

 ; LCD setup
 jsr lcd_init
 lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
 jsr lcd_instruction
 lda #%00001110 ; Display on; cursor on; blink off
 jsr lcd_instruction
 lda #%00000110 ; Increment and shift cursor; don't shift display
 jsr lcd_instruction
 lda #%00000001 ; Clear display
 jsr lcd_instruction

 ; RS232 Setup
 lda #$00
 sta ACIA_STATUS ; soft reset

 lda #$1f
 sta ACIA_CTRL ; N-8-1, 19200 baud

 lda #$0B
 sta ACIA_CMD ; no parity, no echo, no irq
 
 ldx #0
send_message:
 lda message,x
 beq done
 jsr send_char
 inx
 jmp send_message
 
done:
rx_wait:
 lda ACIA_STATUS
 and #$08 ; check if we recieved any data in rx buffer flag
 beq rx_wait

 lda ACIA_DATA
 jsr send_char
 jsr print_char
 jmp rx_wait

message: .asciiz "Hello, World!"
 
send_char:
 pha
 sta ACIA_DATA
tx_wait:
 lda ACIA_STATUS
 and #$10 ; check tx buffer flag
 beq tx_wait
 pla
 jsr tx_delay
 rts
tx_delay:
 phx
 ldx #100
tx_delay_1:
 dex
 bne tx_delay_1
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
exit_irq:
 rti


 .org $fffa ; Reset vector
 .word nmi
 .word reset
 .word irq
