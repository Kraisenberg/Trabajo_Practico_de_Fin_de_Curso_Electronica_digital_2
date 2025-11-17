; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0x23E1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;esto va en todos los codigos
 ORG 0x00
 goto Main
 ORG 0x04
 GOTO ISR
 ORG 0x05

periodo EQU 0x20
Tiempo_L EQU 0x21
Tiempo_H EQU 0x22
DIST_CM EQU 0x23
resultado EQU 0x24
TMP0 EQU 0x25	
TMP1 EQU 0x26
DIVISOR EQU 0x27
STATUS_TEMP EQU 0X70
W_TEMP EQU 0X71
DLY_H EQU 0x28
DLY_L EQU 0x29
 NUM EQU 0x30
 DECE EQU 0x31
 UNI EQU 0X32
 CEN EQU 0x33
 
 Main
    ;=======================================
    ;	    CONFIGURACIÓN DE REGISTROS
    ;=======================================
    BSF STATUS, RP0		;BANCO 1
    CLRF TRISB			;Puerto B como salida
    MOVLW b'10001010'		;RC1 para ECHO, RC0 para TRIG
    MOVWF TRISC			;Puerto C 
    BSF STATUS, RP1		;BANCO 3
    CLRF ANSEL			;Todo digital
    CLRF ANSELH	
    BCF STATUS, RP1		;BANCO 1
    MOVLW b'10000010'	
    MOVWF OPTION_REG		;Configuración option_reg
    MOVLW b'10100000'
    MOVWF INTCON		;Configuración INTCON
    MOVLW .25              ; Baudrate a ~9600 con Fosc=4MHz ? SPBRG=25
    MOVWF SPBRG
    MOVLW b'00100110'
    MOVWF TXSTA
    BCF STATUS, RP0		;BANCO 0
    MOVLW b'10010000'      ; RCSTA: SPEN=1 (enable serial), CREN=1
    MOVWF RCSTA
    CLRF PORTB
    MOVLW .17	
    MOVWF periodo		;Seteo de valor PERIODO
    MOVWF TMR0
    MOVLW .58
    MOVWF DIVISOR		; Guardamos el número 58 (divisor constante)
    MOVLW b'00000000'		; T1CON: prescaler 1:1, Timer1 ON=0
    MOVWF T1CON
    CLRF Tiempo_H
    CLRF Tiempo_L
    CLRF PORTC
    CLRF TXREG
    
 Loop
    TestToggle:
;	BSF PORTC, 2
;	CALL Delay_10us
;	BCF PORTC, 2
;	CALL Delay_Ms_200
;	GOTO TestToggle
;    
    CALL RutinaMedicion
    CALL Delay_60ms
    CALL CalculoDistancia
