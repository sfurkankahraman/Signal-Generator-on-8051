ORG 000h
LJMP MAIN
ORG 000Bh
LJMP TIMER0INT
ORG 001Bh
LJMP TIMER1INT

ORG 50H
MAIN:
ACALL CONFIGURE_LCD

MOV A,#66H
ACALL SEND_DATA
MOV A,#3DH 
ACALL SEND_DATA

ACALL KEYBOARD
ACALL SEND_DATA
ANL A,#0FH
MOV 40H,A

ACALL KEYBOARD
ACALL SEND_DATA
ANL A,#0FH
MOV 41H,A

ACALL KEYBOARD
ACALL SEND_DATA
ANL A,#0FH
MOV 42H,A		;40H,41H,42H HOLDS FREQUENCY VALUES

MOV A,#48H
ACALL SEND_DATA
MOV A,#7AH
ACALL SEND_DATA

MOV A,#0C0H
ACALL SEND_COMMAND

MOV A,#44H
ACALL SEND_DATA
MOV A,#3DH
ACALL SEND_DATA

ACALL KEYBOARD
ACALL SEND_DATA
ANL A,#0FH
MOV 60H,A

ACALL KEYBOARD
ACALL SEND_DATA
ANL A,#0FH
MOV 61H,A		;60H,61H HOLDS DUTY CYCLE

MOV A,#25H
ACALL SEND_DATA

MOV TMOD,#11H		;SELECT MODE 1 FOR BOTH TIMER 1&0
MOV IE,#8AH		;ENABLE ALL INTERRUPT AND TIMER INTERRUPTS

FREQUENCY:
MOV A,40H
MOV B,#100D
MUL AB
MOV 40H,A
MOV A,41H
MOV B,#10D
MUL AB
ADD A,40H
ADD A,42H
MOV R5,A
MOV 40H,R5		;R5 AND 40H HOLDS THE FREQUENCY VALUE GIVEN
CLR A

MOV A,40H
CJNE A,#85D,$+3		;IF FREQUENCY MORE THAN 85 SECOND WAVEFORM FREQUENCY FIXES TO 255
JC HERE1
MOV 50H,#255D
SJMP DUTY_CYCLE_ONES

HERE1:			;IF F<85 THAN MULTIPLY 3 AND INSERT TO SECOND WAVEFORM
MOV A,40H
MOV B,#3D
MUL AB
MOV 50H,A		;50H HOLDS SECOND FREQ

DUTY_CYCLE_ONES:
MOV A,60H
MOV B,#10D
MUL AB
ADD A,61H
MOV R6,A
MOV 70H,R6		;R6 AND 70H ONE WAVE PERCENTAGE
CLR A

DUTY_CYCLE_ZEROS:
MOV A,#64H
SUBB A,R6
MOV R7,A
MOV 71H,R7    		;R7 AND 71H ZERO WAVE PERCENTAGE
CLR A

MOV 72H,R6
MOV 73H,R7		;72H AND 73H ARE SPARE FOR DUTY CYCLES

DUTY_CYCLE_ONE2:
MOV A,70H
MOV B,#02H
DIV AB
MOV 78H,A		;HALF OF THE FIRST DUTY CYCLE

DUTY_CYCLE_ZERO2:
MOV A,#64H
SUBB A,78H
MOV 79H,A		;COMPLEMENT OF SECOND DUTY CYCLE
CLR A

MOV 7AH,78H
MOV 7BH,79H

FREQ_PERIOD1:		;MOVE 2810F TO R3 AND R4
MOV R3,#28H		;THEN SUBTRACT FREQUENCY THEN FIND THE TIMER PERIOD
MOV R4,#10H
KKADAYOLMA1:
MOV A,R4
SUBB A,40H
MOV R4,A
MOV A,R3
SUBB A,#00H
MOV R3,A
PUSH ACC
MOV A,R2
ADD A,#01H
MOV R2,A
MOV A,R1
ADDC A,#00H
MOV R1,A
POP ACC
JZ FREQ_PERIOD2
SJMP KKADAYOLMA1

FREQ_PERIOD2:		;DO SAME THING HERE TO FIND SECOND TIME PERIOD
MOV 60H,R1
MOV 61H,R2
MOV R2,#00H
MOV R1,#00H		;CLR R1 AND R2 TO GET ACCURATE VALUE

MOV R3,#28H
MOV R4,#10H
KKADAYOLMA2:		;20H-21H HOLDS SECOND FREQ
MOV A,R4		;R1-R2 HOLDS THE VALUE OF TIME PERIOD
SUBB A,50H
MOV R4,A
MOV A,R3
SUBB A,#00H
MOV R3,A
PUSH ACC
MOV A,R2
ADD A,#01H
MOV R2,A
MOV A,R1
ADDC A,#00H
MOV R1,A
POP ACC
JZ NEXT
SJMP KKADAYOLMA2

