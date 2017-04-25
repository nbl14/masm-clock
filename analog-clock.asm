;******************************************************
; Original Author(s): Unknown
; Author:             Nabeel Ahmad
; Description: Graphical analog clock display
;              Use MASM to build and DOSBox to run

.286;**************************************************
STACK_SEG     SEGMENT   STACK
    STACK_BUF DW        120 DUP(?)
    TOP       EQU       $-STACK_BUF
STACK_SEG     ENDS
;******************************************************

;******************************************************
DATA_SEG      SEGMENT   PARA
;------------------------------------------------------
TS1           DB        0
QUITBUF       DB        '    N3CLOCKP   '
QUITBUF2      DB        'Press q to Quit'
SIGLE         DB        80H
ABSX          DW        0
ABSY          DW        0
SUT           DW        0
ERROYBZ       DB        0
R0            DW        55
X0            DW        320
Y0            DW        245

COUNT0        DB        0
COUNT_HOUR    DB        11
COUNT_MINUTE  DB        11
YUANXINX      DW        0
YUANXINY      DW        0

S             DB        0
S2            DB        0
S3            DB        0
HOUR          DW        0
HOUR2         DW        0
MINUTE        DW        0
MINUTE2       DW        0
SECOND        DB        0
SECOND2       DB        0
MSECOND       DB        0
MSECOND2      DB        0
SIN_X         DW        0
SIN_XX        DW        0
X             DW        0
Y             DW        0
X1            DW        0

XMINY         DW        0
YMINX         DW        0
XMAX          DW        0
YMAX          DW        0
YMIN          DW        0
XMIN          DW        0
SJX_XMINY     DW        0
SJX_YMINX     DW        0
SJX_XMAX      DW        0
SJX_YMAX      DW        0
SJX_YMIN      DW        0
SJX_XMIN      DW        0
YUANX         DW        0
YUANY         DW        0
Y1            DW        0
X2            DW        0
Y2            DW        0
X3            DW        0
Y3            DW        0
DIANCOLOR     DB        0
COLOR         DB        2
COLOR_HOUR    DB        2
COLOR_MIN     DB        6
COLOR_SECOND  DB        9
COLOR_MSECOND DB        5
COLOR4        DB        10
COLOR5        DB        11
COLOR6        DB        12
BACKGROUNDCOLOR DB      1
PAGE1         DB        0
Y2Y1          DW        0
X2X1          DW        0
SJX_Y2Y1      DW        0
SJX_X2X1      DW        0

; Begins, edit by Nabeel
TEMP1         DB        00
TEMP2         DB        00
COLON         DB        3AH
DOW           DW        00

DAY1          DB        " SUNDAY  $"
DAY2          DB        " MONDAY  $"
DAY3          DB        " TUESDAY $"
DAY4          DB        "WEDNESDAY$"
DAY5          DB        " THIRSDAY$"
DAY6          DB        " FRIDAY  $"
DAY7          DB        " SATURDAY$"
; Ends, edit by Nabeel

;------------------------------------------------------

DATA_SEG      ENDS
;******************************************************


;******************************************************
CODE_SEG      SEGMENT   PARA
;------------------------------------------------------
MAIN          PROC      FAR
              ASSUME    CS:CODE_SEG, DS:DATA_SEG
              ASSUME    SS:STACK_SEG
START:
              MOV       AX, STACK_SEG
              MOV       SS, AX
              MOV       SP, TOP
              MOV       AX, DATA_SEG
              MOV       DS, AX
;------------------------------------------------------

;------------------------------------------------------
BEG:          MOV       AX, 0012H
              INT       10H
              CALL      B1002
              MOV       DX, 0033
              LEA       BP, QUITBUF
              CALL      MSG
              MOV       DX, 193FH
              LEA       BP, QUITBUF2
              CALL      MSGRED

BEG2:         CALL      SKIN
              CALL      SKIN2
              CALL      SKIN3
              CALL      CLK
              MOV       SECOND, DH
              MOV       SECOND2, DH
              ; Begins, edit by Nabeel for Milliseconds hand
              PUSHA
              MOV       AH, 2CH
              INT       21H
              MOV       AX, 59
              MOV       CL, DL
              MUL       CL
              MOV       CL, 99
              DIV       CL
              MOV       DH, AL
              MOV       MSECOND, DH
              MOV       MSECOND2, DH
              POPA
              ; Ends, edit by Nabeel for Milliseconds hand
              ; Nabeel: MAYBE ADD THIS:         CALL        SECOND_LIN
              MOV       COUNT_MINUTE, 11
              CALL      MINUTE_LIN
              XOR       DX, DX
              MOV       AX, MINUTE2
              MOV       CX, 12
              DIV       CX
              MOV       CX, AX                 ;MINURTE2/12
              POP       AX
              ADD       AX, CX
              MOV       HOUR2, AX
              MOV       COUNT_HOUR, 11
              CALL      HOUR_LIN
              CALL      CLK
              MOV       DL, DH
              MOV       AL, DL
              XOR       AH, AH
              MOV       CL, 12
              DIV       CL
              MOV       COUNT_MINUTE, AH            ;SECOND%12
              DEC       COUNT_MINUTE

              XOR       DX, DX
              MOV       AX, MINUTE2
              MOV       CX, 12
              DIV       CX                        ;MINURTE2%12
              MOV       COUNT_HOUR, DL
              DEC       COUNT_HOUR
              INC       SECOND2
KK3:          CLI
              CALL      MSECOND_LIN
              STI
              ; //////////////////////////////////
NCODE:        MOV AH, 2
              MOV       BH, 0
              MOV       DH, 2
              MOV       DL, 21
              INT       10H

              MOV       AH, 2AH
              INT       21H

