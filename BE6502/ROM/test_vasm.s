 .org $8000 ; ROM start address at top of memory

reset:
 lda #$ff
 sta $6002

 lda #$50
 sta $6000

loop:
 ror
 sta $6000

 jmp loop

 .org $fffc ; Reset vector
 .word reset
 .word $0000 
