; libi2c
ZP_X            = $10
ZP_Y            = $11
ZP_A            = $12
ZP_I2C_DATA     = $13
LCD_TEMP        = $14
LCD_4BIT_BUF    = $15
LCD_STRPTR      = $16       ; 2 bytes
LCD_STRPTR_HI   = $17       ; reserved
; libspi
inb             = $18
outb            = $19

; ewoz
XAML            = $24       ;*Index pointers
XAMH            = $25
STL             = $26
STH             = $27
L               = $28
H               = $29
YSAV            = $2A
MODE            = $2B
MSGL            = $2C
MSGH            = $2D
COUNTER         = $2E
CRC             = $2F
CRCCHECK        = $30
IRQ_LOC         = $31       ; *IRC Location
IRQ_LOC_H       = $32       ; reserved
    
; xmodem    
crc		        = $33		; CRC lo byte  (two byte variable)
crch	        = $34		; CRC hi byte  
ptr		        = $35		; data pointer (two byte variable)
ptrh    	    = $36		;   "    " 
blkno	        = $37		; block number 
retry   	    = $38		; retry counter 
retry2	        = $39		; 2nd counter
bflag	        = $3a		; block flag 