SDATE:
              MOV       AH, 00
              MOV       DOW, AX
              MOV       AL, DL
              CALL      CONV
              MOV       TEMP2, ':'
              CALL      DSPLAY1
              MOV       AL, DH
              CALL      CONV
              MOV       TEMP2, ':'
              CALL      DSPLAY1
              MOV       AL, 20
              CALL      CONV
              MOV       AX, CX
              MOV       DX, 0H
              MOV       BX, 7D0H
              DIV       BX
              MOV       AL, DL
              CALL      CONV
              CALL      SHOWDAY


              MOV       AH, 2
              MOV       BH, 0
              MOV       DH, 3
              MOV       DL, 35
              INT       10H

              MOV       AH, 2CH
              INT       21H

STIME:
              MOV       AL, CH
              CALL      CONV

              MOV       TEMP2, ':'
              CALL      DSPLAY1

              MOV       AL, CL
              CALL      CONV

              MOV       TEMP2, ':'
              CALL      DSPLAY1

              MOV       AL, DH
              CALL      CONV

              MOV       TEMP2, ':'
              CALL      DSPLAY1
              MOV       AX, 59
              MOV       CL, DL
              MUL       CL
              MOV       CL, 99
              DIV       CL
              CALL      CONV
              ; //////////////////////////////////
              JMP       KS


KS:           MOV       AH, 1
              INT       16H
              JZ        KK3
              MOV       AH, 8
              INT       21H
              CMP       AL, 'Q'
              JE        QUIT
              JMP       KK3


CHANGE_RS:    CMP       R0, 190
              JA        KS
              ADD       R0, 5

              JMP       TOBEG2
CHANGE_RB:    CMP       R0, 60
              JB        KS
              SUB       R0, 5

              JMP       TOBEG2
CHANGE_COLOR: LEA       SI, COLOR_HOUR
              MOV       CX, 6
CHANGE_KK1:   MOV       AL, [SI]
              INC       AL
              CMP       AL, 15
              JC        CHANGE_COLOR_KK2
              MOV       AL, 1
CHANGE_COLOR_KK2:
              MOV       [SI], AL
              INC       SI
              LOOP      CHANGE_KK1
              JMP       TOBEG2

TOBEG2:       CALL      CLEAR
              JMP       BEG2
QUIT:         MOV       AX, 4C00H
              INT       21H
;*************************************************


HOUR_LIN      PROC      NEAR
              PUSHA
              CMP       COUNT_HOUR, 11
              JB        TOHOUR_YL
              JMP       HOUR_LIN_NEXT
TOHOUR_YL:    MOV       SIGLE, 3
              JMP       HOUR_YL
HOUR_LIN_NEXT:
              MOV       COUNT_HOUR, 0
              MOV       SIGLE, 5
              CALL      CLK
              MOV       DL, CH
              MOV       AL, DL
              CMP       AL, 12
              JB        HOUR_KK1
              SUB       AL, 12
HOUR_KK1:     MOV       CL, 30
              MUL       CL
              PUSH      AX
              XOR       DX, DX
              MOV       AX, MINUTE2
              MOV       CX, 12
              DIV       CX
              MOV       CX, AX       ;MINURTE2/12
              POP       AX
              ADD       AX, CX

              MOV       HOUR2, AX

              MOV       COLOR, 0
              MOV       AX, HOUR
              MOV       BX, R0
              ADD       BX, 20
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              ADD       AX, 270
              ADD       BX, 400              ;90

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX

              MOV       DX, X0
              MOV       X1, DX
              MOV       DX, Y0
              MOV       Y1, DX
              CALL      SJX

              ADD       AX, 180
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX

              SUB       BX, 100
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              CALL      SJX

              MOV       SIGLE, 4

;*************************************************
HOUR_YL:      MOV       AL, COLOR_HOUR
              MOV       COLOR, AL
              MOV       AX, HOUR2
              MOV       BX, R0
              ADD       BX, 70
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              ADD       AX, 90
              ADD       BX, 600                ;90

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX

              ADD       AX, 180

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X1, DX
              MOV       DX, YUANY
              MOV       Y1, DX
              CALL      SJXX
              CALL      SJXY

              ADD       AX, 270
              SUB       BX, 100
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              CALL      SJX
              CALL      SJXX
              CALL      SJXY

              MOV       CX, HOUR2
              MOV       HOUR, CX
HOUR_QUIT:    POPA
              RET
HOUR_LIN      ENDP

;*************************************************


MINUTE_LIN    PROC      NEAR
              PUSHA
              CMP       COUNT_MINUTE, 11
              JB        TOMINUTE_YL
              JMP       MINUTE_LIN_NEXT
TOMINUTE_YL:  MOV       SIGLE, 0
              JMP       MINUTE_YL
MINUTE_LIN_NEXT:
              INC       COUNT_HOUR
              CALL      CLK
              MOV       DL, CL
              MOV       AL, DL
              MOV       CL, 6
              MUL       CL              ;AL*CL
              PUSH      AX
              MOV       DL, SECOND2
              MOV       AL, DL
              XOR       AH, AH
              MOV       CL, 12
              DIV       CL
              MOV       CL, AL       ;SECOND2/12
              POP       AX
              MOV       CH, 0
              ADD       AX, CX

              MOV       MINUTE2, AX

AAAA1:
              MOV       SIGLE, 2
              MOV       COLOR, 0
              MOV       AX, MINUTE
              MOV       BX, R0
              ADD       BX, 10
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              ADD       AX, 268
              ADD       BX, 800              ;90

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX

              MOV       DX, X0
              MOV       X1, DX
              MOV       DX, Y0
              MOV       Y1, DX
              CALL      SJX

              ADD       AX, 180
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX

              ADD       AX, 90
              SUB       BX, 200
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              CALL      SJX

;*************************************************

