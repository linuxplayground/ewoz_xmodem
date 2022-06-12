    .include 'romsymbols.inc'
    .include 'zp.s'

    .org $1000

reset:
    ; init lcd and send message
    jsr lcd_init

    lda #<message
    ldx #>message
    jsr send_lcd_message

    jsr lcd_cursor_off

    ; init led and set intensity
    jsr led_init

    lda #SHUTDOWN
    ldx #1
    jsr spisend

    lda #INTENSITY
    ldx #0
    jsr spisend

COL =$60
ROW =$61

    lda #8          ; 8th col
    sta ROW
    ldx #%00000001  ; bottom row
    stx COL

right:
    jsr tick
    dec ROW
    bne right
    ; row is now 0
    lda #1
    sta ROW ; reset row to 1
    clc     ; clear carr
    rol COL
    bcs exit    ; exit if we get to top.
left:
    jsr tick
    inc ROW
    lda ROW
    cmp #8
    bne left
    clc
    rol COL
    bcs exit
    jmp right



tick:
    lda ROW
    ldx COL
    jsr spisend
    ldy #50
    jsr Delay_ms
    ldx #0
    lda ROW
    jsr spisend
    ldy #50
    jsr Delay_ms
    rts

exit:
    rts

message:
        .byte "    LED Matrix      "
        .byte " MAX 7219 IC Driver "
        .byte "  SPI Interface to  "
        .byte "   ~ Homebrew ~     "
        .byte 0