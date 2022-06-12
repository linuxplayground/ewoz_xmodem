    .include "via.s"
    .include "zp.s"
    .include "romsymbols.inc"

PIN = %10000000
STRPTR  = $50
STRPTRH = $51

    .org $1000

    stz $400
    stz $401
    stz $402
    stz $403
    stz $404
    stz $405
    
    lda #$ff
    sta DDRB
    ; generate a single beep long or short.
    ; uses an active buzzer to avoid having
    ; to calculate notes

    lda #<message
    sta STRPTR
    lda #>message
    sta STRPTR+1

    jsr string
    rts

; Routines

beepon:
    pha
    lda #PIN
    sta PORTB
    pla
    rts

beepoff:
    pha
    lda #0
    sta PORTB
    pla
    rts

dot:
    phy
    phx
    jsr beepon
    ldx #3
    jsr gap
    jsr beepoff
    plx
    ply
    rts

dash:
    phy
    phx
    jsr beepon
    ldx #9
    jsr gap
    jsr beepoff
    ply
    rts

igap:               ; gap between dots and dashes within a character
    phy
    phx
    ldx #3
    jsr gap
    plx
    ply
    rts

sgap:               ; gap between characters within a word
    phy
    phx
    ldx #9
    jsr gap
    plx
    ply
    rts

lgap:               ; gap between words
    phy
    phx
    ldx #21         
    jsr gap
    plx
    ply
    rts

gap:
    phx
    ldy #50
    jsr Delay_ms
    plx
    dex
    bne gap
    rts
;
; Sends a character by looking up it's pattern in the charmap
; A contains ASCII value to send.
; 
char:
    sbc #$41                ; Get the zero based index of the char
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
    bne .charloop
    rts

string:
    ldy #0
.stringloop:
    lda (STRPTR),y
    beq .exit
    cmp #" "
    beq .is_space
    jsr char
    jmp .continue
.is_space:
    jsr sgap
.continue:
    iny
    jmp .stringloop
.exit
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