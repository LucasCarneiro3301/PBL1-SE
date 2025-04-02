ORG 0000H          ; Endereço inicial do programa
   LJMP START

ORG 003H
    LJMP INTERRUPCAO

; Tabela de dígitos para display de 7 segmentos (ânodo comum)
DIGIT_TABLE:
    DB 3FH         ; 0
    DB 06H         ; 1
    DB 5BH         ; 2
    DB 4FH         ; 3
    DB 66H         ; 4
    DB 6DH         ; 5
    DB 7DH         ; 6
    DB 07H         ; 7
    DB 7FH         ; 8
    DB 6FH         ; 9

START: ; Configuração inicial
    MOV IE, #10000001B  ; Habilita interrupção externa 0 (EX0) e global (EA)
    MOV TCON, #00000001B  ; Configura INT0 para borda de descida
    SETB P3.2

    MOV TMOD, #01H  ; Timer 0 em modo 1
    MOV DPTR, #DIGIT_TABLE

    MOV P2, #07H
    MOV R7, #01H

MAIN_LOOP:
    MOV A, R7          ; Move o valor de R7 para A
    CJNE A, #01H, CONTINUA  ; Se R7 ≠ 1, pula para CONTINUA
    CALL ROTINA_4S     ; Se R7 == 1, executa ROTINA_4S

CONTINUA:
    CALL ROTINA_1S  
    CALL ROTINA_3S  
    INC R7            ; Incrementa R7
    JMP MAIN_LOOP  

INTERRUPCAO:
    CLR IE.0        ; Desativa interrupção externa 0 temporariamente
    CLR TCON.1      ; Limpa a flag da interrupção externa 0 (IT0)
    
    SETB TCON.0     ; Reconfigura IT0 para borda de descida
    SETB IE.0       ; Reativa a interrupção externa 0

    CALL ROTINA_4S
    
    RETI  ; Force return to the main loop

ROTINA_4S:
    MOV R0, #4      ; Inicia em 4
    MOV P2, #03H

LOOP_4S:
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CLR IE.0     ; Disable external interrupt
    CALL DELAY   ; Espera 1 segundo
    SETB IE.0    ; Re-enable external interrupt
    
    MOV A, R0 ; Verifica se chegou a zero
    JZ FIM_4S       ; Se já for zero, termina
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_4S    ; Continua o loop
    
FIM_4S:
	MOV R7, #0H
	RET

ROTINA_3S:
    MOV R0, #3      ; Inicia em 3
    MOV P2, #06H

LOOP_3S:
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CLR IE.0     ; Disable external interrupt
    CALL DELAY   ; Espera 1 segundo
    SETB IE.0    ; Re-enable external interrupt
    
    MOV A, R0 ; Verifica se chegou a zero
    JZ FIM_3S       ; Se já for zero, termina
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_3S    ; Continua o loop
    
FIM_3S:
    RET

ROTINA_1S:
    MOV R0, #1      ; Inicia em 1
    MOV P2, #05H

LOOP_1S:
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CLR IE.0     ; Disable external interrupt
    CALL DELAY   ; Espera 1 segundo
    SETB IE.0    ; Re-enable external interrupt

    MOV A, R0 ; Verifica se chegou a zero
    JZ FIM_1S       ; Se já for zero, termina
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_1S    ; Continua o loop
    
FIM_1S:
    RET

DELAY:
    ; Carrega o valor de reload para o Timer 0
    MOV TH0, #0FFH  ; Valor de reload
    MOV TL0, #090H  ; Inicializa o contador do Timer 0 (começa em 255)

    ; Inicia o Timer 0
    SETB TR0         ; Ativa o Timer 0

; Espera o Timer 0 overflow
WAIT:
    JNB TF0, WAIT    ; Espera até o overflow (TF0 será setado quando o timer transbordar)

    ; Para o Timer 0 após o overflow
    CLR TR0          ; Desativa o Timer 0
    CLR TF0          ; Limpa o flag de overflow do Timer 0

    RET              ; Retorna da sub-rotina DELAY

END

