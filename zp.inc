; ewoz
XAML        = $24            ;*Index pointers
XAMH        = $25
STL         = $26
STH         = $27
L           = $28
H           = $29
YSAV        = $2A
MODE        = $2B
MSGL        = $2C
MSGH        = $2D
COUNTER     = $2E
CRC         = $2F
CRCCHECK    = $30

IRQ_LOC     = $31           ; *IRC Location

; xmodem
crc		    =	$38		; CRC lo byte  (two byte variable)
crch	    =	$39		; CRC hi byte  

ptr		    =	$3a		; data pointer (two byte variable)
ptrh    	=	$3b		;   "    "

blkno	    =	$3c		; block number 
retry   	=	$3d		; retry counter 
retry2	    =	$3e		; 2nd counter
bflag	    =	$3f		; block flag 