NEXT:
MOV 68H,R1
MOV 69H,R2		;43H AND 44H HOLD THE VALUE OF TIME PERIOD

LOADTIMER0:
MOV R3,#0FFH
MOV A,R3
SUBB A,61H
MOV R4,A
MOV A,R3
SUBB A,60H
MOV R3,A
MOV TH1,R3
MOV TL1,R4
MOV 3AH,R3
MOV 3BH,R4		;FF FFH - R1 R2H AND LOAD TIMER

LOADTIMER1:
MOV R3,#0FFH
MOV A,R3
SUBB A,69H
MOV R4,A
MOV A,R3
SUBB A,68H
MOV R3,A
MOV TH0,R3
MOV TL0,R4
MOV 30H,R3
MOV 31H,R4		;FF FFH - R1 R2H AND LOAD TIMER

MOV 3EH,#20D
MOV 3FH,#20D
MOV 3CH,70H
MOV 3DH,71H

SETB TR1
SETB TR0		;START TIMERS

SJMP $			;WAIT FOR INTERRUPTS

ORG 200h

TIMER0INT:
CLR TR0
MOV TH0,3AH
MOV TL0,3BH
SETB TR0
MOV A,72H
JNZ SENDONE0
CLR P2.6
MOV A,73H
JNZ SENDZERO0
MOV 72H,70H
MOV 73H,71H
SETB TR0
SJMP LED		;GET INTO LOOP DUE TO DC

SENDONE0:
DEC 72H
SETB P2.6
SJMP LED

SENDZERO0:
DEC 73H
CLR P2.6

LED:			;LED BLINK DUE TO DC AGAIN
MOV A,3CH
JNZ SENDLED1
MOV A,3EH
JNZ HERE2
MOV A,3DH
JNZ SENDLED0
MOV A,3FH
JNZ HERE3
MOV 3CH,70H
MOV 3DH,71H
MOV 3EH,#20D
MOV 3FH,#20D

HERE3:
DEC 3FH
MOV 3DH,71H
RETI

HERE2:
DEC 3EH
MOV 3CH,70H
RETI

SENDLED1:
DEC 3CH
SETB P2.5
RETI

SENDLED0:
DEC 3DH
CLR P2.5
RETI

TIMER1INT:
CLR TR1			;GET INTO LOOP DUE TO DC
MOV TH1,30H
MOV TL1,31H
SETB TR1
MOV A,7AH
JNZ SENDONE1
CLR P2.7
MOV A,7BH
JNZ SENDZERO1
MOV 7AH,78H
MOV 7BH,79H
SETB TR1
RETI

SENDONE1:
DEC 7AH
SETB P2.7
RETI

SENDZERO1:
DEC 7BH
CLR P2.7
RETI

CONFIGURE_LCD:
mov a,#38H
acall SEND_COMMAND
mov a,#0FH
acall SEND_COMMAND
mov a,#06H
acall SEND_COMMAND
mov a,#01H
acall SEND_COMMAND
mov a,#80H
acall SEND_COMMAND
ret

SEND_COMMAND:
mov p1,a
clr p3.5
clr p3.6
setb p3.7
acall DELAY
clr p3.7
ret

SEND_DATA:
mov p1,a
setb p3.5
clr p3.6
setb p3.7
acall DELAY
clr p3.7
ret

DELAY:
push 0
push 1
mov r0,#50

DELAY_OUTER_LOOP:
mov r1,#255
djnz r1,$
djnz r0,DELAY_OUTER_LOOP
pop 1
pop 0
ret

KEYBOARD:
	mov	P0, #0ffh
K1:
	mov	P2, #0
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, K1
K2:
	acall	DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER
	sjmp	K2
KB_OVER:
	acall DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER1
	sjmp	K2
KB_OVER1:
	mov	P2, #11111110B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_0
	mov	P2, #11111101B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_1
	mov	P2, #11111011B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_2
	mov	P2, #11110111B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_3
	ljmp	K2
ROW_0:
	mov	DPTR, #KCODE0
	sjmp	KB_FIND
ROW_1:
	mov	DPTR, #KCODE1
	sjmp	KB_FIND
ROW_2:
	mov	DPTR, #KCODE2
	sjmp	KB_FIND
ROW_3:
	mov	DPTR, #KCODE3
KB_FIND:
	rrc	A
	jnc	KB_MATCH
	inc	DPTR
	sjmp	KB_FIND
KB_MATCH:
	clr	A
	movc	A, @A+DPTR
	ret

KCODE0:	DB	'1', '2', '3', 'A'
KCODE1:	DB	'4', '5', '6', 'B'
KCODE2:	DB	'7', '8', '9', 'C'
KCODE3:	DB	'*', '0', '#', 'D'
END
