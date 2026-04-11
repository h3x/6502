.setcpu "65C02"
.debuginfo
.segment "BIOS"

ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003

LOAD:
  rts
SAVE:
  rts
; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register
;
; Modifies: flags, A
MONRDKEY:
CHRIN:
  lda ACIA_STATUS
  and #$08
  beq @no_keypressed

  lda ACIA_DATA
  jsr CHROUT     ; echo back to the serial interface
  sec
  rts
@no_keypressed:
  clc
  rts

; Output a character (from the A register) to the serial interface
;
; Modifies: flags
MONCOUT:
CHROUT:
  pha
  phx
  phy
  sta ACIA_DATA

  ; calibrated delay (~600–700 cycles)
  ;ldx #$03
  ldx #9
@outer:
  ;ldy #$FF
  ldy #$80
@inner:
  dey
  bne @inner
  dex
  bne @outer
  ply
  plx
  pla
  rts
;CHROUT:
;  pha
;  sta ACIA_DATA
;  lda #$FF
;@txdelay:
;  dec
;  bne @txdelay
;  pla
;  rts


.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector

