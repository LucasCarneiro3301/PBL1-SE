; -----------------------------------------------
; CONSTANTS
; -----------------------------------------------

data_ptr	data	20h	; Number to display
data_len	equ	4h	; Number of digits

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

	org 003h
	ljmp INTERRUPCAO_1

	org 000bh   ; Vetor da interrupção do Timer 0
	reti

	org 0013h
	ljmp INTERRUPCAO_2  ; Interrupção externa 1 (IE1)

; -----------------------------------------------
; SUBPROGRAMS
; -----------------------------------------------
INTERRUPCAO_1:
	mov r7, #00h
	reti  ; Force return to the main loop

INTERRUPCAO_2:
	inc r6
	
	clr tcon.1      ; Limpa manualmente a flag de interrupção externa 1 (IE1)

	reti  ; Force return to the main loop

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

;; Display the number on the LED display
DISPLAY_NUMBER:
	dec	r0
	mov	a, b
	rr	a
	mov	b, a

	mov	a, @r0
	movc	a, @a+dptr

	mov	p0, #0ffh
	mov	p1, a
	mov	p0, b

	cjne	r0, #data_ptr, DISPLAY_NUMBER
	ret

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

NOT_ZERO:
	mov	a, #1  ; Acumulador ≠ 0 -> Z flag limpa
	ret

; -----------------------------------------------
; PROGRAM START
; -----------------------------------------------
START:
	mov	ip, #00000101b	; Definindo INT0 e INT1 com alta prioridade
	mov	ie, #10000111b  ; Habilita interrupção externa 0 (EX0) e global (EA)
	mov	tcon, #00010001b  ; Configura INT0 para borda de descida

	clr	tr0       ; Garante que o Timer 0 está desligado
	mov	tmod, #01h  ; Configura Timer 0 no modo 1

	mov	b, #0eeh
	mov	dptr, #numbers
	mov	data_ptr+2, #0
	mov	data_ptr+3, #0
	mov	p2, #07h
	mov 	r6, #01H
	mov	r7, #01h

	setb 	ie.0     ; Disable external interrupt
	setb 	ie.2

; -----------------------------------------------
; MAIN LOOP
; -----------------------------------------------
MAIN:
	call 	ROTINA_10_S
	call 	ROTINA_3_S
	call 	ROTINA_7_S
	jmp 	MAIN

ROTINA_10_S:
	setb 	ie.2
	mov	data_ptr+0, #0
	mov	data_ptr+1, #1
	mov	p2, #03h
	jmp	LOOP_10_S

ROTINA_15_S:
	mov	r6, #01H
	mov	data_ptr+0, #5
	mov	data_ptr+1, #1

LOOP_10_S:
	mov	a, r7
	jz	FIM_ROTINA_10S

	mov	r0, #data_ptr+data_len
	call	DISPLAY_NUMBER
	call	DELAY

	call	CHECK_ZERO
	jz	FIM_ROTINA_10S

	mov	r0, #data_ptr
	call	DECREMENT_NUMBER

	mov 	A, R6       ; Move R6 para o acumulador
    	clr 	C
    	SUBB 	A, #05H
    	JNC 	ROTINA_15_S

	jmp	LOOP_10_S

ROTINA_3_S:
	clr 	ie.2
	mov	data_ptr+0, #3
	mov	data_ptr+1, #0
	mov	p2, #05h

LOOP_3_S:
	mov	a, r7
	jz	FIM_ROTINA_3S
	
	mov	r0, #data_ptr+data_len
	call	DISPLAY_NUMBER
	call	DELAY

	call	CHECK_ZERO
	jz	FIM_ROTINA_3S

	mov	r0, #data_ptr
	call	DECREMENT_NUMBER

	jmp	LOOP_3_S

ROTINA_7_S:
	clr 	ie.2
	mov	data_ptr+0, #7
	mov	data_ptr+1, #0
	mov	p2, #06h
	jmp	LOOP_7_S
	
EMERGENCIA:
	mov	r7, #01h
	mov	data_ptr+0, #5
	mov	data_ptr+1, #1

LOOP_7_S:
	mov	a, r7
	jz	EMERGENCIA
	
	mov	r0, #data_ptr+data_len
	call	DISPLAY_NUMBER
	call	DELAY

	call	CHECK_ZERO
	jz	FIM_ROTINA_7S

	mov	r0, #data_ptr
	call	DECREMENT_NUMBER

	jmp	LOOP_7_S

FIM_ROTINA_7S:
	mov	r7, #01h
	ret

FIM_ROTINA_10S:
	mov r6, #01h
	ret

FIM_ROTINA_3S:
	ret

; -----------------------------------------------
; Delay
; -----------------------------------------------
DELAY:
	mov	th0, #0ffh      ; Carrega alto byte
	mov	tl0, #0e0h      ; Carrega baixo byte
	setb	tr0            ; Inicia Timer 0
ESPERA:
	jnb	tf0, ESPERA     ; Espera overflow
	clr	tr0             ; Para o timer
	clr	tf0             ; Limpa o flag
	ret

end