MINUTE_YL:    MOV       SIGLE, 1
              MOV       AL, COLOR_MIN
              MOV       COLOR, AL
              MOV       AX, MINUTE2
              MOV       BX, R0
              ADD       BX, 30
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              ADD       AX, 90
              ADD       BX, 900                ;90

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX

              ADD       AX, 180
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X1, DX
              MOV       DX, YUANY
              MOV       Y1, DX
              CALL      SJXX
              CALL      SJXY

              ADD       AX, 270
              SUB       BX, 200
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X3, DX
              MOV       DX, YUANY
              MOV       Y3, DX
              CALL      SJXX
              CALL      SJXY

              MOV       CX, MINUTE2
              MOV       MINUTE, CX
              CALL      HOUR_LIN

MINUTE_KK1:
MINUTE_QUIT:  POPA
              RET
MINUTE_LIN    ENDP

;******************IN   DH*********************
SECOND_LIN    PROC      NEAR
              PUSHA
              CALL      CLK
              ;CMP       SECOND2, DH
              ;JE        TO_SECOND_QUIT
              ;JMP       SECOND_LIN_NEXT
;TO_SECOND_QUIT:JMP       SECOND_QUIT
SECOND_LIN_NEXT:
              MOV       SIGLE, 80H
              MOV       SECOND2, DH
              MOV       COLOR, 0
              MOV       DL, SECOND             ;ERASE
              MOV       AL, DL
              MOV       AH, 0
              MOV       CL, 6
              MUL       CL
              MOV       BX, R0
              ADD       BX, 10
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X1, DX
              MOV       DX, YUANY
              MOV       Y1, DX
              ADD       AX, 180
              ADD       BX, 300

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX
              CALL      LINEX
              CALL      LINEY


              MOV       SIGLE, 80H
              MOV       AL, COLOR_SECOND
              MOV       COLOR, AL
              MOV       DL, SECOND2
              MOV       AL, DL
              MOV       AH, 0
              MOV       CL, 6
              MUL       CL

              MOV       BX, R0
              ADD       BX, 10
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X1, DX
              MOV       DX, YUANY
              MOV       Y1, DX

              ADD       AX, 180
              ADD       BX, 300
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX
              CALL      LINEX
              CALL      LINEY

              CALL      YUANXIN
              MOV       DL, SECOND2
              MOV       SECOND, DL
              ;CMP      DL, 57
              ;JNE      N_SECOND
              CALL      MINUTE_LIN
N_SECOND:     CALL      SKIN2
              MOV       CL, SECOND2
              MOV       SECOND, CL

              CMP       COUNT_MINUTE, 11
              JE        SECOND_KK1
              INC       COUNT_MINUTE
              JMP       SECOND_QUIT
SECOND_KK1:   MOV       COUNT_MINUTE, 0
SECOND_QUIT:  POPA
              RET
SECOND_LIN    ENDP

;******************IN   DH*********************
MSECOND_LIN   PROC      NEAR
              PUSHA
              ; Begins, edit by Nabeel for Milliseconds hand
              MOV       AH, 2CH
              INT       21H
              MOV       AX, 59
              MOV       CL, DL
              MUL       CL
              MOV       CL, 99
              DIV       CL
              MOV       DH, AL
              ; Ends, edit by Nabeel for Milliseconds hand
              CMP       MSECOND2, DH
              JE        TO_MSECOND_QUIT
              JMP       MSECOND_LIN_NEXT
TO_MSECOND_QUIT:
              JMP       MSECOND_QUIT
MSECOND_LIN_NEXT:
              MOV       SIGLE, 80H
              MOV       MSECOND2, DH
              MOV       COLOR, 0
              MOV       AL, MSECOND             ;ERASE  (Change by Nabeel: DL TO AL)
              MOV       AH, 0
              MOV       CL, 6
              MUL       CL
              MOV       BX, R0
              ADD       BX, 10
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X1, DX
              MOV       DX, YUANY
              MOV       Y1, DX
              ADD       AX, 180
              ADD       BX, 300

              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX
              CALL      LINEX
              CALL      LINEY


              MOV       SIGLE, 80H
              MOV       AL, COLOR_MSECOND
              MOV       COLOR, AL
              MOV       AL, MSECOND2             ; (Change by Nabeel: FORM DL TO AL)
              MOV       AH, 0
              MOV       CL, 6
              MUL       CL

              MOV       BX, R0
              ADD       BX, 10
              CALL      RENOVATE
              MOV       DX, YUANX
              MOV       X1, DX
              MOV       DX, YUANY
              MOV       Y1, DX

              ADD       AX, 180
              ADD       BX, 300
              CALL      RENOVATE

              MOV       DX, YUANX
              MOV       X2, DX
              MOV       DX, YUANY
              MOV       Y2, DX
              CALL      LINEX
              CALL      LINEY

              CALL      YUANXIN
              MOV       DL, MSECOND2
              MOV       MSECOND, DL

              CMP       DL, 56
              JB        SECOND_SKIP
              CALL      SECOND_LIN              ; (Change by Nabeel: MINUTE_LIN)
              ;PUSH     CX
              ;MOV      CL, SECOND
              ;CMP      MSECOND2, CL
              ;JNE      S_SKIP_2
              ;CALL     SECOND_LIN
;S_SKIP_2:    POP       CX
SECOND_SKIP:  CALL      SKIN2
              MOV       CL, MSECOND2
              MOV       MSECOND, CL

              ;CMP       COUNT_MINUTE, 11
              ;JE        MSECOND_KK1
              ;INC       COUNT_MINUTE
              ;JMP       MSECOND_QUIT
;MSECOND_KK1: MOV       COUNT_MINUTE, 0
MSECOND_QUIT: ;PUSH     CX
              ;MOV      CL, SECOND
              ;CMP      MSECOND2, CL
              ;JNE      S_SKIP_2
              ;CALL     SECOND_LIN
