    .include "romsymbols.inc"
PORTB = $8800                               ; VIA port B
PORTA = $8801                               ; VIA port A
DDRB = $8802                                ; Data Direction Register B
DDRA = $8803                                ; Data Direction Register A

E =  %10000000
RW = %01000000
RS = %00100000

ACIA        = $8400
ACIA_CTRL   = ACIA+3
ACIA_CMD    = ACIA+2
ACIA_SR     = ACIA+1
ACIA_DAT    = ACIA

    .org $2000

;
; main
;
main:
    lda #%00000001                          ; Set bottom 1 pin to output.
    sta DDRA

loop:
    lda #%00000001
    sta PORTA
    ldy #$ff
    jsr Delay_ms
    lda #%00000000
    sta PORTA
    ldy #$ff
    jsr Delay_ms
    jsr monrdkey
    bcc loop
    ;cmp #$1B
    cmp #$03
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
    sta PORTA
    rts

