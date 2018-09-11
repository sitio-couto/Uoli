@ Confere se uma interrupcao ja esta ocorrendo, nesse caso nao trata as CALLBACKS
@ldr r11, =IRQ_FLAG
@ldr r10, [r11]
@cmp r10, #1             @ Caso a flag estiver setada, ignora as CALLBACKS
@beq end_irq

@mov r10, #1             @ Atualiza a flag para Sinalizar que as CALLBACKS
@str r10, [r11]          @ ja estao sendo tratadas.

@ Trata as CALLBACKS
@ NOTA: NESTAS FUNCOES O R12 EH COMPARTILHADO COMO NUMERO DE CALLBACKS ATIVAS
@bl proximity_callbacks
@bleq alarm_callback

@cmp r6, #0                  @ Verifica se ha callbacks a seren tratadas
@beq end_irq                 @ Se nao ha callbacks, temina IRQ

@bl run_triggered_callbacks   @ Chama as callbacks


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@run_triggered_callbacks:
@    @ R6 CONTEM O NUMERO DE CALLBACKS ATIVAS
@    ldr r8, =IRQ_FLAG
@    ldr r10, =TRIGGERED_CALLBACKS  @ Carrega as callbacks a serem tratadas
@    @ldr r11, =QNT_CALLBACKS
@    @ldr r12, [r11]
@
@    loop_tcb:                  @ Trata as callbacks que foram ativas
@    ldr r9, [r10, r12, lsl #2] @ Pega o endereco da proxima callback
@
@    push {r9-r12, lr}         @ Salva os dados do IRQ para chamar o codigo de usuario
@    add lr, pc, #8            @ Salva o endereco de retorno duas depois do mov
@    mov pc, r9                @ Chama o codigo de usuario para tratar a callback
@    pop {r9-r12, lr}          @ Recupera os dados do IRQ
@
@    sub r12, r12, #1            @ Subtrai a callback tratada
@    cmp r12, #0                @ Verifica se tratou todas as callbacks ativadas
@    streq r12, [r8]            @ Reseta a IRQ_FLAG para tratamento de callbacks
@    streq r12, [r11]           @ Zera o numero de TRIGGERED_CALLBACKS
@    beq end_irq               @ Finaliza a interrupcao para tratamento de callbacks
@
@    b loop_tcb                @ Vai para a proxima callback

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@proximity_callbacks:
@    @ Carrega os parametros das proximity_callbacks definidas pelo usuario
@    ldr r1, =SONAR_CALLBACKS      @ Carrega vetor com ID dos sonares
@    ldr r2, =DISTANCE_CALLBACKS   @ Carrega distancia minima para ativar a callback
@    ldr r3, =ADDRESS_CALLBACKS    @ Carrega endereco da funcao do usuario
@    ldr r4, =QNT_CALLBACKS        @ Carrega quantidade de callbacks definidas
@    ldr r4, [r4]                  @ Salva em R3 o numero de callbacks definidas
@    ldr r5, =TRIGGERED_CALLBACKS  @ Espaco para alocar callbacks ativas
@    mov r12, #0                   @ Numero de callbacks ativas
@
@
@loop_pcb:
@    cmp r4, #0        @ Verifica se ja testou todas as as callbacks
@    beq end_prox_cb_check      @ Se sim, finaliza a checagem
@    sub r4, r4, #1    @ Atualiza numero de callbacks a serem tratadas e ajusta indice
@
@    @ Carrega parametros para a syscall read_sonar
@    ldrb r0, [r1, r4]				        @ ID do sensor a ser verificado
@    ldr r10, [r2, r4, lsl #2]				@ Distancia minima necessaria
@    ldr r11, [r3, r4, lsl #2]				@ Endereco da funcao a ser chamada
@
@    push {r0-r3}
@    mov r7, #16
@    svc 0x0
@    cmp r0, r10						          @ Testa se precisa tratar a CALLBACK
@    pop {r0-r3}
@
@    strls r11, [r5, r12, lsl #2]	  @ Se menor, guarda o endereco da fucao a ser convocada
@    addls r12, r12, #1			        @ Atualiza o numero de CALLBACKS ativas se necessario
@
@    b loop_pcb				 @ Itera para proxima CALLBACK
@
@end_prox_cb_check:
@    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
