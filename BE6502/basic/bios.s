.setcpu "65C02"
.debuginfo

; Word buffer
.zeropage
.org ZP_START0
WRITE_PTR: .res 1
READ_PTR:  .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER: .res $100

.segment "BIOS"
; RS232
ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003

; VIA
PORTA       = $6001
DDRA        = $6003


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
  phx
  jsr BUFFER_SIZE ; Check if we need to grab next character
  beq @no_keypressed

  jsr READ_BUFFER
  jsr CHROUT     ; echo back to the serial interface
  pha
  jsr BUFFER_SIZE
  cmp #$B0
  bcs @mostly_full
  lda #$00 ; This should be the VIA halting tx, but doesnt work
  sta PORTA
  ; lda #$09 ; Re-enable the clear to send 
  ; sta ACIA_CMD
@mostly_full:
  pla
  plx
  sec
  rts
@no_keypressed:
  plx
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

  ldx #$B
@outer:
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

; Initialalise the circular input buffer
; Modifies: flags, A
INIT_BUFFER:
  lda READ_PTR
  sta WRITE_PTR

  ; Due to bug in asic chip, use VIA to handle RS232 RTS signaling. This isnt working
  lda #$01
  sta DDRA
  lda #$00
  sta PORTA
  rts

; Write a character from A to the input buffer
; Modifies: flags, X
WRITE_BUFFER:
  ldx WRITE_PTR
  sta INPUT_BUFFER,x
  inc WRITE_PTR
  rts

; Read a character from the input buffer and put it in A
; Modifies: flags, X, A
READ_BUFFER:
  ldx READ_PTR
  lda INPUT_BUFFER,x
  inc READ_PTR
  rts

; Return the number of unread bytes in the input buffer
; Modifies: flags, A
BUFFER_SIZE:
  lda WRITE_PTR
  sec
  sbc READ_PTR
  rts

; Interupt request handler
IRQ:
  pha
  phx
  lda ACIA_STATUS ; Clear the interupt
  ; for now, assume the only source of interupts is incomming data
  lda ACIA_DATA
  jsr WRITE_BUFFER
  jsr BUFFER_SIZE
  cmp #$F0
  bcc @not_full
  lda #$01 ; This should be the VIA handling the buffer full, but doesnt work
  sta PORTA
  ;lda #$01 ; For now, let the buggy ACIA do it, even tho bugged
  ;sta ACIA_CMD
@not_full:
  plx
  pla
  rti

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   IRQ          ; IRQ vector

