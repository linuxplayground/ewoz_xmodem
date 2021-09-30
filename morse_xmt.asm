    .include "via.s"
    .include "zp.s"
    .include "romsymbols.inc"

PIN = %00000010
STRPTR  = $50
STRPTRH = $51

    ;
    ; Macro to turn on buzzer pin
    ;
    .macro beepon
        pha
        lda PORTB
        ora #PIN
        sta PORTB
        pla
    .endmacro

    ;
    ; Macro to turn off buzzer pin
    ;
    .macro beepoff
        pha
        lda PORTB
        eor #PIN
        sta PORTB
        pla
    .endmacro


    .org $1000

    ; generate a single beep long or short.
    ; uses an active buzzer to avoid having
    ; to calculate notes



; Routines
dot:
    phy
    beepon
    ldy #$50
    jsr Delay_ms
    beepoff
    ply
    rts

dash:
    phy
    beepon
    ldy #$150
    jsr Delay_ms
    beepoff
    ply
    rts

igap:               ; gap between dots and dashes within a character
    phy
    ldy #$50
    jsr Delay_ms
    ply
    rts

sgap:               ; gap between characters within a word
    phy
    ldy #$150
    jsr Delay_ms
    ply
    rts

lgap:               ; gap between words
    phy
    ldy #$350
    jsr Delay_ms
    ply
    rts

;
; Sends a character by looking up it's pattern in the charmap
; A contains ASCII value to send.
; 
char:
    sbc #65                ; Get the zero based index of the char
    tax
    ldy #0
.charloop:
    lda charmap,x
    cmp #1
    beq .is_dot
    cmp #2
    beq .is_dash
    rts                     ; return as soon as the value is a zero
.is_dot:
    jsr dot
    jmp .continue
.is_dash:
    jsr dash
.continue:
    jsr sgap                ; every element followed by a short gap
    inx
    iny
    cmp #5                  ; maximum 5 elements
    bne charloop
    rts

string:
    ldy #0
.stringloop:
    lda (STRPTR),y
    cmp #" "
    beq .is_space
    jsr char
    jmp .continue
.is_space:
    jsr lgap
.continue:
    iny
    bne .stringloop
    rts

; charmap - maps letters to a code.
; $1 = dot
; $2 = dash
; use indirect addressing to find the sequence for each letter.
; sequences are 0 terminated and awlays 8 bits wide.
charmap:
    .byte 1,2,0,0,0         ; A .-
    .byte 2,1,1,1,0         ; B -...
    .byte 2,1,2,1,0         ; C -.-.
    .byte 2,1,1,0,0         ; D -..
    .byte 1,0,0,0,0         ; E .
    .byte 1,1,2,1,0         ; F ..-.

message: .asciiz "ABC DEF"