;S_SKIP_2:    POP       CX
              POPA
              RET
MSECOND_LIN   ENDP




;***************IN AX BX****************
;**********OUT X2->AX,Y2->DX ;**********
RENOVATE      PROC      NEAR
              PUSHA
              ADD       AX, 270
              PUSH      AX
              CALL      SIN
              MOV       DX, 0
              MOV       CX, BX
              DIV       CX
              CMP       SI, 1
              JE        HJIAN
              ADD       AX, Y0
              JMP       RENOVATE_KK1
HJIAN:        MOV       CX, Y0
              SUB       CX, AX
              MOV       AX, CX
RENOVATE_KK1: MOV       YUANY, AX
              POP       AX
              CALL      COS

              MOV       DX, 0
              MOV       CX, BX
              DIV       CX
              CMP       SI, 1
              JE        HJIAN2
              ADD       AX, X0
              JMP       RENOVATE_KK2
HJIAN2:        MOV      CX, X0
              SUB       CX, AX
              MOV       AX, CX
RENOVATE_KK2: MOV       YUANX, AX
              POPA
              RET
RENOVATE      ENDP
;**************************
CLK           PROC
              ;MOV      AH, 2
              ;INT      1AH
              MOV       AH, 2CH
              INT       21H
              RET
CLK           ENDP

;***************** COMPUTES COSINE  IN AX  OUT AX ******************
COS           PROC      NEAR

              ADD       AX, 90
COS_KK1:      CALL      SIN
              RET
COS           ENDP
;********* COMPUTES SIN  IN AX OUT AX *******************************
SIN           PROC      NEAR           ;OUT AX

              PUSH      CX
              PUSH      DX
              PUSH      BX
SIN360:       CMP       AX, 90
              JA        DY90
STO0_90:      MOV       SI, 0
              JMP       PP1
DY90:         CMP       AX, 180
              JBE       Z91TO180
              JMP       DY180
Z91TO180:     MOV       CX, 180
              SUB       CX, AX
              MOV       AX, CX
              MOV       SI, 0
              JMP       PP1
Z181TO270:    SUB       AX, 180
              MOV       SI, 1
              JMP       PP1
Z271TO360:    CMP       AX, 359
              JA        ZDY359
              MOV       CX, 360
              SUB       CX, AX
              MOV       AX, CX
              MOV       SI, 1
              JMP       PP1
ZDY359:       SUB       AX, 360
              JMP       SIN360

DY180:        CMP       AX, 270
              JBE       Z181TO270
              JMP       Z271TO360

PP1:          MOV       CX, 175
              XOR       DX, DX
              MUL       CX
              MOV       SIN_X, AX
              XOR       DX, DX
              MOV       CX, AX
              MUL       CX
              MOV       CX, 10000
              DIV       CX
              MOV       SIN_XX, AX
              XOR       DX, DX
              MOV       CX, 120
              DIV       CX
              MOV       BX, 1677;1667
              CALL      SUBAB
              MOV       CX, SIN_XX
              XOR       DX, DX
              MUL       CX
              MOV       CX, 10000
              DIV       CX               ;XX(XX/120-10000/6)
              MOV       CX, 10000
              MOV       DL, 0
              CMP       DL, S
              JE        JIA
              SUB       CX, AX
              MOV       AX, CX
              JMP       KK1
JIA:          ADD       AX, CX
KK1:          MOV       CX, SIN_X
              XOR       DX, DX
              MUL       CX
              MOV       CX, 10000
              DIV       CX
              POP       BX
              POP       DX
              POP       CX
              MOV       S, 0
              RET
SIN           ENDP


;************** |A-B| *************
SUBAB         PROC
              CMP       AX, BX
              JAE       GOAB
              XOR       S, 1
              XCHG      AX, BX
GOAB:
              SUB       AX, BX
              RET
SUBAB         ENDP


;***************************LINEX***Y=(Y2-Y1)*(X-X1)/(X2-X1)+Y1
;****IN (X1,Y1),(X2, Y2)******************X++
LINEX         PROC      NEAR
              PUSH      X1
              PUSH      X2
              PUSH      Y1
              PUSH      Y2
              PUSHA
              CALL      XYMAXMIN
              MOV       AX, Y2
              MOV       BX, Y1
              CALL      SUBAB
              MOV       Y2Y1, AX
              MOV       AX, X2
              MOV       BX, X1
              CALL      SUBAB
              MOV       SI, 0
              CMP       SI, AX
              JE        ZHIXIAN
              JMP       LOPX
ZHIXIAN:      JMP       ZHIXIANXS
LOPX:         MOV       X2X1, AX
              MOV       AX, XMIN
              MOV       X, AX
LINE0X:       SUB       AX, XMIN
              MOV       DX, 0
              MOV       CX, Y2Y1
              MUL       CX
              MOV       CX, X2X1
              DIV       CX
              MOV       DX, 0
              CMP       DL, S

              JE        ZHENGX
              MOV       CX, AX
              MOV       AX, XMINY
              SUB       AX, CX
              JMP       KK2X
ZHENGX:       ADD       AX, XMINY
KK2X:         MOV       Y, AX
              CALL      DIAN

              INC       X
              MOV       AX, X
              CMP       AX, XMAX
              JBE       LINE0X
              JMP       QUIT12

ZHIXIANXS:    MOV       AX, XMIN
              MOV       X, AX
              MOV       AX, YMIN
              MOV       Y, AX
LOPXX:        CALL      DIAN

              INC       Y
              MOV       AX, YMAX
              CMP       AX, Y
              JAE      LOPXX
 QUIT12:      MOV       S, 0
              POPA
              POP       Y2
              POP       Y1
              POP       X2
              POP       X1
              RET
LINEX         ENDP


