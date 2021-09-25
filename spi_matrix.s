PORTA = $9001
DDRA  = $9003

SCK   = %00000001
CS    = %00000010
MOSI  = %00000100

inb   = $50
outb  = $51

DECODE_MODE         = $09                       
INTENSITY           = $0a                        
SCAN_LIMIT          = $0b                        
SHUTDOWN            = $0c                        
DISPLAY_TEST        = $0f

    .org $1000

reset:

    jsr led_init

    lda #SHUTDOWN
    ldx #1
    jsr spipacket

    lda #INTENSITY
    ldx #0
    jsr spipacket


    ldy #0
lp1:
    lda pattern,y
    beq lp1_exit
    tax
    tya
    adc #1
    phy
    phx
    jsr spipacket
    plx
    ply
    iny
    jmp lp1

lp1_exit:
    ldy #$02
    jsr pause

    ldy #0
lp2:
    lda pattern2,y
    beq lp2_exit
    tax
    tya
    adc #1
    phy
    phx
    jsr spipacket
    plx
    ply
    iny
    jmp lp2
lp2_exit:
    ldy #$02
    jsr pause

    jmp lp1

exit:
    rts

pattern:
    .byte $55, $aa, $55, $aa, $55, $aa, $55, $aa
    .byte 0
pattern2:
    .byte $aa, $55, $aa, $55, $aa, $55, $aa, $55
    .byte 0


pause:
    dey
    beq .continue
    jsr delay
    jmp pause
.continue
    rts

delay:
    phy
    phx

    ldy #$ff
.d1:
    ldx #$ff
.d2:
    dex
    bne .d2
    dey
    bne .d1

    plx
    ply
    rts
led_init:
    lda #%00000111  ; nc/nc/nc/nc/nc/mosi/cs/sck
    sta DDRA

    lda #CS         ; cs high
    sta PORTA

    lda #DISPLAY_TEST
    ldx #0
    jsr spipacket

    lda #SCAN_LIMIT
    ldx #7
    jsr spipacket

    lda #DECODE_MODE
    ldx #0
    jsr spipacket

    jsr lcd_clear

    lda #SHUTDOWN
    ldx #0
    jsr spipacket

    rts

; this ends up sending a nop on the last loop which is fine.
lcd_clear:
    ldx #8
.loop:
    dex
    beq .exit
    phx
    txa
    adc 1   ; columns start at 1 through 8
    ldx #%00000000  ; each column has 8 dots.  turn them all off
    jsr spipacket
    plx
    jmp .loop
.exit
    rts

; A = command, X = value
; borks both A and X
spipacket:
    phx
    pha
    lda #0
    sta PORTA
    pla
    jsr spibyte
    plx
    txa
    jsr spibyte
    lda #CS
    sta PORTA
    rts

; http://www.cyberspice.org.uk/blog/2009/08/25/bit-banging-spi-in-6502-assembler/
spibyte:
	sta outb
	ldy #0
	sty inb
	ldx #8
spibytelp:
	tya		; (2) set A to 0
	asl outb	; (5) shift MSB in to carry
	bcc spibyte1	; (2)
	ora #MOSI	; (2) set MOSI if MSB set
spibyte1:
	sta PORTA	; (4) output (MOSI, SCS low, SCLK low)
	tya		; (2) set A to 0 (Do it here for delay reasons)
	inc PORTA	; (6) toggle clock high (SCLK is bit 0)
	clc		; (2) clear C (Not affected by bit)
	bit PORTA	; (4) copy MISO (bit 7) in to N (and MOSI in to V)
	bpl spibyte2	; (2)
	sec		; (2) set C is MISO bit is set (i.e. N)
spibyte2:
	rol inb		; (5) copy C (i.e. MISO bit) in to bit 0 of result
	dec PORTA	; (6) toggle clock low (SCLK is bit 0)
	dex		; (2) next bit
	bne spibytelp	; (2) loop
	lda inb		; get result
	rts