;    CALL EnviarDistancia
    CALL CalculoFrecuencia
    GOTO Loop

    ;===========================
    ; Delay de 60 ms
    ;===========================
    Delay_60ms:
	MOVLW   .100        ; bucle externo ? 100 repeticiones
	MOVWF   DLY_H

    Delay_60ms_H:
	MOVLW   .200        ; bucle interno ? 200 repeticiones
	MOVWF   DLY_L

    Delay_60ms_L:
	DECFSZ  DLY_L, F    ; 1 ciclo (2 cuando termina)
	GOTO    Delay_60ms_L ; 2 ciclos
	DECFSZ  DLY_H, F
	GOTO    Delay_60ms_H
	RETURN

    
    CalculoFrecuencia:
	MOVF DIST_CM, W
	BTFSC STATUS, Z
	GOTO SinEcho

    ;===========================================================
    ; Comparaciones ordenadas de MAYOR a MENOR distancia
    ;===========================================================

	MOVLW .122
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_C4

	MOVLW .117
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Cs4

	MOVLW .112
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_D4

	MOVLW .107
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Ds4

	MOVLW .102
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_E4

	MOVLW .97
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_F4

	MOVLW .92
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Fs4

	MOVLW .87
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_G4

	MOVLW .82
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Gs4

	MOVLW .77
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_A4

	MOVLW .72
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_As4

	MOVLW .67
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_B4

	MOVLW .62
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_C5

	MOVLW .57
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Cs5

	MOVLW .52
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_D5

	MOVLW .47
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Ds5

	MOVLW .42
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_E5

	MOVLW .37
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_F5

	MOVLW .32
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Fs5

	MOVLW .27
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_G5

	MOVLW .22
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_Gs5

	MOVLW .17
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_A5

	MOVLW .12
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_As5

	MOVLW .07
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_B5

	GOTO NOTA_C6

    ;===========================================================
    ; CARGA DE PERIODOS SEGÚN TU TABLA
    ;===========================================================

    ;===========================================================
    ; CARGA DE PERIODOS SEGÚN TU TABLA (FORMATO COMPATIBLE)
    ;===========================================================

    NOTA_C4:
	MOVLW .16
	GOTO SetPer

    NOTA_Cs4:
	MOVLW .31
	GOTO SetPer

    NOTA_D4:
	MOVLW .43
	GOTO SetPer

    NOTA_Ds4:
	MOVLW .55
	GOTO SetPer

    NOTA_E4:
	MOVLW .66
	GOTO SetPer

    NOTA_F4:
	MOVLW .77
	GOTO SetPer

    NOTA_Fs4:
	MOVLW .87
	GOTO SetPer

    NOTA_G4:
	MOVLW .97
	GOTO SetPer

    NOTA_Gs4:
	MOVLW .106
	GOTO SetPer

    NOTA_A4:
	MOVLW .114
	GOTO SetPer

    NOTA_As4:
	MOVLW .122
	GOTO SetPer

    NOTA_B4:
	MOVLW .129
	GOTO SetPer

    NOTA_C5:
	MOVLW .137
	GOTO SetPer

    NOTA_Cs5:
	MOVLW .143
	GOTO SetPer

    NOTA_D5:
	MOVLW .150
	GOTO SetPer

    NOTA_Ds5:
	MOVLW .156
	GOTO SetPer

    NOTA_E5:
	MOVLW .161
	GOTO SetPer

    NOTA_F5:
	MOVLW .167
	GOTO SetPer

    NOTA_Fs5:
	MOVLW .172
	GOTO SetPer

    NOTA_G5:
	MOVLW .176
	GOTO SetPer

    NOTA_Gs5:
	MOVLW .181
	GOTO SetPer

    NOTA_A5:
	MOVLW .187
	GOTO SetPer

    NOTA_As5:
	MOVLW .191
	GOTO SetPer

    NOTA_B5:
	MOVLW .195
	GOTO SetPer

    NOTA_C6:
	MOVLW .198
	GOTO SetPer


    SetPer:
	MOVWF periodo
	GOTO FinFrecuencia


    SinEcho:
	CLRF periodo

    FinFrecuencia:
	RETURN
    
 CalculoDistancia:
    ; Devolvio valor?
    MOVF Tiempo_H, W
    IORWF Tiempo_L, W
    BTFSC STATUS, Z
    GOTO NoEcho_NoRango		; si = 0, no hubo eco (o timeout)
    
    ;Esta dentro del rango? TMRH<8816
    MOVF Tiempo_H, W
    SUBLW .23		
    BTFSS STATUS, C	;C=1 si tiempoH<=23
    GOTO NoEcho_NoRango	;C=0 si tiempoH>23
    
    ; copiar tiempo a variable temporal
    MOVF Tiempo_H, W
    MOVWF TMP1
    MOVF Tiempo_L, W
    MOVWF TMP0
    
    ;aca que hacemos
    
    ; inicializar resultado
    CLRF resultado
    
    DivisionLoop:
    ;-----------------------------------------------
    ; Restar 58 del valor de 16 bits (TMP1:TMP0)
    ;-----------------------------------------------
	MOVF DIVISOR, W
	SUBWF TMP0, F		; TMP0 = TMP0 - 58
	BTFSS STATUS, C		; TMP0 desbordo? Hay borrow?
	DECF TMP1, F		; Si hubo "borrow", restamos 1 al byte alto

	; Si el byte alto quedó negativo (borrow global) => salir
	MOVF TMP1, W
	XORLW 0xFF
	BTFSC STATUS, Z
	GOTO DivisionEnd
	
	; Si llegó exactamente a 0, también salir
	MOVF TMP1, W
	IORWF TMP0, W
	BTFSC STATUS, Z
	GOTO DivisionEnd

	; Si la resta fue válida ? incrementar resultado
	INCF resultado, F
	GOTO DivisionLoop          ; Repetir mientras alcance

    DivisionEnd:
    ;-----------------------------------------------
    ; 5. Guardar el resultado final (en cm)
    ;-----------------------------------------------
	MOVF resultado, W
	MOVWF DIST_CM              ; Guardar distancia final en cm
	RETURN
    
    NoEcho_NoRango:
	CLRF DIST_CM
	RETURN
    
RutinaMedicion:
    Trigger_and_wait:
       BSF PORTC, 2
       CALL Delay_10us
       BCF PORTC, 2
    EsperaSubida:
       BTFSS PORTC, 3	    ; ECHO esta en alto?
       GOTO EsperaSubida
    InicioTimer:
       CLRF TMR1H
       CLRF TMR1L
       BSF  T1CON, TMR1ON  ; Arranca el conteo
   ; === ESPERA DEL FLANCO DE BAJADA DEL ECHO ===
