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
pausa_play EQU 0x34
contador1 EQU 0x35
contador2 EQU 0x36
interrupcionTMR2 EQU 0x37
 
 Main
    ;=======================================
    ;	    CONFIGURACIÓN DE REGISTROS
    ;=======================================
    BSF STATUS, RP0		;BANCO 1
    CLRF TRISD			;Puerto D como salida
    MOVLW .1			;Puerto B como salida
    MOVWF TRISB
    MOVLW b'10001010'		;RC1 para ECHO, RC0 para TRIG
    MOVWF TRISC			;Puerto C
    BSF STATUS, RP1		;BANCO 3
    CLRF ANSEL			;Todo digital
    CLRF ANSELH	
    BCF STATUS, RP1		;BANCO 1
    MOVLW b'00000010'	
    MOVWF OPTION_REG		;Configuración option_reg
    MOVLW b'11110000'
    MOVWF INTCON		;Configuración INTCON
    BSF WPUB, 0
    MOVLW b'00000010'
    MOVWF PIE1
    ;--- Configurar UART 9600 bps ---
    BANKSEL SPBRG 
    MOVLW .25           ; 9600 baud @ 4MHz (BRGH=1)
    MOVWF SPBRG

    BANKSEL TXSTA
    BSF TXSTA, TXEN     ; Habilita TX
    BCF TXSTA, SYNC     ; Modo asíncrono
    BSF TXSTA, BRGH     ; Alta velocidad
    
    BANKSEL RCSTA
    BSF RCSTA, SPEN     ; Habilita TX (y RX si se quisiera)
 
    BANKSEL BAUDCTL
    BCF BAUDCTL, BRG16  ; Baudrate de 8 bits
    
    BCF STATUS, RP1
    BCF STATUS, RP0		;BANCO 0
    CLRF PORTD
    ;Config TMR2
    BSF STATUS, RP0		;BANCO 0
    MOVLW   .249
    MOVWF   PR2             ; 10 ms exactos
    BCF STATUS, RP0
    CLRF PIR1
    MOVLW b'01111111'
    MOVWF T2CON
    CLRF    TMR2
    
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
    CLRF pausa_play
    CLRF interrupcionTMR2
    
 Loop
    CALL RutinaMedicion
    CALL Delay_60ms
    CALL CalculoDistancia
    CALL CalculoFrecuencia
    GOTO Loop

    ;===========================
    ; Delay de 60 ms
    ;===========================
    Delay_60ms:
	MOVLW   .150        ; bucle externo ? 100 repeticiones
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
    
    ;===========================================================
    ; Rutina de calculo de frecuencia
    ;===========================================================

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
    ; CARGA DE PERIODOS
    ;===========================================================

    NOTA_C4:
	MOVLW .19
	GOTO SetPer

    NOTA_Cs4:
	MOVLW .33
	GOTO SetPer

    NOTA_D4:
	MOVLW .45
	GOTO SetPer

    NOTA_Ds4:
	MOVLW .57
	GOTO SetPer

    NOTA_E4:
	MOVLW .68
	GOTO SetPer

    NOTA_F4:
	MOVLW .79
	GOTO SetPer

    NOTA_Fs4:
	MOVLW .89
	GOTO SetPer

    NOTA_G4:
	MOVLW .99
	GOTO SetPer

    NOTA_Gs4:
	MOVLW .108
	GOTO SetPer

    NOTA_A4:
	MOVLW .116
	GOTO SetPer

    NOTA_As4:
	MOVLW .124
	GOTO SetPer

    NOTA_B4:
	MOVLW .131
	GOTO SetPer

    NOTA_C5:
	MOVLW .139
	GOTO SetPer

    NOTA_Cs5:
	MOVLW .145
	GOTO SetPer

    NOTA_D5:
	MOVLW .152
	GOTO SetPer

    NOTA_Ds5:
	MOVLW .158
	GOTO SetPer

    NOTA_E5:
	MOVLW .163
	GOTO SetPer

    NOTA_F5:
	MOVLW .169
	GOTO SetPer

    NOTA_Fs5:
	MOVLW .174
	GOTO SetPer

    NOTA_G5:
	MOVLW .178
	GOTO SetPer

    NOTA_Gs5:
	MOVLW .183
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
    
    ;===========================================================
    ; Rutina de calculo de distancia
    ;===========================================================

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
    CLRF resultado		;inicializar resultado
    
    DivisionLoop:
    ;-----------------------------------------------
    ; Restar de a 58 del valor de 16 bits (TMP1:TMP0)
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

	; Si la resta fue válida incrementar resultado
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
    
    ;===========================================================
    ; Rutina de medicion del sensor HCSR04
    ;===========================================================
	
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
    
    ;===========================================================
    ; Delay de 10us para el trigger del sensor
    ;===========================================================
       
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
    ;  ENVIAR DISTANCIA POR UART 
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
	MOVLW .13     ; CR
	CALL UART_Send
	MOVLW .10     ; LF
	CALL UART_Send

	RETURN
    
    UART_Send:               ; Enviar lo que esté en W
	BTFSS PIR1, TXIF    
	GOTO $-1
	MOVWF TXREG
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

    ;-------------------------------------
    ; Delay de 20 ms para antirebote
    ; Usa: contador1, contador2
    ;-------------------------------------

    Delay20ms:
	MOVLW   .100        ; 100 loops externos
	MOVWF   contador1

    Loop1
	MOVLW   .200        ; 200 loops internos
	MOVWF   contador2

    Loop2
	DECFSZ  contador2, f
	GOTO    Loop2

	DECFSZ  contador1, f
	GOTO    Loop1

	RETURN
	
    ;===========================================================
    ; Rutina de interrupción
    ;===========================================================
    
ISR:
    Guardado_contexto:
	MOVWF W_TEMP
	SWAPF STATUS, W
	MOVWF STATUS_TEMP
    
    ChequeoBandera:
	BTFSC INTCON, T0IF
	GOTO ONDA_CUADRADA
	BTFSC INTCON, INTF
	GOTO rutinapausa
	BTFSC PIR1, TMR2IF
	GOTO rutinaUART
	GOTO SalidaISR
    
    ONDA_CUADRADA:
	BCF INTCON, T0IF
	BTFSS pausa_play, 0
	GOTO SalidaISR
	MOVF periodo, W
	BTFSC STATUS, Z
	GOTO SalidaISR
	MOVWF TMR0
	MOVLW .1
	XORWF PORTD, F
	GOTO SalidaISR
    
    rutinapausa:
	BCF INTCON, INTF
	CALL Delay20ms
	MOVLW .1
	XORWF pausa_play, F
	GOTO SalidaISR

    rutinaUART:
	BCF PIR1, TMR2IF
	INCF interrupcionTMR2, F
	MOVF interrupcionTMR2, W
	SUBLW .10
	BTFSS STATUS, Z
	GOTO SalidaISR
	CLRF interrupcionTMR2
	CALL EnviarDistancia
	GOTO SalidaISR
	
    SalidaISR:
	SWAPF STATUS_TEMP, W
	MOVWF STATUS
	SWAPF W_TEMP, F
	SWAPF W_TEMP, W
	RETFIE
 
END