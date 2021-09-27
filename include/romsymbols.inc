RESET	= $A000
SOFTRESET	= $A02A
NOTCR	= $A02C
ESCAPE	= $A037
GETLINE	= $A03C
BACKSPACE	= $A043
NEXTCHAR	= $A050
CONVERT	= $A060
SETSTOR	= $A071
SETMODE	= $A072
BLSKIP	= $A074
NEXTITEM	= $A075
NEXTHEX	= $A098
DIG	= $A0A7
HEXSHIFT	= $A0AD
NOTHEX	= $A0B8
RUN	= $A0BF
ACTRUN	= $A0C5
LOADINT	= $A0C8
RUNXMODEM	= $A0CE
NOESCAPE	= $A0D4
TONEXTITEM	= $A0E2
NOTSTOR	= $A0E5
SETADR	= $A0E9
NXTPRNT	= $A0F2
PRDATA	= $A108
XAMNEXT	= $A112
MOD8CHK	= $A124
PRBYTE	= $A12A
PRHEX	= $A133
ECHO	= $A13D
SHWMSG	= $A14C
LOADINTEL	= $A159
INTELLINE	= $A172
FINDCOL	= $A183
NODOT	= $A1B3
INTELSTORE	= $A1BF
TESTCOUNT	= $A1CF
INTELDONE	= $A1E4
OKMESS	= $A1FE
GETHEX	= $A214
DONEFIRST	= $A21F
DONESECOND	= $A231
GETCHAR	= $A237
MSG1	= $A242
MSG2	= $A27C
MSG3	= $A29B
MSG4	= $A2B2
XModem	= $A500
StartCrc	= $A509
StartBlk	= $A51F
GotByte	= $A52E
GotByte1	= $A533
BegBlk	= $A53E
GetBlk	= $A540
GetBlk1	= $A544
GetBlk2	= $A549
GoodBlk1	= $A561
GoodBlk2	= $A570
CalcCrc	= $A572
BadCrc	= $A58C
GoodCrc	= $A597
CopyBlk	= $A5B1
CopyBlk3	= $A5B3
CopyBlk4	= $A5BE
IncBlk	= $A5C3
Done	= $A5CD
GetByte	= $A5D9
StartCrcLp	= $A5DD
GetByte1	= $A5EB
Flush	= $A5EC
Flush1	= $A5F0
PrintMsg	= $A5F6
PrtMsg1	= $A5F8
PrtMsg2	= $A603
Msg	= $A604
Print_Err	= $A63A
PrtErr1	= $A63C
PrtErr2	= $A647
ErrMsg	= $A648
Print_Good	= $A658
Prtgood1	= $A65A
Prtgood2	= $A665
GoodMsg	= $A666
Get_Chr	= $A67B
Get_Chr2	= $A687
Put_Chr	= $A688
Put_Chr1	= $A689
UpdCrc	= $A695
crclo	= $A700
crchi	= $A800
Delay_ms	= $B000
led_init	= $B100
led_clear	= $B12A
spisend	= $B13B
spibyte	= $B200
spibytelp	= $B208
spibyte1	= $B20F
spibyte2	= $B21D
send_lcd_message	= $B300
lcd_init	= $B318
lcd_cursor_off	= $B35F
send_lcd_write_8bit	= $B365
send_lcd_write_4bit_instruction	= $B377
send_lcd_write_4bit_char	= $B3A3
I2C_Start	= $B400
I2C_Stop	= $B41A
I2C_SendAck	= $B434
I2C_SendNak	= $B447
I2C_ReadAck	= $B45A
I2C_Init	= $B473
I2C_Clear	= $B47C
I2C_SendByte	= $B49C
I2C_ReadByte	= $B4BE
I2C_SendAddr	= $B4F0
IRQ	= $FFE0