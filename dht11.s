    .include "zp.s"
    .include "romsymbols.inc"
    .include "via.s"

ZP_HUM      = $40
ZP_HUMDEC   = $41
ZP_TEMP     = $42
ZP_TEMPDEC  = $43
ZP_CHECK    = $44

ZP_SHIFTPTR = $45

ZP_T01      = $47

ZP_BUFPTR   = $48

DATA_BIT  = %10000000   ; PB7

value 	= $2000		; 2 bytes
mod10 	= $2002		; 2 bytes
message = $2004		; 6 bytes
counter = $200a		; 2 bytes


; macros slurped from my I2C library.
; which, of course, I slurped from 6502.org forums.
;------------------------------------------------------------------------------
    .macro data_up
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #DATA_BIT  ; Clear data bit of the DDR
        trb   DDRB       ; to make bit an input and let it float up.
    .endmacro


;------------------------------------------------------------------------------
    .macro data_down
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #DATA_BIT  ; Set data bit of the DDR
        tsb   DDRB       ; to make bit an output and pull it down.
    .endmacro

    .org $1000

    jsr lcd_init

    lda #<message1
    ldx #>message1
    jsr send_lcd_message

    stz ZP_TEMP
    stz ZP_HUM
    stz ZP_HUMDEC
    stz ZP_TEMPDEC
    stx ZP_T01

    ; clear buffer
    jsr clear_buffer

    ; 1-wire comms out of pin PB7
    ; PB7 is pulled up with a 10kohm resistor on the DHT11 Sensor module.
    ; if you don't have the module, you need to add this resistor yourself.
    ; setting PB7 to input mode will let the line float high
    ; allowing the MCU or the slave device to pull it low
    ; high is idle state.

    data_up
    ldy #50
    jsr Delay_ms    ; this delay is just to let things settle.  Mainly for
                    ; the purposes of KNOWING when things start while looking
                    ; my logic analyser

    jsr dh22_start
    jsr TOH         ; skip over the first two as these are the slave device
    jsr TOL         ; signalling that it's about send data.

; read 40 bits into memory.  The TOL routine actually writes the loop count
; into Address $03ff,x (Starting at 03ff becuase the first low is not actual
; data.  Its that first signal that the slave sends to say it's about to send
; data)  Later on, I use $0400 as the base for shifting in the bytes.

    ldx #0
loop:
    jsr TOH
    jsr TOL
    inx
    cpx #41
    bne loop
    
    ; Read the various sections of the buffered reading and store in ZP memory
    ; for all prosperity.

    ; humidity - integral = first 8 bits
    stz ZP_T01
    lda #$00
    sta ZP_BUFPTR
    lda #$04
    sta ZP_BUFPTR + 1
    jsr shift
    lda ZP_T01
    sta ZP_HUM

    ; humidity - decimal = second 8 bits
    stz ZP_T01
    lda #$08
    sta ZP_BUFPTR
    lda #$04
    sta ZP_BUFPTR + 1
    jsr shift
    lda ZP_T01
    sta ZP_HUMDEC

    ; temperature - integral = third 8 bits
    stz ZP_T01
    lda #$10
    sta ZP_BUFPTR
    lda #$04
    sta ZP_BUFPTR + 1
    jsr shift
    lda ZP_T01
    sta ZP_TEMP

    ; temperature decimal = fourth 8 bits
    stz ZP_T01
    lda #$18
    sta ZP_BUFPTR
    lda #$04
    sta ZP_BUFPTR + 1
    jsr shift
    lda ZP_T01
    sta ZP_TEMPDEC

    ; I have not bothered with the checksum.  It's the binary sum of the 4
    ; previoius bytes and is in the fifth and last 8 bits.

    ; this bin2dec function from beneater assumes 16 bit numbers.
    ; we only have 8bit numbers so I am just initializing the high counter
    ; value to 0

    ; display humidity line
    lda #<message3
    ldx #>message3
    jsr send_lcd_message
    lda ZP_HUM
    sta counter
    stz counter + 1
    jsr bin2dec

    lda #<message2
    ldx #>message2
    jsr send_lcd_message

    ; display temperature line
    lda #<message4
    ldx #>message4
    jsr send_lcd_message
    lda ZP_TEMP
    sta counter
    stz counter + 1
    jsr bin2dec


exit:
    rts

; clear buffer
clear_buffer:
    ldy #0
    lda #0
.loop:
    sta $0400,y
    iny
    bne .loop
    rts

;
; dh22_start
; Starts the dh22 signal dance. 
; low for 18ms followed by bringing the line high.  THat's when the slave wakes up
; and takes over.
;
dh22_start:
    data_down
    ldy #72         ; 18 milliseconds on a mhz clock.  My delay sequence in rom
                    ; is callibrated for 1mhz.
    jsr Delay_ms    ; use the rom routine for delay ms
    data_up
    rts

;
; count loops until DATABIT goes high.
; assumes data is low to begin with.
;
TOH:
    lda #DATA_BIT
.loop:
    bit PORTB
    beq .loop
    rts

;
; count loops until the DATABIT goes low.
; as high pulses on this protocol represent input, save the input
; into the reading buffer starting at $3ff offset by x which is
; defined by the calling loop.
TOL:
    lda #DATA_BIT
.loop:
    inc $3ff,x
    bit PORTB
    bne .loop
    rts

; shifts in 8 bytes of data from the BUFFPTR into a temporary
; zero page location.
; data is MSB First.
shift:
    ldy #0
    ldx #8
.loop:
    lda (ZP_BUFPTR),y
    clc
    sbc #$0f    ; using subtract with carry will cause the Carry to be set if the result
                ; would be negative.
    rol ZP_T01  ; roll the carry flag in.  A carry set means reading was larger than $0f
    iny
    dex
    bne .loop
    rts

; binary to decimal

bin2dec:
	; initialise the output message
	lda #0
	sta message

	sei				; Disable interrupts. (the name of this instruction is misleading)

	; initialize the value to convert
	lda counter
	sta value
	lda counter + 1
	sta value + 1

	cli				; clear interrupt disable bit (enable interrupts)

divide:
	; Initialise the remainder to zero
	lda #0
	sta mod10
	sta mod10 + 1
	clc

	ldx #16
divloop:
	; Rotate the quotient and remainder
	rol value
	rol value + 1
	rol mod10
	rol mod10 + 1

	; a, y = dividend - divisor
	sec
	lda mod10
	sbc #10
	tay				; save low byte
	lda mod10 + 1
	sbc #0
	bcc  ignore_result ; branch if dividend < divisor

	sty mod10
	sta mod10 + 1

ignore_result:
	dex
	bne divloop
	rol value	; shift in the last bit of the qotient
	rol value + 1

	lda mod10
	clc
	adc #"0"
	jsr push_char

	; if value is not zero we need to continue dividing
	lda value
	ora value + 1
	bne divide

	ldx #0
print:
	lda message,x
	beq exit_print
	phx
	jsr send_lcd_write_4bit_char
	plx
	inx
	jmp print
exit_print:
	rts

; Add the character in the A register to the beginning of the 
; null-terminated string `message`
push_char:
	pha	; Push new char to the stack
	ldy #0
char_loop:
	lda message,y	; Get char from the string and put to x reg
	tax
	pla
	sta message,y	; Pull char off the stack and push to the string
	iny
	txa
	pha				; Push char from stirng on to stack
	bne	char_loop
	pla
	sta message,y	; Pull the null off the stack and add to end of string
	rts

message1: .byte "DHT11               ",0
message2: .byte "--------------------",0
message3: .byte "Humidity: ....... ",0
message4: .byte "Temperature: .... ",0