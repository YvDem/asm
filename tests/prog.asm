 LIST  R=DEC ; Sets number base to decimal
 include p16f628.inc ; Includes microchip configuration for this processor
 __CONFIG _CP_OFF & _WDT_OFF & _HS_OSC & _PWRTE_ON & _LVP_OFF & _MCLRE_ON
 
 ; CP - Copy protection (off)
 ; WDT - Watchdog timer (off)
 ; HS_OSC - Im using a high speed oscillator (20Mhz)
 ; PWRTE - Power up timer delay (on), leaves a delay for voltages to stabilise
 ; LVP - Low voltage programming (off)
 ; MCLRE - Holds MCLR pin high if on (on)

  cblock 0x20      ; Declare variable addresses starting at 0x20
  DELAY,DELAYTMP
  endc

; TEST NUMBERS
B'00000001'
b'00000010'
b0010110011
b0010110011

D'4444'
d'4444'
d45555
D56478

o12356
O12356 
o'12356'
O'12356'

h'1234'
H'1234'
0x1234
h1234
H1234


1234
356
45675


;##### Macros #####
DELAY_MILLI macro TIME
  movlw TIME
  movwf DELAY
  call DELAY_MS
  endm

DELAY_MICRO macro TIME
  movlw TIME
  movwf DELAY
  call DELAY_US
  endm

SENDDATA macro DATA
  movlw DATA
  call TRANSMIT
  endm

CLEARSCREEN macro
  movlw 0xFE
  call TRANSMIT
  movlw 0x58
  call TRANSMIT
  endm

;##### Program Code #####
        ORG    0
  goto MAIN       
       
;##### Subroutines #####
delay_us:               ; busy wait of DELAY us
  nop                  ; (1)
  nop                  ; (2)
  decfsz DELAY,f         ; test DELAY count (3)
  goto delay_us          ; loop if not done (4,5)
  return               ; gtfo (4,5)

delay_us:           ; busy wait of DELAY ms
  movf DELAY,w
  movwf DELAYTMP         ; save DELAY time
DELAY_MS_LOOP            ; inner loop
  movlw 245               ; load 245 (1)
  movwf DELAY            ; into DELAY (2)
  call DELAY_US            ; wait 245us (3-249)
  movlw 245               ; load 245 (250)
  movwf DELAY            ; into DELAY (251)
  call DELAY_US            ; wait 245us (252-498)
  movlw 245               ; load 245 (499)
  movwf DELAY            ; into DELAY (500)
  call DELAY_US            ; wait 245us (501-747)
  movlw 246               ; load 246 (748)
  movwf DELAY            ; into DELAY (749)
  call DELAY_US            ; wait 246us (750-997)
  decfsz DELAYTMP,f         ; test DELAYTMP count (998)
  goto DELAY_MS_LOOP 
  GOTO     ; loop if not done (999,1000)
  return               ; gtfo (999,1000)
 
INIT:
  bsf STATUS,RP0          ; RAM PAGE 1
  movlw b'00000010'       ; RB7-RB4 and RB1(RX)=input, others output
  movwf TRISB
  movlw 0x40              ; 0x40 = 19.2kbps
  movwf SPBRG
  movlw b'00100100'       ; brgh = high (2)
  movwf TXSTA             ; enable Async Transmission, set brgh
  bcf STATUS,RP0          ; RAM PAGE 0
  movlw b'10010000'       ; enable Async Reception
  movwf RCSTA
  DELAY_MILLI 250
  DELAY_MILLI 250
  DELAY_MILLI 250
  DELAY_MILLI 250
  DELAY_MILLI 250
  DELAY_MILLI 250
  DELAY_MILLI 250
  DELAY_MILLI 250
  return
 
TRANSMIT
  movwf TXREG             ; send data in W 
  bsf STATUS,RP0          ; RAM PAGE 1
TRANSMITTEST
  btfss TXSTA,TRMT        ; (1) transmission is complete if hi
  goto TRANSMITTEST
  bcf STATUS,RP0          ; RAM PAGE 0
  return
 
;##### Main Program #####
MAIN
  call INIT
  CLEARSCREEN
receive
  btfss PIR1,RCIF         ; check for received data
  goto receive
  movf RCREG,W            ; save received data in W
  call TRANSMIT           ; send received data to display
  goto receive
  END