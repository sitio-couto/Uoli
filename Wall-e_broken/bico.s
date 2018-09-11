.global set_motor_speed
.global set_motors_speed
.global read_sonar
.global read_sonars
.global register_proximity_callback
.global	get_time
.global set_time
.global add_alarm


set_motor_speed:
@ Parametros:
@ R0: endereco para struct com 2 bytes (id e speed)
		push {r4-r12, lr} 	@ Salva dados do usuario

		ldrb r1, [r0, #1] 	@ Pega o segundo byte (speed) em r5
		ldrb r0, [r0, #0]		@ Pega o primeiro byte (id) em r4
		mov r7, #18			    @ Identifica syscall a ser chamada
		svc 0x0

		pop {r4-r12, lr}	  @ Devolve dados do usuario
		mov pc, lr

set_motors_speed:
@ Parametros:
@ R0: endereco para struct do motor 0 com 2 bytes (id e speed)
@ R1: endereco para struct do motor 1 com 2 bytes (id e speed)
		push {r4-r12, lr}

		ldrb r4, [r0, #0]
		ldrb r6, [r1, #0]

		cmp r4, r6
		bhi motor_1_0_
		b motor_0_1_

motor_0_1_:
		ldrb r5, [r0, #1]
		ldrb r7, [r1, #1]
		b set_values

motor_1_0_:
		ldrb r5, [r1, #1]
		ldrb r7, [r0, #1]
		b set_values

set_values:
		mov r0, r5
		mov r1, r7
		mov r7, #19
		svc 0x0

		pop {r4-r12, lr}
		mov pc, lr

read_sonar:
@ Parametros:
@ R0: id do sonar a ser lido
@ Retorno:
@ R0: tempo de resposta do sonar
		push {r4-r12, lr}

		mov r7, #16
		svc 0x0

		pop {r4-r12, lr}
		mov pc, lr

read_sonars:
@ Parametros:
@ R0: primeiro radar a ser lido
@ R1: radar onde termina a leitura
@ R2: vetor para armazenar os resultados
		push {r4-r12, lr}

		mov r10, r0			@ Salva o radar inicial
		mov r11, r1			@ Salva o radar final
		mov r9, r3			@ Salva o endereco do vetor

reading_sonars:
		mov r0, r10			@ Carrega o parametro da syscall
		mov r7, #16			@ Carrega o valor da syscall desejada
		svc 0x0					@ Realiza a syscall
		str r0, [r3]		@ Armazena o valor de retoro no vetor fornecido

		add r3, #4						@ Atualiza o endereco do vetor dos resultado
		cmp r10, r11					@ Compara com o ultimo sonar a ser lido
		add r10, r10, #1			@ Atualiza o sonar a ser lido
		cmp r10, #16					@ Se chegar ao valor 16 (inexistente)
		moveq r10, #0					@ "Da a volta" do sonar 15 para o 0
		bne reading_sonars		@ Caso nao eh o sonar de termino, repete

		pop {r4-r12, lr}
		mov pc, lr

register_proximity_callback:
@ Parametros:
@ R0 = ID do sensor a ser verificado
@ R1 = Distancia minima para ativacao
@ R2 = Endereco da funcao de tratamento
		push {r4-r12, lr}

		mov r7, #17			@ Carrega o valor da syscall register_proximity_callback
		svc 0x0					@ Realiza a syscall

		pop {r4-r12, lr}
		mov pc, lr


get_time:
@ Parametros:
@ R0: Endereco fornecido para devolver o retorno ao usuario.
		push {r4-r12, lr}

		mov r7, #20			@ Carrega o valor da syscall get_time
		svc 0x0					@ Realiza a syscall

		pop {r4-r12, lr}
		mov pc, lr

set_time:
@ Parametros:
@ R0: Novo tempo do sistema
		push {r4-r12, lr}

		mov r7, #21
		svc 0x0

		pop {r4-r12, lr}
		mov pc, lr


add_alarm:
@ Parametros:
@ R0 = endereco da funcao a ser chamada
@ R1 = tempo para o alarme se disparado
		push {r4-r12, lr}

		mov r7, #22
		svc 0x0

		pop {r4-r12, lr}
		mov pc, lr