;**************************LINEY      X=(X2-X1)(Y-Y1)/(Y2-Y1)+X1
;*****************Y++

SJX           PROC      NEAR
              PUSH      X1
              PUSH      X2
              PUSH      Y1
              PUSH      Y2
              PUSHA
              CALL      XYMAXMIN
              MOV       AX, Y2
              MOV       BX, Y1
              CALL      SUBAB
              MOV       Y2Y1, AX
              MOV       SI, 0
              CMP       SI, AX
              JE        TO_SJXX
SJX_LOP1:     MOV       AX, X2
              MOV       BX, X1
              CALL      SUBAB
              MOV       X2X1, AX
              MOV       SI, 0
              CMP       SI, AX
              JE        TO_SJXY
              MOV       DX, 0
              MOV       AX, Y2Y1
              MOV       CX, X2X1
              DIV       CX
              CMP       AX, 1
              JE        TO_SJXX
              CMP       AX, 0
              JE        TO_SJXX
              JMP       TO_SJXY
TO_SJXX:      MOV       S, 0
              CALL      SJXX
              JMP       SJX_QUIT
TO_SJXY:      MOV       S, 0
              CALL      SJXY
SJX_QUIT:     POPA
              POP       Y2
              POP       Y1
              POP       X2
              POP       X1
              MOV       S, 0
              RET
SJX           ENDP

LINEY         PROC      NEAR
              PUSH      X1
              PUSH      X2
              PUSH      Y1
              PUSH      Y2
              PUSHA
              CALL      XYMAXMIN
              MOV       AX, Y2
              MOV       BX, Y1
              CALL      SUBAB
              MOV       Y2Y1, AX
              MOV       SI, 0
              CMP       SI, AX
              JE        HENG
              JMP       LOP1
HENG:         JMP       HENGXIAN
LOP1:         MOV       AX, X2
              MOV       BX, X1
              CALL      SUBAB
              MOV       X2X1, AX
              MOV       AX, YMIN
              MOV       Y, AX

LINE0Y: SUB   AX, YMIN
        MOV   DX, 0
              MOV       CX, X2X1
              MUL       CX
              MOV       CX, Y2Y1
              DIV       CX
              MOV       DX, 0
              CMP       DL, S
              JE        ZHENGY
              MOV       CX, AX
              MOV       AX, YMINX
              SUB       AX, CX
              JMP       KKY
ZHENGY:       ADD       AX, YMINX
 KKY:         MOV       X, AX

              CALL      DIAN
              INC       Y
              MOV       AX, Y
              CMP       AX, YMAX
              JBE       LINE0Y
              JMP       QUITY
HENGXIAN:     MOV       AX, YMIN
              MOV       Y, AX
              MOV       AX, XMIN
              MOV       X, AX
LOPY:         CALL      DIAN
              INC       X
              MOV       AX, XMAX
              CMP       AX, X
              JAE       LOPY

 QUITY:       MOV       S, 0
              POPA
              POP       Y2
              POP       Y1
              POP       X2
              POP       X1
              RET
LINEY         ENDP






;************LINEX***Y=(Y2-Y1)*(X-X1)/(X2-X1)+Y1
;****IN (X1,Y1),(X2, Y2)******************X++
SJXX          PROC      NEAR
              PUSHA
              PUSH      X1
              PUSH      X2
              PUSH      X3
              PUSH      Y1
              PUSH      Y2
              PUSH      Y3

              CALL      XYMAXMIN
              MOV       AX, XMIN
              MOV       SJX_XMIN, AX
              MOV       AX, YMIN
              MOV       SJX_YMIN, AX
              MOV       AX, XMAX
              MOV       SJX_XMAX, AX
              MOV       AX, YMAX
              MOV       SJX_YMAX, AX
              MOV       AX, XMINY
              MOV       SJX_XMINY, AX


              MOV       AX, Y2
              MOV       BX, Y1
              CALL      SUBAB
              MOV       SJX_Y2Y1, AX
              MOV       AX, X2
              MOV       BX, X1
              CALL      SUBAB
              MOV       DL, S
              MOV       S2, DL
              MOV       S, 0
              MOV       SI, 0
              CMP       SI, AX
              JE        SJX_ZHIXIAN
              JMP       SJX_LOPX
SJX_ZHIXIAN:
              MOV       X1, AX
              MOV       AX, X3
              MOV       X2, AX
              MOV       AX, Y3
              MOV       Y2, AX
              JMP       SJX_ZHIXIANXS
SJX_LOPX:     MOV       SJX_X2X1, AX
              MOV       AX, X3
              MOV       X2, AX
              MOV       AX, Y3
              MOV       Y2, AX
              MOV       AX, SJX_XMIN
              MOV       X1, AX

SJX_LINE0X:   SUB       AX, SJX_XMIN
              MOV       DX, 0                         ;***Y=(Y2-Y1)*(X-X1)/(X2-X1)+Y1
              MOV       CX, SJX_Y2Y1
              MUL       CX
              MOV       CX, SJX_X2X1
              DIV       CX
              MOV       DX, 0
              CMP       DL, S2
              JE        SJX_ZHENGX
              MOV       CX, AX
              MOV       AX, SJX_XMINY
              SUB       AX, CX
              JMP       SJX_KK2
SJX_ZHENGX:
              ADD       AX, SJX_XMINY
SJX_KK2:
              MOV       Y1, AX
              CALL      LINEX
              CALL      LINEY
              INC       X1
              MOV       AX, X1
              CMP       AX, SJX_XMAX
              JBE       SJX_LINE0X
              JMP       SJX_QUIT12
SJX_ZHIXIANXS:
              MOV       AX, SJX_XMIN
              MOV       X1, AX
              MOV       AX, SJX_YMIN
              MOV       Y1, AX
