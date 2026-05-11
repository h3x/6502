.setcpu "65c02"
; VIA2 Port B bit definitions
LCD_D4  = %00000001   ; VIA PB0 → LCD DB4
LCD_D5  = %00000010   ; VIA PB1 → LCD DB5
LCD_D6  = %00000100   ; VIA PB2 → LCD DB6
LCD_D7  = %00001000   ; VIA PB3 → LCD DB7
LCD_RS  = %00010000   ; VIA PB4 → LCD RS
LCD_RW  = %00100000   ; VIA PB5 → LCD RW
LCD_E   = %01000000   ; VIA PB6 → LCD E

VIA_PORTB = $8000
VIA_DDRB  = $8002

.segment "CODE"
reset:
 ldx #$0

 ; VIA setup
 lda #%11111111       ; Set all pins on port B to output
 sta VIA_DDRB

 ; LCD setup
 jsr lcd_init
 lda #%00101000       ; Set 4-bit mode
 jsr lcd_instruction
 jmp done


send_message:
 lda message,x
 beq done
 jsr print_char
 inx
 jmp send_message


done:
 jmp done
 
message: .asciiz "Hello, World!"
 
lcd_init:
    ; send $30 three times as upper nibble only (8 bit mode init)
    lda #%00000011      ; $30 upper nibble = 0011
    sta VIA_PORTB
    ora #LCD_E
    sta VIA_PORTB
    eor #LCD_E
    sta VIA_PORTB
    jsr lcd_wait

    lda #%00000011
    sta VIA_PORTB
    ora #LCD_E
    sta VIA_PORTB
    eor #LCD_E
    sta VIA_PORTB
    jsr lcd_wait

    lda #%00000011
    sta VIA_PORTB
    ora #LCD_E
    sta VIA_PORTB
    eor #LCD_E
    sta VIA_PORTB
    jsr lcd_wait

    ; now send 0010 to switch to 4 bit mode
    lda #%00000010
    sta VIA_PORTB
    ora #LCD_E
    sta VIA_PORTB
    eor #LCD_E
    sta VIA_PORTB
    jsr lcd_wait

    rts
 
lcd_instruction:
 jsr lcd_wait
 pha
 lsr
 lsr
 lsr
 lsr                 ; Send high 4 bits
 and #%00001111      ; RS=0, RW=0, E=0
 sta VIA_PORTB
 ora #LCD_E         ; Set E bit to send instruction
 sta VIA_PORTB
 eor #LCD_E         ; Clear E bit
 sta VIA_PORTB
 pla
 and #%00001111     ; Send low 4 bits
 sta VIA_PORTB
 ora #LCD_E         ; Set E bit to send instruction
 sta VIA_PORTB
 eor #LCD_E         ; Clear E bit
 sta VIA_PORTB
 rts

lcd_wait:
 pha
 phy
 ldy #$ff
delay_loop:
 dey
 bne delay_loop
 ply
 pla
 rts
lcd_long_wait:
    pha
    phy
    phx
    ldx #$ff
long_outer:
    ldy #$ff
long_inner:
    dey
    bne long_inner
    dex
    bne long_outer
    plx
    ply
    pla
    rts
print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #LCD_RS         ; Set RS
  sta VIA_PORTB
  ora #LCD_E          ; Set E bit to send instruction
  sta VIA_PORTB
  eor #LCD_E          ; Clear E bit
  sta VIA_PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #LCD_RS         ; Set RS
  sta VIA_PORTB
  ora #LCD_E          ; Set E bit to send instruction
  sta VIA_PORTB
  eor #LCD_E          ; Clear E bit
  sta VIA_PORTB
  rts
 
handle_nmi:
handle_irq:
exit_irq:
 rti

.segment "VECTORS"
 .word handle_nmi
 .word reset
 .word handle_irq

