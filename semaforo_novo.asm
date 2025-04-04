; P0 (Bits 0, 1) -> Controle do multiplexador do display de 7 segmentos
; P1 (Todos os 8 bits) -> Controle dos segmentos do display
; P2 (Bits 0, 1, 2) -> LEDs de indicação
; P3 (Bits 2, 3) -> Entradas das chaves DIP
; R0 -> Ponteiro para os dígitos exibidos
; R6 -> Contador auxiliar
; R7 -> Flag de emergência e controle de estado
; DPTR -> Aponta para a tabela de segmentos
; B -> Armazena temporariamente o controle do multiplexador
; IE -> Controle de interrupções
; TCON -> Configuração de interrupções e timers

; -----------------------------------------------
; CONSTANTS
; -----------------------------------------------

data_ptr	data	20h	; Número para o display
data_len	equ	4h	; Número de dígitos

numbers: db 11000000b ; 0
         db 11111001b ; 1
         db 10100100b ; 2
         db 10110000b ; 3
         db 10011001b ; 4
         db 10010010b ; 5
         db 10000010b ; 6
         db 11111000b ; 7
         db 10000000b ; 8
         db 10010000b ; 9

; -----------------------------------------------
; VECTORS
; -----------------------------------------------
	org	0
	jmp	START

	org 	003h
	ljmp 	INTERRUPCAO_1 	; Interrupção externa 0 (IE0)

	org 	000bh   	; Vetor da interrupção do Timer 0
	reti

	org 	0013h
	ljmp 	INTERRUPCAO_2  	; Interrupção externa 1 (IE1)

; -----------------------------------------------
; ROTINAS
; -----------------------------------------------

INTERRUPCAO_1:
	mov 	r7, #00h	; Faz com que o registrador R7 assuma valor 0 (proíbe as rotinas do sinal verde e amarelo)
	reti

INTERRUPCAO_2:
	clr 	ie.2
	clr 	tcon.1	; Limpa manualmente a flag de interrupção externa 1 (IE1)

	inc 	r6	; Incrementa o registrador R6. Conta o número de veículos

	reti

; Decrementa o número
DECREMENT_NUMBER:
	dec	@r0
	cjne	@r0, #0ffh, DEC_NUM_END

	mov	@r0, #9
	inc	r0
	cjne	r0, #data_ptr+data_len, $+4
	ret
	call	DECREMENT_NUMBER
DEC_NUM_END:
	ret

; Mostra o número no display
DISPLAY_NUMBER:
	dec	r0		; Decrementa o registrador R0
	mov	a, b		; Move o conteúdo de B para o acumulador A
	rr	a		; Faz um rotate right (rotaciona os bits de A para a direita)
	mov	b, a		; Atualiza o registrador B com o novo valor rotacionado

	mov	a, @r0		; Carrega em A o valor apontado por R0 (endereço do dígito atual)
	movc	a, @a+dptr	; Usa o valor de A como índice para buscar o padrão de segmentos em uma tabela apontada por DPTR

	mov	p0, #0ffh	; Desliga todos os dígitos do display (todos bits em 1)
	mov	p1, a 		; Controla cada segmento individualmente
	mov	p0, b 		; Controla, através da multiplexação, cada dígito do display

	cjne	r0, #data_ptr, DISPLAY_NUMBER
	ret

; Verifica se todos os bytes em `data_ptr` são zero.
CHECK_ZERO:
	mov	a, data_ptr+0
	jnz	NOT_ZERO
	mov	a, data_ptr+1
	jnz	NOT_ZERO
	mov	a, data_ptr+2
	jnz	NOT_ZERO
	mov	a, data_ptr+3
	jnz	NOT_ZERO
	clr	acc.7
	ret

; Acumulador ≠ 0 -> Z flag limpa
NOT_ZERO:
	mov	a, #1	; Coloca o valor 1 no acumulador, útil para indicar que nem todos os bytes de data_ptr são zero.
	ret

; -----------------------------------------------
; PROGRAM START
; -----------------------------------------------
START:
	mov	ip, #00000101b		; Define as interrupções INT0 e INT1 para alta prioridade
	mov	ie, #10000111b  	; Habilita interrupção externa 0 (EX0) e a global (EA)
	mov	tcon, #00010001b	; Configura as interrupções para borda de descida

	clr	tr0       		; Garante que o Timer 0 está desligado
	mov	tmod, #01h  		; Inicializa o Timer 0 no modo 1

	mov	b, #0eeh
	mov	dptr, #numbers
	mov	data_ptr+2, #0		; Zera permanentemente o terceiro dígito
	mov	data_ptr+3, #0		; Zera permanentemente o quarto dígito
	mov	p2, #07h		; Desliga os leds
	mov 	r6, #00H		; Inicia em zero o registrador que conta o número de veiculos
	mov	r7, #01h		; Inicia em 1 o registrador que habilita as rotinas de sinal verde e amarelo

	setb 	ie.0     		; Habilita a interrupção 0
	setb 	ie.2			; Habilita a interrupção 1