SJX_LOPXX:
              CALL      LINEX
              CALL      LINEY
              INC       Y1
              MOV       AX, SJX_YMAX
              CMP       AX, Y1
              JAE      SJX_LOPXX
SJX_QUIT12:
              MOV       S, 0
              POP       Y3
              POP       Y2
              POP       Y1
              POP       X3
              POP       X2
              POP       X1
              POPA
              RET
SJXX          ENDP



;**************************LINEY      X=(X2-X1)(Y-Y1)/(Y2-Y1)+X1
;*****************Y++


SJXY          PROC      NEAR
              PUSH      X1
              PUSH      X2
              PUSH      X3
              PUSH      Y1
              PUSH      Y2
              PUSH      Y3
              PUSHA
              CALL      XYMAXMIN
              MOV       AX, XMIN
              MOV       SJX_XMIN, AX
              MOV       AX, YMIN
              MOV       SJX_YMIN, AX
              MOV       AX, XMAX
              MOV       SJX_XMAX, AX
              MOV       AX, YMAX
              MOV       SJX_YMAX, AX
              MOV       AX, YMINX
              MOV       SJX_YMINX, AX
              MOV       AX, Y2
              MOV       BX, Y1
              CALL      SUBAB
              MOV       SJX_Y2Y1, AX
              MOV       SI, 0
              CMP       SI, AX
              JE        SJXY_HENG
              JMP       SJXY_LOP1
SJXY_HENG:
              MOV       DL, S
              MOV       S2, DL
              MOV       S, 0
              MOV       AX, X3
              MOV       X2, AX
              MOV       AX, Y3
              MOV       Y2, AX
              JMP       SJXY_HENGXIAN
SJXY_LOP1:    MOV       AX, X2
              MOV       BX, X1            ;X=(X2-X1)(Y-Y1)/(Y2-Y1)+X1
              CALL      SUBAB
              MOV       DL, S
              MOV       S2, DL
              MOV       S, 0
              MOV       SJX_X2X1, AX
              MOV       AX, X3
              MOV       X2, AX
              MOV       AX, Y3
              MOV       Y2, AX
              MOV       AX, SJX_YMIN
              MOV       Y1, AX

SJXY_LINE0Y:  SUB       AX, SJX_YMIN
              MOV       DX, 0
              MOV       CX, SJX_X2X1
              MUL       CX
              MOV       CX, SJX_Y2Y1
              DIV       CX
              MOV       DX, 0
              CMP       DL, S2
              JE        SJXY_ZHENGY
              MOV       CX, AX
              MOV       AX, SJX_YMINX
              SUB       AX, CX
              JMP       SJXY_KKY3
SJXY_ZHENGY:
              ADD       AX, SJX_YMINX
SJXY_KKY3:
              MOV       X1, AX
              CALL      LINEX

              CALL      LINEY
              INC       Y1
              MOV       AX, Y1
              CMP       AX, SJX_YMAX
              JBE       SJXY_LINE0Y
              JMP       SJXY_QUITY
SJXY_HENGXIAN:
              MOV       AX, SJX_YMIN
              MOV       Y1, AX
              MOV       AX, SJX_XMIN
              MOV       X1, AX
SJXY_LOPY:    CALL      LINEY
              CALL      LINEX
              INC       X1
              MOV       AX, SJX_XMAX
              CMP       AX, X1
              JAE       SJXY_LOPY

SJXY_QUITY:   MOV       S, 0
              POPA
              POP       Y3
              POP       Y2
              POP       Y1
              POP       X3
              POP       X2
              POP       X1
              RET
SJXY          ENDP

XYMAXMIN      PROC      NEAR
              PUSHA
              PUSH      X1
              PUSH      X2
              PUSH      Y1
              PUSH      Y2
              MOV       AX, X1
              CMP       AX, X2
              JAE       X1DYX2
              MOV       XMIN, AX    ;X1<X2
              MOV       AX, Y1
              MOV       XMINY, AX
              MOV       AX, X2
              MOV       XMAX, AX
              JMP       YMAXMIN
X1DYX2:       MOV       XMAX, AX
              MOV       AX, X2
              MOV       XMIN, AX
              MOV       AX, Y2
              MOV       XMINY, AX
YMAXMIN:      MOV       AX, Y1
              CMP       AX, Y2
              JAE       Y1DYY2
              MOV       YMIN, AX
              MOV       AX, X1
              MOV       YMINX, AX
              MOV       AX, Y2
              MOV       YMAX, AX
              JMP       XYMAX_QUIT
Y1DYY2:       MOV       YMAX, AX
              MOV       AX, Y2
              MOV       YMIN, AX
              MOV       AX, X2
              MOV       YMINX, AX
XYMAX_QUIT:
              POP       Y2
              POP       Y1
              POP       X2
              POP       X1
              POPA
              RET
XYMAXMIN      ENDP

DIAN          PROC      NEAR
              PUSHA
              MOV       AH, S
              MOV       S3, AH
              MOV       AH, SIGLE
              AND       AH, 80H
              CMP       AH, 0
              JE        PUANDUAN
PAINT:
              MOV       AL, COLOR
              MOV       BH, PAGE1
              MOV       DX, Y
              MOV       CX, X
              MOV       AH, 0CH
              INT       10H
              JMP       DIANQUIT
PUANDUAN:
              CALL      READERDIAN
              MOV       DIANCOLOR, AL
              MOV       AH, SIGLE

              AND       AH, 7FH
              CMP       AH, 0
              JE        NEW0
              CMP       AH, 1
              JE        NEW1
              CMP       AH, 2
              JE        NEW2
              CMP       AH, 3
              JE        NEW3
              CMP       AH, 4
              JE        NEW4
              CMP       AH, 5
              JE        NEW5
              CMP       AH, 6
              JE        NEW6
              JMP       DIANQUIT

