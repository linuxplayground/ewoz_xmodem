# 6502 Board 2

This is my second Ben Eater inspired project for a 6502 board.

The memory map is:

```
RAM  $0000-$7FFF
ACIA $8400-$8410
VIA  $9000-$9010
ROM  $A000-$FFFF
```

## VASM

I use the Vasm assembler for this project in oldstyle mode.  In order to keep my RAM apps light, I try to reference routines in rom where I can.  The Rom assembly is called `ewoz_rom.asm` as it includes, Ehanced WOZ Mon (ewoz), Xmodem, i2c and spi libraries.

There is a python script I use to take all the labels and their addresses from the ROM LST file created by vasm which I can include in my other apps.

I also keep track of zero page addresses in a file called `zp.s` under the includes.

## Apps I have made so far:

1. dht11.asm - Example of reading 1-wire protocol.  Note: this only works when I use the 4mhz clock.  (I use an arduino nano to clock at 4mhz)
2. i2c_lcd_test.s - Dispaly stuff on my 20x4 LCD display which has a PCF8572 i2c to parralel module on the back of it.
3. spi_matrix.s to test an 8x8 LED Matrix I have.
4. i2c-irq.s - The name is a bit misleading.  It's Ben Eater's IRQ Counter program but displays to the I2C backed LCD display.

## Apps made for the first board

I keep these handy as a reference and because I still have that board on my shelf.

1. hello_world.asm
2. irq.asm

## Notes on code

Most of the interface code for i2c and SPI are taken from the 6502.org forums.  Specifically Garth Wilson's primers.

All the includes that are included into the ROM have set start addresses defined.  There is no good way do relocatable code in vasm.  For that you need to switch / port to ca65 and it's linker.  _ I have not done that _