; -----------------------------------------------
; MAIN LOOP
; -----------------------------------------------

MAIN:
	call 	ROTINA_10_S	; Rotina padrão do sinal verde
	call 	ROTINA_3_S	; Rotina padrão do sinal amarelo
	call 	ROTINA_7_S	; Rotina padrão do sinal vermelho
	jmp 	MAIN

; -----------------------------------------------
; SINAL VERDE
; -----------------------------------------------

ROTINA_15_S:
	mov	r6, #00H	; Reinicia a contagem
	mov	data_ptr+0, #5	; Dígito 5
	mov	data_ptr+1, #1	; Dígito 1 (15)
	jmp	LOOP_10_S

ROTINA_10_S:
	setb 	ie.2		; Habilita a INT1
	mov	data_ptr+0, #0	; Dígito 0
	mov	data_ptr+1, #1	; Dígito 1 (10)
	mov	p2, #03h	; Liga somente o 3º led

LOOP_10_S:
	setb ie.2			; Habilita a INT1
	mov	a, r7			; Move R7 para o acumulador
	jz	FIM_ROTINA_10S		; Se o acumulador valer zero, finaliza a rotina

	mov	r0, #data_ptr+data_len	; Define o número atual
	call	DISPLAY_NUMBER		; Mostra no display
	call	DELAY			; Executa um atraso

	call	CHECK_ZERO		; Verifica se já atingiu zero na contagem
	jz	FIM_ROTINA_10S		; Se atingiu, finaliza a rotina

	mov	r0, #data_ptr		; Recebe o número atual
	call	DECREMENT_NUMBER	; Decrementa

	mov 	a, r6       		; Move R6 para o acumulador
    	clr 	c			; Limpa o carry
    	SUBB 	a, #05H			; Faz a subtração entre o valor do acumulador e 5
    	JNC 	ROTINA_15_S		; Se for maior ou igual a 5, chama a rotina de 15 seg

	jmp	LOOP_10_S

; -----------------------------------------------
; SINAL AMARELO
; -----------------------------------------------

ROTINA_3_S:
	clr 	ie.2		; Desabilita INT1
	mov	data_ptr+0, #3	; Dígito 3
	mov	data_ptr+1, #0	; Dígito 0 (03)
	mov	p2, #05h	; Liga somente o 2º led 

LOOP_3_S:
	mov	a, r7			; Move R7 para o acumulador
	jz	FIM_ROTINA_3S		; Se o acumulador valer zero, finaliza a rotina
	
	mov	r0, #data_ptr+data_len
	call	DISPLAY_NUMBER
	call	DELAY

	call	CHECK_ZERO
	jz	FIM_ROTINA_3S

	mov	r0, #data_ptr
	call	DECREMENT_NUMBER

	jmp	LOOP_3_S

; -----------------------------------------------
; SINAL VERMELHO
; -----------------------------------------------

ROTINA_7_S:
	clr 	ie.2		; Desabilita INT1
	mov	data_ptr+0, #7	; Dígito 7
	mov	data_ptr+1, #0	; Dígito 0 (07)
	mov	p2, #06h	; Liga somente o 1° led
	jmp	LOOP_7_S
	
EMERGENCIA:
	mov	r7, #01h	; Reabilita as rotinas do sinal verde e amarelo
	mov	data_ptr+0, #5	; Dígito 5
	mov	data_ptr+1, #1	; Dígito 1 (15)

LOOP_7_S:
	mov	a, r7			; Move R7 para o acumulador
	jz	EMERGENCIA		; Se o acumulador valer zero, inicia o modo de emergencia
	
	mov	r0, #data_ptr+data_len
	call	DISPLAY_NUMBER
	call	DELAY

	call	CHECK_ZERO
	jz	FIM_ROTINA_7S

	mov	r0, #data_ptr
	call	DECREMENT_NUMBER

	jmp	LOOP_7_S

; -----------------------------------------------
; FINALIZA AS ROTINAS DO SEMAFORO
; -----------------------------------------------

FIM_ROTINA_7S:
	mov	r7, #01h	; Reabilita as rotinas do sinal verde e amarelo
	ret

FIM_ROTINA_10S:
	mov r6, #00h		; Zera a contagem
	ret

FIM_ROTINA_3S:
	ret

; -----------------------------------------------
; DELAY
; -----------------------------------------------

DELAY:
	mov	th0, #0ffh      ; Carrega o MSB
	mov	tl0, #0e0h      ; Carrega o LSB
	setb	tr0            	; Inicia Timer 0
ESPERA:
	jnb	tf0, ESPERA     ; Espera overflow
	clr	tr0             ; Para o timer
	clr	tf0             ; Limpa o flag
	ret

end
