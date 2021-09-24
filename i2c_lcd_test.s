    .include "liblcd.s"

    .org $1000

    jsr lcd_init

    lda #<message
    ldx #>message
    jsr send_lcd_message

    jsr lcd_cursor_off
    rts

message:
        .byte "    LCD Works!      "
        .byte " without having to  "
        .byte " i2c is hard enough "
        .byte "  deal with LCD     "
        .byte 0

       
