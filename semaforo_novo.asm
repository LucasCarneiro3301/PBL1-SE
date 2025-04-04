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
	jmp	start

; -----------------------------------------------
; SUBPROGRAMS
; -----------------------------------------------
decrement_number:
	dec	@R0
	cjne	@R0, #0FFh, dec_num_end

	mov	@R0, #9
	inc	R0
	cjne	R0, #data_ptr+data_len, $+4
	ret
	call	decrement_number
dec_num_end:
	ret

;; Display the number on the LED display
display_number:
	dec	R0
	mov	A, B
	rr	A
	mov	B, A

	mov	A, @R0
	movc	A, @A+DPTR

	mov	P0, #0FFh
	mov	P1, A
	mov	P0, B

	cjne	R0, #data_ptr, display_number
	ret

check_zero:
	mov	A, data_ptr+0
	jnz	not_zero
	mov	A, data_ptr+1
	jnz	not_zero
	mov	A, data_ptr+2
	jnz	not_zero
	mov	A, data_ptr+3
	jnz	not_zero
	clr	ACC.7
	ret

not_zero:
	mov	A, #1  ; Acumulador ≠ 0 -> Z flag limpa
	ret

; -----------------------------------------------
; PROGRAM START
; -----------------------------------------------
start:
	mov	B, #0EEh
	mov	DPTR, #numbers
	mov	data_ptr+2, #0
	mov	data_ptr+3, #0
	MOV P2, #07H

; -----------------------------------------------
; MAIN LOOP
; -----------------------------------------------
main:
	call rotina_10_s
	call rotina_3_s
	call rotina_7_s
	jmp main

rotina_10_s:
	mov	data_ptr+0, #0
	mov	data_ptr+1, #1
	MOV P2, #03H

loop_10_s:
	mov	R0, #data_ptr+data_len
	call	display_number
	call	DELAY

	call check_zero
	jz fim_rotina

	mov	R0, #data_ptr
	call	decrement_number

	jmp loop_10_s

rotina_3_s:
	mov	data_ptr+0, #3
	mov	data_ptr+1, #0
	MOV P2, #05H

loop_3_s:
	mov	R0, #data_ptr+data_len
	call	display_number
	call	DELAY

	call check_zero
	jz fim_rotina

	mov	R0, #data_ptr
	call	decrement_number

	jmp loop_3_s

rotina_7_s:
	mov	data_ptr+0, #7
	mov	data_ptr+1, #0
	MOV P2, #06H

loop_7_s:
	mov	R0, #data_ptr+data_len
	call	display_number
	call	DELAY

	call check_zero
	jz fim_rotina

	mov	R0, #data_ptr
	call	decrement_number

	jmp loop_7_s

fim_rotina:
	ret

; -----------------------------------------------
; Delay de aproximadamente 50 ms com Timer 0
; -----------------------------------------------
DELAY:
	mov TMOD, #01h      ; Timer 0, modo 1 (16 bits)
	clr TF0             ; Limpa o flag de overflow
	mov TH0, #0FFH      ; Carrega alto byte
	mov TL0, #0E0H      ; Carrega baixo byte
	setb TR0            ; Inicia Timer 0
espera:
	jnb TF0, espera     ; Espera overflow
	clr TR0             ; Para o timer
	clr TF0             ; Limpa o flag
	ret

end