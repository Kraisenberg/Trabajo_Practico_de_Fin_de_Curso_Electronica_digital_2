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
STATUS_TEMP EQU 0X70
W_TEMP EQU 0X71

 TablaDeFrecuencias:
    ADDWF PCL, f
    RETLW .17		;C4
    RETLW .43		;D4
    RETLW .66		;E4
    RETLW .77		;F4
    RETLW .97		;G4
    RETLW .114		;A4
    RETLW .129		;B4
    RETLW .137		;C5
    RETLW .150		;D5
    RETLW .161		;E5
    RETLW .167		;F5
    RETLW .176		;G5
    RETLW .185		;A5
    RETLW .193		;B5
    RETLW .196		;C6
 
Main
 BSF STATUS, RP0	;BANCO 1
 CLRF TRISB		;Puerto C como salida
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
 MOVLW .66		
 MOVWF periodo		;Seteo de valor PERIODO
 MOVWF TMR0
 
 Loop
    GOTO Loop
 
; Trigger_and_wait:
;    BSF PORTB, 0
;    CALL Delay_10us
;    BCF PORTB, 0
    
 
; Delay_10us:
;    NOP         ; 1 us
;    NOP         ; 2 us
;    NOP         ; 3 us
;    NOP         ; 4 us
;    NOP         ; 5 us
;    NOP         ; 6 us
;    NOP         ; 7 us
;    NOP         ; 8 us
;    NOP         ; 9 us
;    NOP         ; 10 us
;    RETURN

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