rom:
	vasm6502_oldstyle -Fbin -dotdir -L ewoz.lst -ignore-mult-inc -o ewoz.bin ewoz_rom.asm

hello-world:
	vasm6502_oldstyle -Fbin -dotdir -o hello.o hello_world.asm && \
	/usr/bin/printf "\x00\x10" | cat - hello.o > hello.bin

irq:
	vasm6502_oldstyle -Fbin -dotdir -o irq.o irq.asm && \
	/usr/bin/printf "\x00\x10" | cat - irq.o > irq.bin

clean:
	rm -v irq.o hello.o irq.bin hello.bin ewoz.bin