NEW0:         CMP       DIANCOLOR, 0
              JE        TOPAINT
              JMP       DIANQUIT
NEW1:         CMP       DIANCOLOR, 0
              JE        TOPAINT
              MOV       AH, COLOR_HOUR
              CMP       DIANCOLOR, AH
              JE        TOPAINT
              JMP       DIANQUIT
TOPAINT:      JMP       PAINT

NEW2:         MOV       AH, COLOR_MIN
              CMP       DIANCOLOR, AH
              JE        TOPAINT
              JMP       DIANQUIT
NEW3:         JMP       NEW0
NEW4:         JMP       NEW0
NEW5:         MOV       AH, COLOR_HOUR
              CMP       DIANCOLOR, AH
              JE        TOPAINT
              JMP       DIANQUIT
NEW6:         CMP       DIANCOLOR, 0
              JE        TOPAINT
              JMP       DIANQUIT
              MOV       AX, X
              MOV       BX, X0
              CALL      SUBAB
              CMP       AX, 5
              JA        TOPAINT
              MOV       AX, Y
              MOV       BX, Y0
              CALL      SUBAB
              CMP       AX, 5
              JA        TOPAINT


DIANQUIT:     MOV       AH, S3
              MOV       S, AH
              POPA
              RET
DIAN          ENDP

YUANXIN       PROC
              MOV       AL, COLOR_SECOND
              ADD       AL, 1
              MOV       BH, PAGE1
              MOV       DX, Y0
              MOV       CX, X0
              MOV       AH, 0CH
              INT       10H
              DEC       DX
              MOV       AH, 0CH
              INT       10H
              DEC       CX
              MOV       AH, 0CH
              INT       10H
              INC       DX
              MOV       AH, 0CH
              INT       10H
              INC       DX
              MOV       AH, 0CH
              INT       10H
              INC       CX
              MOV       AH, 0CH
              INT       10H
              INC       CX
              MOV       AH, 0CH
              INT       10H
              SUB       DX, 1
              MOV       AH, 0CH
              INT       10H
              DEC       DX
              MOV       AH, 0CH
              INT       10H

              RET
YUANXIN       ENDP

READERDIAN    PROC
              MOV       BH, PAGE1
              MOV       DX, Y
              MOV       CX,X        ;
              MOV       AH, 0DH
              INT       10H
              RET
READERDIAN    ENDP


B1002         PROC      NEAR        ;
              MOV       BH, 0
              MOV       AH, 02H
              INT       10H
              RET
B1002         ENDP


CLEAR         PROC
              MOV       DX, 0410H
              CALL      B1002
              MOV       CX, 6000
              MOV       BH, PAGE1
              MOV       AL, ' '
              MOV       AH, 0AH
              INT       10H
              RET
CLEAR         ENDP


;***********************************
SKIN2         PROC
              PUSHA
              MOV       AL, COLOR6
              MOV       COLOR, AL

              MOV       CX, 12
              MOV       AX, 0
SKIN2_KK1:    PUSH      CX

              PUSH      AX
              MOV       BX, R0
              MOV       CX, Y0
              MOV       DX, X0

              CALL      ENOVATE
              MOV       AX, X
              MOV       X1, AX
              MOV       AX, Y
              MOV       Y1, AX
              POP       AX
              PUSH      AX

              MOV       BX, R0
              ADD       BX, 10
              MOV       CX, Y0
              MOV       DX, X0

              CALL      ENOVATE
              MOV       AX, X
              MOV       X2, AX
              MOV       AX, Y
              MOV       Y2, AX
              CALL      LINEX
              CALL      LINEY
              POP       AX
              ADD       AX, 30

              POP       CX
              LOOP      SKIN2_KK1
              MOV       CX, 4
              MOV       AX, 0
SKIN2_KK2:    PUSH      CX

              PUSH      AX
              MOV       BX, R0
              MOV       CX, Y0
              MOV       DX, X0

              CALL      ENOVATE
              MOV       AX, X
              MOV       X1, AX
              MOV       AX, Y
              MOV       Y1, AX
              POP       AX
              PUSH      AX

              MOV       BX, R0
              ADD       BX, 20
              MOV       CX, Y0
              MOV       DX, X0

              CALL      ENOVATE
              MOV       AX, X
              MOV       X2, AX
              MOV       AX, Y
              MOV       Y2, AX
              CALL      LINEX
              CALL      LINEY
              POP       AX
              ADD       AX, 90

              POP       CX
              LOOP      SKIN2_KK2

              POPA
              RET
SKIN2         ENDP



;**********************************

SKIN3         PROC
              PUSHA
              MOV       AL, COLOR5
              MOV       COLOR, AL
              MOV       CX, 60
              MOV       AX, 0
SKIN2_KK3:    PUSH      CX

              PUSH      AX
              MOV       BX, R0
              MOV       CX, Y0
              MOV       DX, X0

              CALL      ENOVATE
              MOV       AX, X
              MOV       X1, AX
              MOV       AX, Y
              MOV       Y1, AX
              POP       AX
              PUSH      AX

              MOV       BX, R0
              ADD       BX, 3
              MOV       CX, Y0
              MOV       DX, X0

              CALL      ENOVATE
              MOV       AX, X
              MOV       X2, AX
              MOV       AX, Y
              MOV       Y2, AX
              CALL      LINEX
              CALL      LINEY
              POP       AX
              ADD       AX, 6

              POP       CX
              LOOP      SKIN2_KK3
              POPA
              RET
SKIN3         ENDP



