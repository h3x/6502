rom = bytearray([0xea] * 32768)

rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80

with open("rom2.bin", "wb") as out:
    out.write(rom)
