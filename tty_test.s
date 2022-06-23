    .include 'romsymbols.inc'
    .include 'zp.s'

BUFIN = $2000

    .org $1000
_reset:
    ; init lcd and send message
    JSR lcd_init

    LDA #<message
    LDX #>message
    JSR send_lcd_message

    JSR lcd_cursor_off

    LDA #$0D        ; New line.
    JSR ECHO

    ldy #$0         ; set buffer ptr to 0
_get_line:
    jsr GETCHAR
    CMP #$60
    BMI _convert
    AND #$5F
_convert:
    ORA #$80
    jsr ECHO
    cmp #$8D        ; carriage return
    beq _get_line_done
    cmp #$88        ; backspace
    beq _backspace
    sta BUFIN,y
    iny
    jmp _get_line

_backspace:
    dey
    bmi _get_line
    lda #$A0
    jsr ECHO
    lda #$88
    jsr ECHO
    jmp _get_line

_get_line_done:
    lda #$0         ; zero terminate the buffer
    sta BUFIN,y
   
    lda #$0D        ; new line
    jsr ECHO
    lda prompt        ; indicator
    jsr ECHO

    jsr _clear_lcd_screen

_print_line:
    ldy #$FF
_print_line_loop:
    iny
    lda BUFIN,y
    beq QUIT
    jsr ECHO
    and #$7F
    phy
    jsr send_lcd_write_4bit_char
    ply
    jmp _print_line_loop

QUIT:
    lda #$0D        ; new line
    jsr ECHO

    RTS             ; back to monitor

_clear_lcd_screen:
    lda #%00000010	; Move cursor to home
	jsr send_lcd_write_4bit_instruction
    ldy #$40
_clear_screen_loop:
    lda #" "        ; write 64 spaces to LCD
    phy
    jsr send_lcd_write_4bit_char
    ply
    dey
    beq _end_clear_screen_loop
    jmp _clear_screen_loop
_end_clear_screen_loop
    lda #%00000010	; Move cursor to home
	jsr send_lcd_write_4bit_instruction
    rts

prompt: .BYTE ">"

message:
    .BYTE "    TTY TEST        "
    .BYTE "    19200 8N1"
    .BYTE ""
    .BYTE ""
    .BYTE 0
