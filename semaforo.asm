ORG 0000H          ; Endereço inicial do programa
   LJMP START

ORG 003H
    LJMP INTERRUPCAO_1

ORG 000BH   ; Vetor da interrupção do Timer 0
    	RETI

ORG 0013H
    LJMP INTERRUPCAO_2  ; Interrupção externa 1 (IE1)

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
	MOV IP, #00000101B	;Definindo INT0 e INT1 com alta prioridade
    	MOV IE, #10000111B  ; Habilita interrupção externa 0 (EX0) e global (EA)
    	MOV TCON, #00010001B  ; Configura INT0 para borda de descida

    	CLR TR0       ; Garante que o Timer 0 está desligado
    	MOV TMOD, #01H  ; Configura Timer 0 no modo 1

    	MOV DPTR, #DIGIT_TABLE

    	MOV P2, #07H
    	MOV R7, #01H
    	MOV R6, #00H

    	CLR IE.0
    	CLR IE.2

MAIN_LOOP:
    CALL ROTINA_4S
    CALL ROTINA_1S
    CALL ROTINA_3S
    
    JMP MAIN_LOOP  

INTERRUPCAO_1:  
    MOV R7, #00H

    CLR IE.0        ; Desativa interrupção externa 0 temporariamente
    CLR TCON.1      ; Limpa manualmente a flag de interrupção externa 0 (IE0)
    
    RETI  ; Force return to the main loop

INTERRUPCAO_2:  
    INC R6

    CLR IE.2        ; Desativa interrupção externa 0 temporariamente
    CLR TCON.1   ; Limpa manualmente a flag de interrupção externa 1 (IE1)
    
    RETI  ; Force return to the main loop

ROTINA_4S:
    CLR IE.0     ; Disable external interrupt
    SETB IE.2
    MOV R0, #4      ; Inicia em 4
    MOV P2, #03H

LOOP_4S:
    	MOV A, R0
    	MOVC A, @A+DPTR ; Obtém padrão do display
    	MOV P1, A       ; Mostra dígito
    	CALL DELAY   ; Espera 1 segundo
    
    	MOV A, R0 ; Verifica se chegou a zero
    	JZ FIM_4S       ; Se já for zero, termina

    	MOV A, R6       ; Move R6 para o acumulador
    	CLR C 
    	SUBB A, #05H
    	JNC MAIOR_QUE_5

CONTINUA:
    	DEC R0          ; Decrementa o contador
    	SJMP LOOP_4S    ; Continua o loop

MAIOR_QUE_5:
	MOV R6, #00H
	MOV R0, #09H
	SJMP LOOP_4S    ; Continua o loop
    
FIM_4S:
	;MOV R6, #00H
	RET

ROTINA_3S:
    CLR IE.2
    MOV R0, #3      ; Inicia em 3
    MOV P2, #06H

LOOP_3S:
    CLR IE.0     ; Disable external interrupt
    MOV A, R0
    MOVC A, @A+DPTR ; Obtém padrão do display
    MOV P1, A       ; Mostra dígito
    CALL DELAY   ; Espera 1 segundo
    SETB IE.0    ; Re-enable external interrupt
    
    MOV A, R0 ; Verifica se chegou a zero
    JZ FIM_3S       ; Se já for zero, termina

    MOV A, R7
    JZ FIM_3S
    
    DEC R0          ; Decrementa o contador
    SJMP LOOP_3S    ; Continua o loop
    
FIM_3S:
    MOV R7, #01H
    RET

ROTINA_1S:
	CLR IE.2
	CLR IE.0     ; Disable external interrupt
    	MOV R0, #1      ; Inicia em 1
    	MOV P2, #05H

LOOP_1S:
    	MOV A, R0
    	MOVC A, @A+DPTR ; Obtém padrão do display
   	MOV P1, A       ; Mostra dígito
    	CALL DELAY   ; Espera 1 segundo

    	MOV A, R0 ; Verifica se chegou a zero
    	JZ FIM_1S       ; Se já for zero, termina
    
    	DEC R0          ; Decrementa o contador
    	SJMP LOOP_1S    ; Continua o loop
    
FIM_1S:
    RET

DELAY:
    ; Carrega o valor de reload para o Timer 0
    MOV TH0, #0FFH  ; Valor de reload
    MOV TL0, #0E0H  ; Inicializa o contador do Timer 0 (começa em 255)

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

