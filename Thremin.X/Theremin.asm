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

unidad EQU 0x20
decena EQU 0x21
centena EQU 0x22
index EQU 0x23
W_TEMP EQU 0x24
STATUS_TEMP EQU 0x25
dato EQU 0x26
cien EQU 0X27
diez EQU 0X28
uno EQU 0X29


contador1 EQU 0x2D
contador2 EQU 0x2E
valorcont1 EQU .20
valorcont2 EQU .249
 
;=====================================
;   TABLAS
;=====================================
 
 TablaNormal
    ADDWF PCL, f
    RETLW b'11111100' ; 0
    RETLW b'01100000' ; 1
    RETLW b'11011010' ; 2
    RETLW b'11110010' ; 3
    RETLW b'01100110' ; 4
    RETLW b'10110110' ; 5
    RETLW b'10111110' ; 6
    RETLW b'11100000' ; 7
    RETLW b'11111110' ; 8
    RETLW b'11110110' ; 9

TablaMulti
    ADDWF PCL, f
    RETLW b'00000001' ; 
    RETLW b'00000010' ; 
    RETLW b'00000100' ; 
 
Main
    BSF STATUS, RP0
    CLRF TRISD
    CLRF TRISC
    BSF TRISA, 0
    BSF STATUS, RP1
    MOVLW b'00000001'
    MOVWF ANSEL
    CLRF ANSELH
    BCF STATUS, RP1
    MOVLW b'11000000'
    MOVWF INTCON
    MOVLW b'10000000'
    MOVWF OPTION_REG
    MOVLW b'01000000'
    MOVWF PIE1
    MOVLW b'00000000'
    MOVWF ADCON1
    BCF STATUS, RP0
    MOVLW b'01000001'
    MOVWF ADCON0
    BCF PIR1, ADIF
    
    CLRF index
    CLRF unidad
    CLRF decena
    CLRF centena
    
    MOVLW .100
    MOVWF cien
    MOVLW .10
    MOVWF diez
    MOVLW .1
    MOVWF uno
    CALL delay
    BSF ADCON0, 1
    
Loop
    CALL multiplex
    GOTO Loop
    
    multiplex
	MOVF index, w
	CALL TablaMulti
	MOVWF PORTC
	MOVF index, 0
	ADDLW 0x20
	MOVWF FSR
	MOVF INDF, 0
	CALL TablaNormal
	MOVWF PORTD
	
	CALL delay
	
	INCF index, f
	MOVLW .3
	SUBWF index, 0
	BTFSC STATUS, Z	    ;es cero el flag de cero?
	CLRF index	    ;si es uno limpiamos
	RETURN
    
    delay
	MOVLW .1
	MOVWF contador1
    d1
	MOVLW .200
	MOVWF contador2
    d2
	NOP
	DECFSZ contador2, F
	GOTO d2
	DECFSZ contador1, F
	GOTO d1
	RETURN

ISR
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP

    CLRF centena
    CLRF decena
    CLRF unidad

    MOVF ADRESH, W
    MOVWF dato

; --- centenas ---
resta_cen
    MOVF cien, W
    SUBWF dato, f
    BTFSS STATUS, C
    GOTO fin_c
    INCF centena, f
    GOTO resta_cen
fin_c
    MOVF cien, W
    ADDWF dato, f

; --- decenas ---
resta_dec
    MOVF diez, W
    SUBWF dato, f
    BTFSS STATUS, C
    GOTO fin_d
    INCF decena, f
    GOTO resta_dec
fin_d
    MOVF diez, W
    ADDWF dato, f

; --- unidades ---
resta_uni
    MOVF uno, W
    SUBWF dato, f
    BTFSS STATUS, C
    GOTO fin_u
    INCF unidad, f
    GOTO resta_uni
fin_u

    BCF PIR1, ADIF
    BSF ADCON0, GO    ; iniciar nueva conversión

    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE

;ISR
;    ;guardado de W y STATUS
;    MOVWF W_TEMP
;    SWAPF STATUS, W
;    MOVWF STATUS_TEMP
;    
;    rutina
;	CLRF centena
;	CLRF unidad
;	CLRF decena
;	MOVF ADRESH,0 
;	MOVWF dato
;	resta_cen
;	    MOVF cien, 0
;	    SUBWF dato, 1
;	    BTFSC STATUS, Z
;	    GOTO fin_c
;	    BTFSC STATUS, C
;	    GOTO incrementar_c
;	    GOTO fin_c
;	    incrementar_c
;		INCF centena,1
;		GOTO resta_cen
;	    fin_c
;	    MOVF cien, 0
;	    ADDWF dato, 1
;	resta_dec
;	    MOVF diez, 0
;	    SUBWF dato, 1
;	    BTFSC STATUS, Z
;	    GOTO fin_d
;	    BTFSC STATUS, C
;	    GOTO incrementar_d
;	    GOTO fin_d
;	    incrementar_d
;		INCF decena,1
;		GOTO resta_dec
;	    fin_d
;	    MOVF diez, 0
;	    ADDWF dato, 1
;	resta_uni
;	    MOVF uno, 0
;	    SUBWF dato, 1
;	    BTFSC STATUS, Z
;	    GOTO fin
;	    BTFSC STATUS, C
;	    GOTO incrementar_u
;	    GOTO fin
;	    incrementar_u
;		INCF unidad, 1
;		GOTO resta_uni
;	    fin
;		BCF PIR1, ADIF
;		BSF ADCON0, 1
;		GOTO Salida
;    
;    Salida
;	SWAPF STATUS_TEMP, W
;	MOVWF STATUS
;	SWAPF W_TEMP, F
;	SWAPF W_TEMP, W
;	RETFIE
	
END


