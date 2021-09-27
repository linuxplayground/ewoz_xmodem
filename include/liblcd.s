    .include "libi2c.s"
    .include "util.s"
    .include "zp.s"

LCD_RS = %00000001
LCD_RW = %00000010
LCD_EN = %00000100
LCD_BT = %00001000

ADDRESS = $27           ; i2c address of LCD display

    .org $B300
; ---------------------------------------------
; Send a string of text to the LCD Display
; A = msg low byte
; X = msg high byte
; ---------------------------------------------
send_lcd_message:
    sta LCD_STRPTR
    stx LCD_STRPTR + 1

    stz ZP_Y
.loop:
    ldy ZP_Y
    lda (LCD_STRPTR),y
    beq .end_lcd_message
    jsr send_lcd_write_4bit_char
    ldy ZP_Y
    iny
    sty ZP_Y
    jmp .loop
.end_lcd_message:
    rts

; ---------------------------------------------
; Initialise LCD Display
; ---------------------------------------------
lcd_init:
    lda #%11000100              ; Function set 8 bits long
    jsr send_lcd_write_8bit
    lda #%11000000              ; Function set 8 bits long ENABLE
    jsr send_lcd_write_8bit

    lda #%11000100              ; Function set 8 bits long
    jsr send_lcd_write_8bit
    lda #%11000000              ; Function set 8 bits long ENABLE
    jsr send_lcd_write_8bit

    ldy #100
    jsr Delay_ms                ; 5 millisecond delay after every operation

    lda #%11000100              ; Function set 8 bits long
    jsr send_lcd_write_8bit
    lda #%11000000              ; Function set 8 bits long ENABLE
    jsr send_lcd_write_8bit

    lda #%00100100
    jsr send_lcd_write_8bit     ; Set to 4 bit mode
    lda #%00100000
    jsr send_lcd_write_8bit     ; Set to 4 bit mode ENABLE

    lda #%00101000
    jsr send_lcd_write_4bit_instruction     ; Set to 2 lines, 8x5 font

    lda #%00001000
    jsr send_lcd_write_4bit_instruction     ; turn display off

    lda #%00000001
    jsr send_lcd_write_4bit_instruction     ; clear display
    

    lda #%00000010
    jsr send_lcd_write_4bit_instruction     ; Increment cursor, do not shift display

    lda #%00001110
    jsr send_lcd_write_4bit_instruction     ; Turn display on

    rts

lcd_cursor_off:
    lda #%00001100
    jsr send_lcd_write_4bit_instruction
    
    rts
; ---------------------------------------------
; A contains data to send
; ---------------------------------------------
send_lcd_write_8bit:

    pha             ; save value to the stack
    jsr I2C_Start
    lda #ADDRESS
    clc             ; write mode
    jsr I2C_SendAddr
    pla             ; pull the value from the stack
    jsr I2C_SendByte
    jsr I2C_Stop
    rts

; ---------------------------------------------
; A contains instruction to send
; RS = 0, RW = 0
; ---------------------------------------------
send_lcd_write_4bit_instruction:
    sta LCD_TEMP    ; save the full byte
    and #$f0 ; mask out bottom 4 bits
    sta LCD_4BIT_BUF
    ora #(LCD_EN|LCD_BT)
    jsr send_lcd_write_8bit
    lda LCD_4BIT_BUF
    ora #(LCD_BT)
    jsr send_lcd_write_8bit
    ; high nibble done.
    lda LCD_TEMP
    asl
    asl
    asl
    asl
    sta LCD_4BIT_BUF
    ora #(LCD_EN|LCD_BT)
    jsr send_lcd_write_8bit
    lda LCD_4BIT_BUF
    ora #(LCD_BT)
    jsr send_lcd_write_8bit
    ; low nibble done.
    ldy #1
    jsr Delay_ms
    rts

; ---------------------------------------------
; A contains data to send
; RS = 0, RW = 0
; ---------------------------------------------
send_lcd_write_4bit_char:
    sta LCD_TEMP    ; save the full byte
    and #$f0 ; mask out bottom 4 bits
    sta LCD_4BIT_BUF
    ora #(LCD_RS|LCD_EN|LCD_BT)
    jsr send_lcd_write_8bit
    lda LCD_4BIT_BUF
    ora #(LCD_RS|LCD_BT)
    jsr send_lcd_write_8bit
    ; high nibble done.
    lda LCD_TEMP
    asl
    asl
    asl
    asl
    sta LCD_4BIT_BUF
    ora #(LCD_RS|LCD_EN|LCD_BT)
    jsr send_lcd_write_8bit
    lda LCD_4BIT_BUF
    ora #(LCD_RS|LCD_BT)
    jsr send_lcd_write_8bit
    ; low nibble done.
    ldy #1
    jsr Delay_ms
    rts
