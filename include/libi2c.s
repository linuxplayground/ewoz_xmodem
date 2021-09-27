
I2C_DATABIT     = %00000010
I2C_CLOCKBIT    = %00000001
I2C_DDR         = $9002     ; use port b
I2C_PORT        = $9000     ; use port b

    .org $B400

;------------------------------------------------------------------------------
    .macro i2c_data_up
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #I2C_DATABIT  ; Clear data bit of the DDR
        trb   I2C_DDR       ; to make bit an input and let it float up.
    .endmacro


;------------------------------------------------------------------------------
    .macro i2c_data_down
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #I2C_DATABIT  ; Set data bit of the DDR
        tsb   I2C_DDR       ; to make bit an output and pull it down.
    .endmacro


;------------------------------------------------------------------------------
    .macro i2c_clock_up
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #I2C_CLOCKBIT
        trb   I2C_DDR
    .endmacro


;------------------------------------------------------------------------------
    .macro i2c_clock_down
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #I2C_CLOCKBIT
        tsb   I2C_DDR
    .endmacro


;------------------------------------------------------------------------------
    .macro i2c_clock_pulse
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
        lda   #I2C_CLOCKBIT
        trb   I2C_DDR           ; Clock up
        tsb   I2C_DDR           ; Clock down
    .endmacro


;------------------------------------------------------------------------------
I2C_Start:
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
    i2c_data_up
    i2c_clock_up
    i2c_data_down
    i2c_clock_down
    i2c_data_up
    rts


;------------------------------------------------------------------------------
I2C_Stop:
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
    i2c_data_down
    i2c_clock_up
    i2c_data_up
    i2c_clock_down
    i2c_data_up
    rts


;------------------------------------------------------------------------------
I2C_SendAck:
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
    i2c_data_down       ; Acknowledge.  The ACK bit in I2C is the 9th bit of a "byte".
    i2c_clock_pulse     ; Trigger the clock
    i2c_data_up         ; End with data up
    rts


;------------------------------------------------------------------------------
I2C_SendNak:
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
    i2c_data_up         ; Acknowledging consists of pulling it down.
    i2c_clock_pulse     ; Trigger the clock
    i2c_data_up
    rts


;------------------------------------------------------------------------------
I2C_ReadAck:
;------------------------------------------------------------------------------
; Ack in carry flag (clear means ack, set means nak)
; Destroys A
;------------------------------------------------------------------------------
    i2c_data_up         ; Input
    i2c_clock_up        ; Clock up
    clc                 ; Clear the carry
    lda I2C_PORT        ; Load data from the port
    and #I2C_DATABIT    ; Test the data bit
    beq .skip           ; If zero skip
        sec             ; Set carry if not zero
.skip:
    i2c_clock_down      ; Bring the clock down
    rts


;------------------------------------------------------------------------------
I2C_Init:
;------------------------------------------------------------------------------
; Destroys A
;------------------------------------------------------------------------------
    lda #(I2C_CLOCKBIT | I2C_DATABIT) 
    tsb I2C_DDR
    trb I2C_PORT
    rts


;------------------------------------------------------------------------------
I2C_Clear:
;------------------------------------------------------------------------------
; This clears any unwanted transaction that might be in progress, by giving 
; enough clock pulses to finish a byte and not acknowledging it.
; Destroys  A 
;------------------------------------------------------------------------------
    phx                     ; Save X
    jsr I2C_Start
    jsr I2C_Stop
    i2c_data_up             ; Keep data line released so we don't ACK any byte sent by a device.
    ldx #9                  ; Loop 9x to send 9 clock pulses to finish any byte a device might send.
    lda #I2C_CLOCKBIT
.do:
        trb I2C_DDR         ; Clock up
        tsb I2C_DDR         ; Clock down
        dex
        bne .do
    plx                     ; Restore X
    jsr I2C_Start
    jmp I2C_Stop            ; (JSR, RTS)


;------------------------------------------------------------------------------
I2C_SendByte:
;------------------------------------------------------------------------------
; Sends the byte in A
; Destroys A
;------------------------------------------------------------------------------
    stx ZP_X                ; Save X
    sta ZP_I2C_DATA         ; Save to variable
    ldx #8                  ; We will do 8 bits.
.loop:
        lda #I2C_DATABIT    ; Init A for mask for TRB & TSB below.    
        trb I2C_DDR         ; Release data line.  This is like i2c_data_up but saves 1 instruction.
        asl ZP_I2C_DATA     ; Get next bit to send and put it in the C flag.
        bcs .continue
            tsb I2C_DDR     ; If the bit was 0, pull data line down by making it an output.
.continue:
        
        i2c_clock_pulse     ; Pulse the clock
        dex
    bne .loop  
    ldx ZP_X                ; Restore variables
    jmp I2C_ReadAck         ; Put ack in Carry


;------------------------------------------------------------------------------
I2C_ReadByte:
;------------------------------------------------------------------------------
; Start with clock low.  Ends with byte in A.  Do ACK separately.
;------------------------------------------------------------------------------
    stx ZP_X                ; Save X
    sta ZP_I2C_DATA         ; Define local zeropage variable

    i2c_data_up             ; Make sure we're not holding the data line down.  Be ready to input data.
    ldx #8                  ; We will do 8 bits.  
    lda #I2C_CLOCKBIT       ; Load the clock bit in for initial loop
    stz ZP_I2C_DATA         ; Clear data
    clc                     ; Clear the carry flag
.loop:
        trb I2C_DDR         ; Clock up
        nop                 ; Delay for a few clock cycles
        nop
        nop
        nop
        lda I2C_PORT        ; Load PORTA
        
        and #I2C_DATABIT    ; Mask off the databit
        beq .skip           ; If zero, skip
            sec             ; Set carry flag
.skip:
        rol ZP_I2C_DATA     ; Rotate the carry bit into value / carry cleared by rotated out bit
        lda #I2C_CLOCKBIT   ; Load the clock bit in
        tsb I2C_DDR         ; Clock down
        nop                 ; Delay for a few clock cycles
        nop
        nop
        nop
        dex
    bne .loop               ; Go back for next bit if there is one.

    lda ZP_I2C_DATA         ; Load A from local
    ldx ZP_X                ; Restore variables
    rts


;------------------------------------------------------------------------------
I2C_SendAddr:
;------------------------------------------------------------------------------
; Address in A, carry flag contains read/write flag (read = 1, write 0)
; Return ack in Carry
;------------------------------------------------------------------------------
    rol A                   ; Rotates address 1 bit and puts read/write flag in A
    jmp I2C_SendByte        ; Sends address and returns

