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

FLAG_INT EQU 20H

START:
    ; Configuração inicial
    MOV IE, #10000001B  ; Habilita interrupção externa 0 (EX0) e global (EA)
    MOV TCON, #00000001B  ; Configura INT0 para borda de descida
    SETB P3.2
    SETB FLAG_INT  ; Garante que FLAG_INT começa zerada

    MOV TMOD, #01H  ; Timer 0 em modo 1
    MOV DPTR, #DIGIT_TABLE

    MOV P2, #07H

MAIN_LOOP: ; Executa a sequência completa de decrementos
    JB FLAG_INT, CALL_4S
    CALL ROTINA_1S  ; 1,0
    CALL ROTINA_3S  ; 3,2,1,0
    SETB FLAG_INT
    ; Repete o ciclo infinitamente
    JMP MAIN_LOOP

CALL_4S:
     CALL ROTINA_4S  ; 4,3,2,1,0
     CLR FLAG_INT
     JMP MAIN_LOOP

INTERRUPCAO:
    CLR FLAG_INT
    CALL ROTINA_4S  ; 4,3,2,1,0
    CLR TCON.1
    RETI            ; Retorna corretamente da interrupção

; Rotina de 5 segundos (4->3->2->1->0)
ROTINA_4S:
    MOV R0, #4      ; Inicia em 4
    MOV P2, #03H

LOOP_4S:
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CALL DELAY   ; Espera 1 segundo
    
    ; Verifica se chegou a zero
    MOV A, R0
    JZ FIM_4S       ; Se já for zero, termina
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_4S    ; Continua o loop
    
FIM_4S:
    RET

; Rotina de 4 segundos (3->2->1->0)
ROTINA_3S:
    MOV R0, #3      ; Inicia em 3
    MOV P2, #06H

LOOP_3S:
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CALL DELAY   ; Espera 1 segundo
    
    ; Verifica se chegou a zero
    MOV A, R0
    JZ FIM_3S       ; Se já for zero, termina
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_3S    ; Continua o loop
    
FIM_3S:
    RET

; Rotina de 2 segundos (1->0)
ROTINA_1S:
    MOV R0, #1      ; Inicia em 1
    MOV P2, #05H

LOOP_1S:
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CALL DELAY   ; Espera 1 segundo

    ; Verifica se chegou a zero
    MOV A, R0
    JZ FIM_1S       ; Se já for zero, termina
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_1S    ; Continua o loop
    
FIM_1S:
    RET

; Sub-rotina de atraso de 1 segundo
DELAY_1S:
    MOV R7, #14     ; Contador externo (ajuste conforme necessário)

DELAY:
    ; Carrega o valor de reload para o Timer 0
    MOV TH0, #0FFH  ; Valor de reload
    MOV TL0, #0C0H  ; Inicializa o contador do Timer 0 (começa em 255)

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
