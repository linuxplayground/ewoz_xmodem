    .include 'romsymbols.inc'
    .include 'zp.s'

    .org $1000
reset:
    ; init lcd and send message
    JSR lcd_init

    LDA #<message
    LDX #>message
    JSR send_lcd_message

    JSR lcd_cursor_off

    LDA #$0D
    JSR ECHO        ;* New line.
PROMPT:
    JSR GETCHAR     ;get a character
    JSR ECHO
    JSR send_lcd_write_4bit_char
    JMP PROMPT

prompt: .byte ">"

message:
    .byte "    TTY TEST        "
    .byte "    19200 8N1"
    .byte ""
    .byte ""
    .byte 0
