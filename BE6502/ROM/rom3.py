rom = bytearray([0xea] * 32768)

rom[0] = 0xa9
rom[1] = 0x42 # LDA #42

rom[2] = 0x8d 
rom[3] = 0x00
rom[4] = 0x60 # STA $6000

rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom3.bin", "wb") as out:
    out.write(rom)
