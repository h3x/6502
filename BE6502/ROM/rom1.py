rom = bytearray([0xea] * 32768)
with open("rom1.bin", "wb") as out:
    out.write(rom)