;**************************************
SKIN          PROC      NEAR
              MOV       AL, COLOR4
              MOV       COLOR, AL
              MOV       BX, R0
              CALL      YUAN
              MOV       BX, R0
              MOV       DH, 7
              MOV       DL, 39
              CALL      B1002
              MOV       DL, '1'
              MOV       AH, 2
              INT       21H
              MOV       DH, 7
              MOV       DL, 40
              CALL      B1002
              MOV       DL, '2'
              MOV       AH, 2
              INT       21H


              MOV       DH, 8
              MOV       DL, 47
              CALL      B1002
              MOV       DL, '1'
              MOV       AH, 2
              INT       21H

              MOV       DH, 11
              MOV       DL, 53
              CALL      B1002
              MOV       DL, '2'
              MOV       AH, 2
              INT       21H

              MOV       DH, 19
              MOV       DL, 53
              CALL      B1002
              MOV       DL, '4'
              MOV       AH, 2
              INT       21H

              MOV       DH, 22
              MOV       DL, 47
              CALL      B1002
              MOV       DL, '5'
              MOV       AH, 2
              INT       21H

              MOV       DH, 22
              MOV       DL, 32
              CALL      B1002
              MOV       DL, '7'
              MOV       AH, 2
              INT       21H

              MOV       DH, 19
              MOV       DL, 26
              CALL      B1002
              MOV       DL, '8'
              MOV       AH, 2
              INT       21H

              MOV       DH, 11
              MOV       DL, 25
              CALL      B1002
              MOV       DL, '1'
              MOV       AH, 2
              INT       21H
              MOV       DH, 11
              MOV       DL, 26
              CALL      B1002
              MOV       DL, '0'
              MOV       AH, 2
              INT       21H

              MOV       DH, 8
              MOV       DL, 30
              CALL      B1002
              MOV       DL, '1'
              MOV       AH, 2
              INT       21H
              MOV       DH, 8
              MOV       DL, 31
              CALL      B1002
              MOV       DL, '1'
              MOV       AH, 2
              INT       21H

              MOV       DH, 15
              MOV       DL, 55
              CALL      B1002
              MOV       DL, '3'
              MOV       AH, 2
              INT       21H
              MOV       DH, 23
              MOV       DL, 40
              CALL      B1002
              MOV       DL, '6'
              MOV       AH, 2
              INT       21H
              MOV       DH, 15
              MOV       DL, 24
              CALL      B1002
              MOV       DL, '9'
              MOV       AH, 2
              INT       21H
              RET

SKIN          ENDP

MSG           PROC      NEAR
              PUSH      ES
              PUSH      DS
              POP       ES
              MOV       CX, 15
              MOV       AL, 0
              MOV       BX, 2
              MOV       AH, 13H
              INT       10H
              POP       ES
              RET
MSG           ENDP


MSGRED        PROC      NEAR
              PUSH      ES
              PUSH      DS
              POP       ES
              MOV       CX, 15
              MOV       AL, 0
              MOV       BX, 4
              MOV       AH, 13H
              INT       10H
              POP       ES
              RET
MSGRED        ENDP

MSGYELLOW     PROC      NEAR
              PUSH      ES
              PUSH      DS
              POP       ES
              MOV       CX, 29
              MOV       AL, 0
              MOV       BX, 14
              MOV       AH, 13H
              INT       10H
              POP       ES
              RET
MSGYELLOW     ENDP


;R0=BX    ********************************
YUAN          PROC
              PUSHA
              MOV       CX, 360
              MOV       AX, 0
YUAN_KK1:     PUSH      CX
              PUSH      AX
              MOV       CX, Y0
              MOV       DX, X0
              CALL      ENOVATE
              CALL      DIAN
              POP       AX
              ADD       AX, 1
              POP       CX
              LOOP      YUAN_KK1

              POPA
              RET
YUAN          ENDP

;*****************IN AX    OUT  X, Y************
ENOVATE       PROC      NEAR
              PUSHA
              PUSH      DX
              PUSH      AX
              PUSH      CX
              CALL      SIN
              MOV       DX, 0
              MOV       CX, BX
              DIV       CX
              POP       CX
              CMP       SI, 1
              JE        IAN

              ADD       AX, CX
              JMP       ENOVATE_KK1
IAN:          SUB       CX, AX
              MOV       AX, CX
ENOVATE_KK1:  MOV       Y, AX
              POP       AX
              CALL      COS
              MOV       DX, 0
              MOV       CX, BX
              DIV       CX
              POP       DX
              CMP       SI, 1
              JE        IAN2
              ADD       AX, DX
              JMP       ENOVATE_KK2
IAN2:         MOV       CX, DX
              SUB       CX, AX
              MOV       AX, CX
ENOVATE_KK2:  MOV       X, AX
              POPA
              RET
ENOVATE       ENDP


; Procedures below added by Nabeel

CONV          PROC
              MOV       AH, 0
              MOV       TEMP1, 10
              DIV       TEMP1

              ADD       AL, 30H
              MOV       TEMP2, AL
              CALL      DSPLAY1

              ADD       AH, 30H
              MOV       TEMP2, AH
              CALL      DSPLAY1

              RET
CONV          ENDP

DSPLAY1       PROC
              PUSH      AX
              PUSH      DX
              MOV       DL, TEMP2
              MOV       AH, 2
              INT       21H
              POP       DX
              POP       AX
              RET
DSPLAY1       ENDP


SHOWDAY       PROC
              PUSH      DX
              PUSH      AX
              PUSH      CX
              MOV       AH, 2
              MOV       BH, 0
              MOV       DH, 2
              MOV       DL, 50
              INT       10H

              MOV       DX, OFFSET DAY1
              MOV       AX, DOW
              MOV       CL, 0AH
              MUL       CL
              MOV       AH, 00H
              ADD       AX, DX
              MOV       DX, AX

              MOV       AH, 09H
              INT       21H

              POP       CX
              POP       AX
              POP       DX
              RET
SHOWDAY       ENDP


MAIN          ENDP
;------------------------------------------------------
CODE_SEG      ENDS
;******************************************************
              END       MAIN





