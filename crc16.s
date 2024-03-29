; R1 - crc
; R2 - data length
; R3 - pointer to current byte of data
; R4 - current byte
; R5 - result
; R20 - temp for main loop
; R21 - temp for inner loop

.data

Prompt:       .asciiz  "Len: "
PrintfFormat: .asciiz  "CRC16 = %x\n\n"
              .align   2
PrintfPar:    .word    PrintfFormat
PrintfValue:  .space   8

string:       .space 64
par1:         .word 0

.word string
.word 64

.global main

.text

main:

ADDI R1,R0,Prompt  ;
JAL  InputUnsigned ; length input
ADD  R2, R0, R1    ;

ADDI R14, R0, par1 ; sequence input
trap 3             ;

ADDU R1, R0, #0xFFFF    ; crc init
ADDI R3, R0, string     ; pointer to first byte

;============main loop===============
loop1:

BEQZ R2, done    ; if len == 0 jump to done
SUBI R2, R2, #1  ; decrease length
LB   R4, 0(R3)   ; next byte
ADDI R3, R3, #1

SLLI R20, R4, #8   ; shift
XOR  R1, R1, R20   ; xor

;-------------inner loop--------------
ADDI R21, R0, #8

loop2: BEQZ R21, loop1

SUBI R21, R21, #1
ANDI R20, R1, #0x8000

SLLI  R1, R1, #1

BNEZ R20, if
BEQZ R20, else

if:
XORI R1, R1, #0x1021 ; 0x1021 - polynomial

else:
J loop2
;-------------------------------------

BNEZ R2, loop1
;=====================================

done:

ANDI R5, R1, #0xFFFF

SW    PrintfValue, R5   ;
ADDI  R14,R0,PrintfPar  ; output
trap  5                 ;

trap  0
