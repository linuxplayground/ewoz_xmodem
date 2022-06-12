    .include "libspi.s"

    .org $B100
led_init:
    lda #%00000111  ; nc/nc/nc/nc/nc/mosi/cs/sck
    sta DDRA

    lda #CS         ; cs high
    sta PORTA

    lda #DISPLAY_TEST
    ldx #0
    jsr spisend

    lda #SCAN_LIMIT
    ldx #7
    jsr spisend

    lda #DECODE_MODE
    ldx #0
    jsr spisend

    jsr led_clear

    lda #SHUTDOWN
    ldx #0
    jsr spisend

    rts

; this ends up sending a nop on the last loop which is fine.
led_clear:
    ldx #9
.loop:
    dex
    beq .exit
    phx
    txa
    ldx #%00000000  ; each column has 8 dots.  turn them all off
    jsr spisend
    plx
    jmp .loop
.exit
    rts

; A = command, X = value
; borks both A and X
spisend:
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