;        El TimerH se paso de 98?
    VerificarTimeout:
       MOVF TMR1H, 0
       SUBLW .98
       BTFSS STATUS, C	;C=1 si TMR1H<=98
       GOTO Timeout	;C=0 si TMR1H>98
    EsperaBajada:
       BTFSC PORTC, 3  ; Espera mientras siga en alto
       GOTO VerificarTimeout
       BCF  T1CON, TMR1ON
       GOTO CapturaValores
    Timeout:
       BCF  T1CON, TMR1ON
       CLRF TMR1L
       CLRF TMR1H
    CapturaValores:
       MOVF TMR1L, W
       MOVWF Tiempo_L
       MOVF TMR1H, W
       MOVWF Tiempo_H
       RETURN
    
 Delay_10us:
    NOP         ; 1 us
    NOP         ; 2 us
    NOP         ; 3 us
    NOP         ; 4 us
    NOP         ; 5 us
    NOP         ; 6 us
    NOP         ; 7 us
    NOP         ; 8 us
    NOP         ; 9 us
    NOP         ; 10 us
    RETURN

    ;===================================================
    ;  ENVIAR DISTANCIA POR UART  -  SUPER SIMPLE
    ;  Formato:  Distancia: XX cm
    ;===================================================

    EnviarDistancia:

	; --- Enviar texto fijo "Distancia: " ---
	MOVLW 'D'      ; Cada MOVLW + CALL es 1 caracter
	CALL UART_Send
	MOVLW 'i'
	CALL UART_Send
	MOVLW 's'
	CALL UART_Send
	MOVLW 't'
	CALL UART_Send
	MOVLW 'a'
	CALL UART_Send
	MOVLW 'n'
	CALL UART_Send
	MOVLW 'c'
	CALL UART_Send
	MOVLW 'i'
	CALL UART_Send
	MOVLW 'a'
	CALL UART_Send
	MOVLW ':'
	CALL UART_Send
	MOVLW ' '
	CALL UART_Send

	; --- Convertir el número DIST_CM y enviarlo ---
	MOVF DIST_CM, W
	CALL EnviarNumero0a255   ; <--- convierte y manda

	; --- Enviar " cm" ---
	MOVLW ' '
	CALL UART_Send
	MOVLW 'c'
	CALL UART_Send
	MOVLW 'm'
	CALL UART_Send

	; --- Salto de línea ---
	MOVLW 13     ; CR
	CALL UART_Send
	MOVLW 10     ; LF
	CALL UART_Send

	RETURN
    
    UART_Send:               ; Enviar lo que esté en W
	BTFSS TXSTA, TRMT    ; Esperar que TXREG esté libre
	GOTO UART_Send

	MOVWF TXREG          ; Mandar el byte
	RETURN
    
    ;========================================================
    ; EnviarNumero0a255: convierte el número en W a texto
    ;========================================================
    ; Usa variables: NUM, CEN, DEC, UNI
    ;========================================================

    EnviarNumero0a255:

	MOVWF NUM        ; Guardar el número
	CLRF CEN
	CLRF DECE
	CLRF UNI

    ; --- Cientos ---
    CientosLoop:
	MOVLW .100
	SUBWF NUM, W
	BTFSS STATUS, C     ; Si NUM < 100 ? salir
	GOTO DecenasStart
	MOVLW .100
	SUBWF NUM, F        ; NUM -= 100
	INCF CEN, F         ; CEN++
	GOTO CientosLoop

    DecenasStart:

    ; --- Decenas ---
    DecenasLoop:
	MOVLW .10
	SUBWF NUM, W
	BTFSS STATUS, C     ; Si NUM < 10 ? salir
	GOTO UnidadesStart
	MOVLW .10
	SUBWF NUM, F        ; NUM -= 10
	INCF DECE, F         ; DEC++
	GOTO DecenasLoop

    UnidadesStart:
	MOVF NUM, W
	MOVWF UNI           ; UNI = lo que queda

    ; --- Enviar cientos si no es cero ---
	MOVF CEN, W
	BTFSC STATUS, Z
	GOTO EnviarDecenas
	ADDLW '0'
	CALL UART_Send

    EnviarDecenas:
	MOVF DECE, W
	; Si CEN=0 y DEC=0 y número < 10 ? no enviar decena
	BTFSC STATUS, Z
	GOTO EnviarUnidades
	ADDLW '0'
	CALL UART_Send

    EnviarUnidades:
	MOVF UNI, W
	ADDLW '0'
	CALL UART_Send

	RETURN
    
	
	
ISR:
    Guardado_contexto:
	MOVWF W_TEMP
	SWAPF STATUS, W
	MOVWF STATUS_TEMP
    
    ChequeoBandera:
	BTFSC INTCON, T0IF
	GOTO ONDA_CUADRADA
	GOTO SalidaISR
    
    ONDA_CUADRADA:
	BCF INTCON, T0IF
	MOVF periodo, W
	BTFSC STATUS, Z
	GOTO SalidaISR
	MOVWF TMR0
	MOVLW .1
	XORWF PORTB, F
	GOTO SalidaISR
    
    SalidaISR:
	SWAPF STATUS_TEMP, W
	MOVWF STATUS
	SWAPF W_TEMP, F
	SWAPF W_TEMP, W
	RETFIE
 
END