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
 
 Main
    BSF STATUS, RP0	;BANCO 1
    CLRF TRISB		;Puerto B como salida
    MOVLW b'00000010'	;RC1 para ECHO, RC0 para TRIG
    MOVWF TRISC		;Puerto C 
    BSF STATUS, RP1	;BANCO 3
    CLRF ANSEL		;Todo digital
    CLRF ANSELH
    BCF STATUS, RP1	;BANCO 1
    MOVLW b'10000010'	
    MOVWF OPTION_REG	;Configuración option_reg
    MOVLW b'10100000'
    MOVWF INTCON		;Configuración INTCON
    BCF STATUS, RP0	;BANCO 0
    CLRF PORTB
    MOVLW .152		
    MOVWF periodo		;Seteo de valor PERIODO
    MOVWF TMR0
    MOVLW .58
    MOVWF DIVISOR              ; Guardamos el número 58 (divisor constante)
    MOVLW b'00000000'  ; T1CON: prescaler 1:1, Timer1 ON=0
    MOVWF T1CON
 
 Loop
    CALL RutinaMedicion
    CALL CalculoDistancia
    CALL CalculoFrecuencia
    GOTO Loop

 CalculoFrecuencia:
	MOVF DIST_CM, W
	BTFSC STATUS, Z
	GOTO SinEcho             ; Si DIST_CM = 0 ? sin eco o fuera de rango

;-------------------------------------------
; Comparaciones por rango (de mayor a menor)
;-------------------------------------------
	MOVLW .152
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_C4

	MOVLW .142
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_D4

	MOVLW .132
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_E4

	MOVLW .122
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_F4

	MOVLW .112
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_G4

	MOVLW .102
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_A4

	MOVLW .92
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_B4

	MOVLW .82
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_C5

	MOVLW .72
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_D5

	MOVLW .62
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_E5

	MOVLW .52
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_F5

	MOVLW .42
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_G5

	MOVLW .32
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_A5

	MOVLW .22
	SUBWF DIST_CM, W
	BTFSC STATUS, C
	GOTO NOTA_B5

	; Si está entre 2 y 12 cm ? nota más aguda (C6)
	GOTO NOTA_C6
    
;===========================================================
; Bloques de notas: cada uno carga el valor de periodo (TMR0)
;===========================================================
    
    NOTA_C4:
	MOVLW .17
	MOVWF periodo
	GOTO FinFrecuencia
    
    NOTA_D4:
	MOVLW .43
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_E4:
	MOVLW .66
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_F4:
	MOVLW .77
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_G4:
	MOVLW .97
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_A4:
	MOVLW .114
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_B4:
	MOVLW .129
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_C5:
	MOVLW .137
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_D5:
	MOVLW .150
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_E5:
	MOVLW .161
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_F5:
	MOVLW .167
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_G5:
	MOVLW .176
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_A5:
	MOVLW .185
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_B5:
	MOVLW .193
	MOVWF periodo
	GOTO FinFrecuencia

    NOTA_C6:
	MOVLW .196
	MOVWF periodo
	GOTO FinFrecuencia
    SinEcho:
	CLRF periodo
    
    FinFrecuencia:
	Return
    
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
       BSF PORTC, 0
       CALL Delay_10us
       BCF PORTC, 0
    EsperaSubida:
       BTFSS PORTC, 1	    ; ECHO esta en alto?
       GOTO EsperaSubida
    InicioTimer:
       CLRF TMR1H
       CLRF TMR1L
       BSF  T1CON, TMR1ON  ; Arranca el conteo
   ; === ESPERA DEL FLANCO DE BAJADA DEL ECHO ===
       ; El TimerH se paso de 98?
    VerificarTimeout:
       MOVF TMR1H, 0
       SUBLW .98
       BTFSS STATUS, C	;C=1 si TMR1H<=98
       GOTO Timeout	;C=0 si TMR1H>98
    EsperaBajada:
       BTFSC PORTC, 1  ; Espera mientras siga en alto
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
	XORLW 0xFF
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