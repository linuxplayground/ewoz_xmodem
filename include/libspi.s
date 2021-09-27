    .include "zp.s"
    
PORTA = $9001
DDRA  = $9003
SCK   = %00000001
CS    = %00000010
MOSI  = %00000100

	.org $B200
; http://www.cyberspice.org.uk/blog/2009/08/25/bit-banging-spi-in-6502-assembler/
spibyte:
	sta outb
	ldy #0
	sty inb
	ldx #8
spibytelp:
	tya		        ; (2) set A to 0
	asl outb	    ; (5) shift MSB in to carry
	bcc spibyte1	; (2)
	ora #MOSI	    ; (2) set MOSI if MSB set
spibyte1:
	sta PORTA	    ; (4) output (MOSI, SCS low, SCLK low)
	tya		        ; (2) set A to 0 (Do it here for delay reasons)
	inc PORTA	    ; (6) toggle clock high (SCLK is bit 0)
	clc		        ; (2) clear C (Not affected by bit)
	bit PORTA	    ; (4) copy MISO (bit 7) in to N (and MOSI in to V)
	bpl spibyte2	; (2)
	sec		        ; (2) set C is MISO bit is set (i.e. N)
spibyte2:
	rol inb		    ; (5) copy C (i.e. MISO bit) in to bit 0 of result
	dec PORTA	    ; (6) toggle clock low (SCLK is bit 0)
	dex		        ; (2) next bit
	bne spibytelp	; (2) loop
	lda inb		    ; get result
	rts