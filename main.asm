;***************************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores
; LAB 1
; Autor: Diego Cardona
; Proyecto: LAB 1
; Hardware: ATMEGA328P
; Creado: 31/01/2024
; Última modificación: 06/02/2024
;***************************************************************************************

;****************************************************************
; ENCABEZADO
;****************************************************************

.include "M328PDEF.inc"

;SE DEFINEN A LOS CONTADORES
.def COUNT1=R18 
.def COUNT2=R19

; DEFINICIÓN DE CONTADOR PARA PUERTO D
.def COUNTD=R20


.cseg
.org 0x00

;****************************************************************
; STACK POINTER
;****************************************************************

LDI R16, LOW (RAMEND) 
OUT SPL, R16
LDI R17, HIGH (RAMEND) 
OUT SPH, R17


; ///////////////////////////////////////////////////////
; Configuracion
; ///////////////////////////////////////////////////////

Setup:

; CONFIGURACIÓN DE PRESCALER

LDI R16, 0b1000_0000
STS CLKPR, R16
CALL delay

; PRESCALER DE 8 
LDI R16, 0b0000_0011 
STS CLKPR, R16

;SE PONE A TODO D COMO SALIDAS
LDI R16, 0xFF
OUT DDRD, R16 

 ; SE APAGAN TODAS LAS SALIDAS
LDI R16, 0x00
OUT PORTD, R16

; SE PONE A TODO B (MENOS A PB5) COMO ENTRADA
LDI R16, 0b0010_0000
OUT DDRB, R16 

;SE HABILITA PULLUPS EN TODO B (MENOS A PB5)
LDI R16, 0x1F
OUT PORTB, R16 

;SE PONE A C0-C5 COMO SALIDA
LDI R16, 0b0011_1111
OUT DDRC, R16 

;SE APAGAN LAS MISMAS
LDI R16, 0x00
OUT PORTC, R16 

; EL MISMO ASEGURA QUE AMBOS CONTADORES ESTÉN EN 0
LDI COUNT1, 0x00 
LDI COUNT2, 0x00


; ///////////////////////////////////////////////////////
; Loop principal
; ///////////////////////////////////////////////////////


Loop:
;SALIDAS

LDI COUNTD, 0x00 
OR COUNTD, COUNT2 

; UTILIZAMOS LEFT SHIFT PARA DESPLEGAR CONTADOR 1 EN PD4-7
LDI R17, 4 
MOV R16, COUNT1

shift:
LSL R16
DEC R17
BRNE shift

; CARGA EL VALOR DEL SEGUNDO CONTADOR EN LOS 4 BITS ALTOS
OR COUNTD, R16 
OUT PORTD, COUNTD

; Utilizamos PC5 y PC6 para los primeros 2 bits de counter2 porque PD0 y PD1 estan reservados para  el serial
SBRC COUNT2, 0
SBI PORTC, PC4 
SBRS COUNT2, 0
CBI PORTC, PC4

SBRC COUNT2, 1
SBI PORTC, PC5
SBRS COUNT2, 1
CBI PORTC, PC5

// control

SBIS PINB, PB0 ;Saltamos a increment si PB0 esta en 0 (recordar pullup)
CALL INCREMENTCOUNT1

SBIS PINB, PB1 ;Saltamos a decrement si PB1 esta en 0 (recordar pullup)
CALL DECREMENTCOUNT1

SBIS PINB, PB2 ;Saltamos a increment2
CALL INCREMENTCOUNT2

SBIS PINB, PB3 ;Saltamos a decrement2
CALL DECREMENTCOUNT2

RJMP Loop


; ///////////////////////////////////////////////////////
; MÓDULO DE CONTADORES
; ///////////////////////////////////////////////////////

; MÓDULO PARA INCREMENTAR EN EL CONTADOR 1
INCREMENTCOUNT1: 
CALL delay2


	SBIS PINB, PB0 
	RJMP INCREMENTCOUNT1

	; NO AUMENTA MAS DE LOS 4 BITS
	INC COUNT1
	SBRC COUNT1, 4 
	LDI COUNT1, 0x0F

	RET

; MÓDULO PARA INCREMENTAR EN EL CONTADOR 2
INCREMENTCOUNT2: 
CALL delay


	SBIS PINB, PB2
	RJMP INCREMENTCOUNT2

; NO AUMENTA MAS DE LOS 4 BITS
	INC COUNT2 
	SBRC COUNT2, 4 
	LDI COUNT2, 0x0F

	RET

; MÓDULO PARA DECREMENTAR EN EL CONTADOR 1
DECREMENTCOUNT1: 
	CALL delay2

	; CONFIRMANDO QUE ESTA EN 0
	SBIS PINB, PB1 
	RJMP DECREMENTCOUNT1

	; NO AUMENTA MAS DE LOS 4 BITS
	DEC COUNT1
	SBRC COUNT1, 7 
	LDI COUNT1, 0x00

	RET

; MÓDULO PARA DECREMENTAR EN EL CONTADOR 2
DECREMENTCOUNT2: 
	CALL delay

	; CONFIRMANDO QUE ESTA EN 0
	SBIS PINB, PB3
	RJMP DECREMENTCOUNT2

	; NO AUMENTA MAS DE LOS 4 BITS
	DEC COUNT2
	SBRC COUNT2, 7
	LDI COUNT2, 0x00

	RET



; ///////////////////////////////////////////////////////
; MÓDULOS "DELAY"
; ///////////////////////////////////////////////////////

; MÓDULO DE DELAYS DE 1250 TICKS
delay:
;LOOP EXTERNO
LDI R17, 5 
delayOUT:
;LOOP INTERNO
LDI R16, 250 
delayIN:
	DEC R16
	BRNE delayIN

	DEC R17
	BRNE delayOUT

RET

; MÓDULO DE DELAYS DE 1250 TICKS
delay2:
;LOOP EXTERNO
LDI R17, 15 ; loop externo
delayOUT2:
;LOOP INTERNO
LDI R16, 250 ; loop interno
delayIN2:
	DEC R16
	BRNE delayIN2

	DEC R17
	BRNE delayOUT2

RET