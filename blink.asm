    .include "romsymbols.inc"
    .include "via.inc"
    .include "acia.inc"

    .org $2000

;
; main
;
main:
    lda #%00000001                          ; Set bottom 1 pin to output.
    sta VIA2_DDRA

loop:
    lda #%00000001
    sta VIA2_PORTA
    ldy #$ff
    jsr Delay_ms
    lda #%00000000
    sta VIA2_PORTA
    ldy #$ff
    jsr Delay_ms
    jsr monrdkey
    bcc loop
    ;cmp #$1B   ; excape key
    cmp #$03    ; CTRL+C
    beq exit
    jmp loop

monrdkey:
    lda ACIA_SR
    and #$08
    beq nokeypress 
    lda ACIA_DAT
    sec
    rts 
nokeypress:
    clc
    rts
exit:
    lda #$0
    sta VIA2_PORTA
    rts

