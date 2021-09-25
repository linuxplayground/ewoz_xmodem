	.include "liblcd.s"

PORTB 	= $9000
PORTA 	= $9001
DDRB  	= $9002
DDRA  	= $9003

PCR		= $900c		; W65C22 VIA Periferal Control Register
IFR		= $900d		; W65C22 VIA Interrupt Flag Register
IER		= $900e		; W65C22 VIA Interrupt Enable Register

value 	= $2000		; 2 bytes
mod10 	= $2002		; 2 bytes
message = $2004		; 6 bytes
counter = $200a		; 2 bytes

E     	= %10000000
RW    	= %01000000
RS    	= %00100000

ISR_LOC = $31		; location of IRQ handler

	.org $1000

reset:

	lda #<irq       ; set up IRQ handler for sixty5o2
	sta ISR_LOC
	lda #>irq
	sta ISR_LOC + 1

	lda #$ff		; Set up stack pointer
	txs

	lda #$82		; Enable CA1 interrupt on the VIA (10000010)
	sta IER
	lda #$00
	sta PCR			; Set CA1 to trigger on negative transition (going low)

	jsr lcd_init
	jsr lcd_cursor_off
	
	lda #0			; Initialize the counter to zero
	sta counter
	sta counter + 1
	cli				; clear interrupt disable bit (enable interrupts)

loop:
	lda #%00000010	; Move cursor to home
	jsr send_lcd_write_4bit_instruction

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
	jmp loop

number: .word 1729

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



irq:
	phx
	phy
	pha
	
	inc counter
	bne exit_irq
	inc counter + 1

exit_irq:

	ldy #$ff
wl1:
	ldx #$ff
wl2:
	dex
	bne wl2
	dey
	bne wl1

	bit PORTA

	pla
	ply
	plx

	rti


