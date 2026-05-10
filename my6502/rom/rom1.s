.setcpu "65C02"

.segment "CODE"

RESET:
    JMP $8000

LOOP:
    NOP
    JMP LOOP

.segment "VECTORS"
    .word $0000     ; NMI
    .word RESET     ; RESET
    .word $0000     ; IRQ
