; VIA2 Port B bit definitions
LCD_D4  = %00000001   ; VIA PB0 → LCD DB4
LCD_D5  = %00000010   ; VIA PB1 → LCD DB5
LCD_D6  = %00000100   ; VIA PB2 → LCD DB6
LCD_D7  = %00001000   ; VIA PB3 → LCD DB7
LCD_RS  = %00010000   ; VIA PB4 → LCD RS
LCD_RW  = %00100000   ; VIA PB5 → LCD RW
LCD_E   = %01000000   ; VIA PB6 → LCD E

VIA_PORTB = $8100
VIA_DDRB  = $8102

 .org $8000 ; ROM start address at top of memory

reset:
    JSR LCD_INIT

    LDA #$80          ; line 1 position 0
    JSR LCD_SETPOS

    LDX #<HELLO_STR
    LDY #>HELLO_STR
    JSR LCD_PRINT

    JMP reset          ; loop forever

HELLO_STR:
    .byte "HELLO WORLD", $00

; ============================================================
; LCD_INIT — initialise the ST7920 in 4 bit mode
; ============================================================
LCD_INIT:
    ; set all port B pins as output
    LDA #%01111111
    STA VIA_DDRB

    ; ST7920 needs >40ms after power on before init
    JSR DELAY_50MS

    ; send function set 3 times as per ST7920 init sequence
    ; first send — 8 bit mode command upper nibble only
    LDA #%00110000    ; function set, DL=1 (8 bit), upper nibble
    JSR LCD_SEND_NIBBLE
    JSR DELAY_5MS

    LDA #%00110000    ; repeat
    JSR LCD_SEND_NIBBLE
    JSR DELAY_200US

    LDA #%00110000    ; repeat
    JSR LCD_SEND_NIBBLE
    JSR DELAY_200US

    ; now switch to 4 bit mode
    LDA #%00100000    ; function set DL=0 (4 bit mode), upper nibble
    JSR LCD_SEND_NIBBLE
    JSR DELAY_200US

    ; from here send full bytes as two nibbles
    ; function set: 4 bit, 2 line, basic instruction
    LDA #%00101000    ; DL=0, N=1, RE=0
    JSR LCD_CMD
    JSR DELAY_200US

    ; display off
    LDA #%00001000
    JSR LCD_CMD
    JSR DELAY_200US

    ; display clear
    LDA #%00000001
    JSR LCD_CMD
    JSR DELAY_2MS

    ; entry mode set: increment, no shift
    LDA #%00000110
    JSR LCD_CMD
    JSR DELAY_200US

    ; display on, cursor off, blink off
    LDA #%00001100
    JSR LCD_CMD
    JSR DELAY_200US

    RTS

; ============================================================
; LCD_CMD — send command byte in A (RS=0)
; ============================================================
LCD_CMD:
    PHA
    AND #%11110000    ; get high nibble
    LSR A
    LSR A
    LSR A
    LSR A             ; shift to bits 0-3
    JSR LCD_SEND_NIBBLE
    PLA
    AND #%00001111    ; get low nibble
    JSR LCD_SEND_NIBBLE
    RTS

; ============================================================
; LCD_CHAR — send data byte in A (RS=1)
; ============================================================
LCD_CHAR:
    PHA
    AND #%11110000
    LSR A
    LSR A
    LSR A
    LSR A
    ORA #LCD_RS       ; set RS high for data
    JSR LCD_SEND_NIBBLE
    PLA
    AND #%00001111
    ORA #LCD_RS       ; RS still high
    JSR LCD_SEND_NIBBLE
    RTS

; ============================================================
; LCD_SEND_NIBBLE — send nibble in bits 0-3 of A
; RS state should already be ORed in
; ============================================================
LCD_SEND_NIBBLE:
    PHA
    AND #%00111111    ; mask to data + RS + RW(low=write)
    STA VIA_PORTB     ; set data and RS, E low
    ORA #LCD_E        ; raise E
    STA VIA_PORTB
    AND #%00011111    ; lower E
    STA VIA_PORTB
    PLA
    RTS

; ============================================================
; LCD_PRINT — print null terminated string
; address of string in X(low) Y(high)
; ============================================================
LCD_PRINT:
    STX $00           ; store pointer low
    STY $01           ; store pointer high
    LDY #$00
LP_LOOP:
    LDA ($00),Y
    BEQ LP_DONE         ; null terminator
    JSR LCD_CHAR
    INY
    BNE LP_LOOP
LP_DONE:
    RTS

; ============================================================
; LCD_SETPOS — set cursor to line L (0-3) column C (0-7)
; line addresses from datasheet:
; Line 1 = $80, Line 2 = $90, Line 3 = $88, Line 4 = $98
; ============================================================
LCD_SETPOS:
    ; call with address in A
    ; e.g. LDA #$80 for line 1 col 0
    ;      LDA #$90 for line 2 col 0
    JSR LCD_CMD
    RTS

; ============================================================
; delay routines — adjust loop counts for your clock speed
; ============================================================
DELAY_50MS:
    LDX #$FF
DELAY_O: LDY #$FF
DELAY_I: DEY
    BNE DELAY_I
    DEX
    BNE DELAY_O
    RTS

DELAY_5MS:
    LDX #$1A
DELAY5_O: LDY #$FF
DELAY5_I: DEY
    BNE DELAY5_O
    DEX
    BNE DELAY5_I
    RTS

DELAY_2MS:
    LDX #$0A
DELAY2_O: LDY #$FF
DELAY2_I: DEY
    BNE DELAY2_I
    DEX
    BNE DELAY2_O
    RTS

DELAY_200US:
    LDY #$FF
DELAY200_L: DEY
    BNE DELAY200_L
    RTS

 .org $fffc ; Reset vector
 .word reset
 .word $0000 
