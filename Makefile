rom:
	vasm6502_oldstyle \
		-Fbin \
		-dotdir \
		-c02 \
		-Iinclude \
		-L ewoz.lst -Llo \
		-ignore-mult-inc \
		-o ewoz.bin \
		ewoz_rom.asm

hello-world:
	vasm6502_oldstyle -Fbin -dotdir -o hello.o hello_world.asm && \
	/usr/bin/printf '\x00\x10' | cat - hello.o > hello.bin

irq:
	vasm6502_oldstyle -Fbin -dotdir -o irq.o irq.asm

i2c-lcd:
	vasm6502_oldstyle -Fbin -dotdir -Iinclude -c02 -o i2c-lcd.o -L i2c-lcd.lst i2c_lcd_test.s

i2c-lcd-irq:
	vasm6502_oldstyle -Fbin -dotdir -Iinclude -c02 -o i2c-irq.o -L i2c-irq.lst i2c-irq.s

spi:
	vasm6502_oldstyle -Fbin -dotdir -Iinclude -c02 -o spi.o spi_matrix.s

dht11:
	vasm6502_oldstyle -Fbin -dotdir -Iinclude -c02 -o dht11.o dht11.s

morse:
	vasm6502_oldstyle -Fbin -dotdir -Iinclude -c02 -o morse.o morse_xmt.asm
	
clean:
	rm -v *.o *.lst *.bin

install-rom:
	minipro -p AT28C256 -w ewoz.bin