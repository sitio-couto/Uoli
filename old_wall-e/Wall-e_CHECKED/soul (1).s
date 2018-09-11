.org 0x0
.set USER_CODE,     0x77812000
.set USER_SP,       0x77817004
.set MAX_CALLBACKS, 8
.set MAX_ALARMS,    8
.section .iv,"a"

interrupt_vector:
  b RESET_HANDLER
.org 0x4
  b UNDEFINED_HANDLER
.org 0x8
  b SUPERVISOR_HANDLER
.org 0x0c
  b UNDEFINED_HANDLER
.org 0x10
  b UNDEFINED_HANDLER
.org 0x18
  b IRQ_HANDLER
.org 0x1c
  b UNDEFINED_HANDLER


.data  @ Endereco dos dados: 0x77801800
SYSTEM_TIME:  .word 0
IRQ_FLAG:     .word 0
USER_CPSR:    .word 0
USER_TIME:    .word 0

POSITION_BITS_CALLBACKS:  .word 0
POSITION_BITS_ALARM:		  .word 0

SONAR_CALLBACKS:            .skip 16
DISTANCE_CALLBACKS:         .skip 32
ADDRESS_CALLBACKS:	        .skip 32

ADDRESS_ALARM:		          .skip 32
TIME_ALARM:                 .skip 32


@ Aloca espaco para pilha IRQ full-descendent
@ O espaco em maior pois pode ocorre irqs dentro de irqs e tambem o irq eh
@ responsavel por chamar as callbacks, logo faz extenso uso da pilha
.skip 200
IRQ_SP:

@ Aloca espaco para pilha SUPERVISOR full-descendent
.skip 100
SUPERVISOR_SP:

 @@@@@@@@ O .text JA NAO ATUALIZA O ENDERECO DE ESCRITA? PORQUE O .org NESSE CASO?
.text
@@@@@@@@ CONFIGURAR LR A PRIMEIRA VEZ PARA GARANTIR QUE PULE PARA O CODIGO DO USUARIO?
@@@@@@@@ OU O RESET EH ACESSADO APENAS UMA VEZ POR EXECUCAO?

RESET_HANDLER:

    @Faz o registrador que aponta para a tabela de interrup��es apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    msr CPSR_c, #0b00010010   @ Muda para o modo IRQ
    ldr sp, =IRQ_SP           @ Ajustar a pilha do modo IRQ.

    msr CPSR_c, #0b00010011   @ Retorna ao SUPERVISOR
    ldr sp, =SUPERVISOR_SP    @ Ajustar a pilha do modo SUPERVISOR

    bl SET_GPT                @ Configura o GPT
    bl SET_TZIC               @ Cofigura TZIC
    bl SET_GPIO               @ Configura o GPIO_GDIR

    msr CPSR_c, #0b00010000   @ Modo USER com interrupcoes ativas.
    ldr sp, =USER_SP          @ Inicializa a pilha do USER.
    ldr r0, =USER_CODE        @ Carrega USER_CODE em R0
    bx r0                     @ Salta para o USER_CODE

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_GPT:
    .set GPT_BASE, 		0x53FA0000
    .set GPT_CR,  		0x0000
    .set GPT_PR,	   	0x0004
    .set GPT_SR,		0x0008
    .set GPT_IR,		0x000C
    .set GPT_OCR1,		0x0010
    .set TIME_SZ,       100

    ldr r0, =GPT_BASE

    mov r1, #0x00000041
    str r1, [r0, #GPT_CR]	      @ Configura o modo clock_src para perifericos
				                        @ e seta o EN bit para ativar o gpt.
    mov r1, #0
    str r1, [r0, #GPT_PR]	      @ Seta o divisor do relogio como PR+1 = 1

    mov r1, #TIME_SZ
    str r1, [r0, #GPT_OCR1]     @ Define o valor que dispara um evento no output channel 1

    mov r1, #1
    str r1, [r0, #GPT_IR]	      @ Seta o IR para lancar interrupcao de acordo com o OCR1

    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_TZIC:
    @ Constantes para os enderecos do TZIC
    .set TZIC_BASE,             0x0FFFC000
    .set TZIC_INTCTRL,          0x0000
    .set TZIC_INTSEC1,          0x0084
    .set TZIC_ENSET1,           0x0104
    .set TZIC_PRIOMASK,         0x000C
    .set TZIC_PRIORITY9,        0x0424

    @ Liga o controlador de interrupcoes
    @ R1 <= TZIC_BASE
    ldr	r1, =TZIC_BASE

    @ Configura interrupcao 39 do GPT como nao segura
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupcao 39 (GPT)
    @ reg1 bit 7 (gpt)
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3
    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    @ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

    @ Habilita o controlador de interrupcoes
    mov	r0, #1
    str	r0, [r1, #TZIC_INTCTRL]

    @instrucao msr - habilita interrupcoes
    msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled (THUMB disable)

    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_GPIO:
    .set GPIO_BASE,   0x53F84000
    .set GPIO_DR,     0x0
    .set GPIO_GDIR,   0x0004
    .set GPIO_PSR,    0x0008
    .set DOORS_MASK,  0xFFFC003E  @11111111111111000000000000111110

    ldr r1, =GPIO_BASE

    ldr r0, =DOORS_MASK
    str r0, [r1, #GPIO_GDIR]

    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

IRQ_HANDLER:
    push {r0-r12, lr}             @ Salva os reg compartilhados e o estado previo.

    ldr r0, =GPT_BASE
    mov r1, #1
    str r1, [r0, #GPT_SR]	        @ Sinaliza ao GPT que o processador identificou o interrupt do OC1

    @ incrementa SYSTEM_TIME
    ldr r0, =SYSTEM_TIME
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    @ incrementa USER_TIME.
    ldr r0, =USER_TIME
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    @ Verifica a flag caso ja estejam sendo tratadas as callbacks
    ldr r0, =IRQ_FLAG
    ldr r1, [r0]
    cmp r1, #1
    beq end_irq     @ Se a flag estiver setada, termina IRQ

    @ Seta a IRQ_FLAG para avisar outras IRQs que ja existe um IRQ tratando as callbacks
    mov r1, #1
    str r1, [r0]

    ldr r0, =USER_CPSR            @ Salva o PCSR caso haja um novo IRQ durante o tratamento das callbacks
    mrs r1, SPSR
    str r1, [r0]                  @ Guarda o CPSR do usuario iterropido em uma posicao reservada
    msr CPSR_c, #0b00010010       @ Reseta flag de interrupcao o modo IRQ a fim
                                  @ de evitar defasagem de tempo durante as callbacks

    mov r0, #0                    @ Indica que deve retornar em
    b search_alarm_callbacks
    alarm_first_return:
    b search_proximity_callbacks

continue_irq:
    ldr r0, =IRQ_FLAG
    mov r1, #0                    @ Terminando as callbacks, desabilita a IRQ_FLAG
    str r1, [r0]

    ldr r0, =USER_CPSR
    ldr r1, [r0]                  @ Recupera o PCSR do usuario caso tenha ocorrido
    msr SPSR, r1                  @ um IRQ dentro do IRQ que trata as callbacks

end_irq:
    pop {r0-r12, lr}            @ Recupera pilhas e endereco de retorno onde houve interrupcao.
    sub lr, lr, #4              @ Ajusta endereco de retorno
    movs pc, lr			            @ A FLAG "S" RECUPERA O SPSR NO CPSR (IMPORTANTE PARA MUDANCAS DE ESTADO)

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

search_proximity_callbacks:
    @ Carrega os parametros das proximity_callbacks definidas pelo usuario
    ldr r1, =SONAR_CALLBACKS              @ Carrega vetor com ID dos sonares
    ldr r2, =DISTANCE_CALLBACKS           @ Carrega distancia minima para ativar a callback
    ldr r3, =ADDRESS_CALLBACKS            @ Carrega endereco da funcao do usuario
    ldr r5, =POSITION_BITS_CALLBACKS      @ Carrega os bits de posicao das callbacks
    ldr r4, [r5]                          @ Salva em R3 os bits das posicoes
    ldr r6, =0xFFFFFFFF

    mov r12,  #1
    mov r12, r12, lsl #MAX_CALLBACKS      @ Itera pelas posições do vetores
    mov r12, r12, lsr #1                  @ Ajusta para posicao inicial do vetor

    mov r11, #0                           @ idexa as posicoes dos vetores

loop_bit_check_proximity:                 @ loop pelas posições do vetor
    and r9, r12, r4                       @ Isola bit da posicao ry
    cmp r9, #0                            @ Verifica se a posição está vazia
    beq next_position_callback            @ Se vazia, testa a callback

    @ Carrega parametros para a syscall read_sonar
    ldrb r0, [r1, r11]				    @ ID do sensor a ser verificado

    @ Realiza um jump "informal" para a read_sonar
    push {r1-r3}
    mov r7, #16
    svc 0x0
    pop {r1-r3}

    ldr r9, [r2, r11, lsl #2]			 @ Distancia minima necessaria
    cmp r0, r9                     @ Verifica distancia minima
    bhi next_position_callback     @ Se maior, retorna sem tratar callback

    @ Remove a callback do vetor de bits
    bic r4, r4, r12                @ Apaga bit da posicao com a callback tratada
    str r4, [r5]                   @ Atualiza o vetor de bits das posicoes

    @ recupera e sobrescreve endereco da callback chamada por seguranca
    ldr r0, [r3, r11, lsl #2]	     @ Endereco da funcao a ser chamada
    mov r7, #0x1c                  @ Caso chama uma callback apagada, vai para UNDEFINED_HANDLER
    str r7, [r3, r11, lsl #2]

    push {r1-r12}
    mov r1, #0
    msr CPSR_c, #0b00010000        @ Muda para o modo usuario
    b call_user_code               @ Se menor, executa a callback
    return_from_proximity_user_code:
    pop {r1-r12}

    mov r0, #1                     @ Sinaliza a posicao de retorno (alarm_second_return)
    b search_alarm_callbacks       @ Verifica os alarmes apos o tratamento de uma
    alarm_second_return:           @ callback para evitar defasagem de tempo com o
                                   @ esperado pelo alarme
next_position_callback:
    mov r12, r12, lsr #1           @ Shifta mask para proxima posicao
    add r11, r11, #1               @ Incrementa index dos vetores
    cmp r12, #0                    @ Confere se passou todas as posicoes
    beq end_proximity_search       @ Se passou as posições, termina
    b loop_bit_check_proximity     @ Senão, verifica proxima posicao

end_proximity_search:
    b continue_irq

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

search_alarm_callbacks:
    push {r0-r12}
    ldr r1, =TIME_ALARM                  @ Carrega vetor com ID dos sonares
    ldr r2, =ADDRESS_ALARM               @ Carrega distancia minima para ativar a callback
    ldr r3, =USER_TIME
    ldr r5, =POSITION_BITS_ALARM         @ Carrega os bits de posicao das callbacks
    ldr r4, [r5]                         @ Salva em R3 os bits das posicoes

    mov r12,  #1
    mov r12, r12, lsl #MAX_ALARMS        @ Itera pelas posições do vetores
    mov r12, r12, lsr #1                 @ Ajusta para posicao inicial do vetor

    mov r11, #0                          @ idexa as posicoes dos vetores

loop_bit_check_alarm:                    @ loop pelas posições do vetor
    and r9, r12, r4                      @ Isola bit da posicao r4
    cmp r9, #0                           @ Verifica se a posição está vazia
    beq next_position_alarm              @ Se vazia, testa a callback

    ldr r9, [r3]                         @ Carrega USER_TIME em R9
    ldr r0, [r1, r11, lsl #2]            @ Carrega tempo de disparo em R0
    cmp r9, r0                           @ Compara se R9 ja alcancou R0
    blo next_position_alarm              @ Se R9 ainda eh menor, nao dispara o alarme

    @ Remove a callback do vetor de bits
    bic r4, r4, r12                @ Apaga bit da posicao com a callback tratada
    str r4, [r5]                   @ Atualiza o vetor de bits das posicoes

    @ recupera e sobrescreve endereco da callback chamada por seguranca
    ldr r0, [r2, r11, lsl #2]	     @ Endereco da funcao a ser chamada
    mov r7, #0x1c                  @ Caso chama uma callback apagada, vai para UNDEFINED_HANDLER
    str r7, [r2, r11, lsl #2]

    push {r1-r12}
    mov r1, #1
    msr CPSR_c, #0b00010000        @ Muda para o modo usuario
    b call_user_code               @ Se menor, executa a callback
    return_from_alarm_user_code:
    pop {r1-r12}

next_position_alarm:
    mov r12, r12, lsr #1           @ Shifta mask para proxima posicao
    add r11, r11, #1               @ Incrementa index dos vetores
    cmp r12, #0                    @ Confere se passou todas as posicoes
    beq end_alarm_search           @ Se passou as posições, termina
    b loop_bit_check_alarm         @ Senão, verifica proxima posicao

end_alarm_search:
    pop {r0-r12}
    cmp r0, #0                      @ verifica se deve voltar para o primeiro retorno
    beq alarm_first_return
    cmp r0, #1                      @ verifica se deve voltar para o segundo retorno
    beq alarm_second_return

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
SUPERVISOR_HANDLER:
    cmp r7, #0                  @ Syscall especial para retornar ao modo IRQ apos uma callback
    beq return_from_callback
    cmp r7, #1                  @ Syscall especial para retornar ao modo IRQ apos uma callback
    beq return_from_alarm

    @ Salvar r4-r12 do usuario na pilha
    push {r4-r12, lr}

    @ Compares syscalls
    cmp r7, #16
    bleq read_sonar
    cmp r7, #17
    bleq register_proximity_callback
    cmp r7, #18
    bleq set_motor_speed
    cmp r7, #19
    bleq set_motors_speed
    cmp r7, #20
    bleq get_time
    cmp r7, #21
    bleq set_time
    cmp r7, #22
    bleq set_alarm  @@@ FALTA FAZER!!!

    pop {r4-r12, lr}
    movs pc, lr

read_sonar:
@ Parametros:
@ R0 = ID do sonar a ser lido.
@ Variaveis:
@ R4 = endereco base do GPIO
@ R5 = valor do GPIO_DR/GPIO_PSR
@ R6 = Mask com novos valores do GPIO_DR e TRIGGER
@ R7 = bit wise clear mask
@ R8 = Contador para o delay de 10ms
@ R9 = Limite para o contador
    cmp r0, #16
    movhs r0, #-1
    movhs pc, lr

    cmp r0, #0
    movlo r0, #-1
    movlo pc, lr

    mov r6, r0
    mov r6, r6, lsl #2    @ Desloca espaco para a FLAG e o TRIGGER
    orr r6, r6, #0b10     @ Seta o TRIGGER (mantem FLAG baixada)
    mov r7, #0b111111     @ Cria mask para limpar os bits de enrtrada do sonar
                          @ (Essa mask tambem zera a FLAG e o TRIGGER)

    ldr r4, =GPIO_BASE      @ Inicializa endereco base do PSR
    ldr r5, [r4, #GPIO_DR]  @ Recupera valor atual do DR
    bic r5, r5, r7          @ Limpa bits a serem escritos no DR
    orr r5, r5, r6          @ Carrega o novo valor pro sonar
    str r5, [r4, #GPIO_DR]  @ Atualiza o DR com o novo sonar
                            @ldr r10, =VET_TEST_1
                            @str r5, [r10]

    @ Atrasa o processador por ciclos suficientes para 10ms
    ldr r8, =1000

delay_trigger:
    sub r8, r8, #1
    cmp r8, #0
    bne delay_trigger

    ldr r5, [r4, #GPIO_DR]
    mov r7, #0b10           @ Muda a mask para desabilitar o TRIGGER
    bic r5, r5, r7          @ Abaixa o TRIGGER no DR
    str r5, [r4, #GPIO_DR]  @ Atualiza o DR com o TRIGGER desabilitado
                            @ldr r10, =VET_TEST_2
                            @str r5, [r10]

    @ Aguarda o leventamento da FLAG
    mov r7, #0b1            @ Muda a mask para isolar apenas o valor da flag.

delay_flag:
    ldr r5, [r4, #GPIO_DR]  @ Recupera valor atual do DR
    and r5, r5, r7          @ Maskeia apenas o bit[0] (FLAG)
    cmp r5, #1              @ Testa se a FLAG foi habilitada
    bne delay_flag

    ldr r5, [r4, #GPIO_PSR] @ Le o valor devolvido pelo sonar no PSR    @ Verifica a flag caso ja estejam sendo tratadas as callbacks

    ldr r7, =0xFFF
    mov r5, r5, lsr #6      @ Desloca para os bits de retorno do sonar
    and r5, r5, r7          @ Maskeia apenas os 12 bits do sonar

    mov r0, r5              @ Carrega o valor de retorno do sonar em R0

    mov pc, lr

register_proximity_callback:
@ R0 = sonar ID
@ R1 = limiar de distancia
@ R2 = CALLBACK
    ldr r10, =POSITION_BITS_CALLBACKS  @ Salva endereco do numero de CALLBACKS
    ldr r4, [r10]                      @ Carrega em R4 a quantia atual de CALLBACKs definidos

    @ Testa se o ID do sonar eh valido
    cmp r0, #16
    movhs r0, #-2
    movhs pc, lr

    cmp r0, #0
    movlo r0, #-2
    movlo pc, lr

    @ Ajuste da mask para o vetor de bits
    mov r12, #1
    mov r12, r12, lsl #MAX_CALLBACKS      @ Itera pelas posições do vetores
    mov r12, r12, lsr #1                  @ Ajusta para posicao inicial do vetor

    mov r11, #0                           @ idexa as posicoes dos vetores

loop_bit_write_proximity:                 @ loop pelas posições do vetor
    and r5, r12, r4                       @ Isola bit da posicao ry
    cmp r5, #0                            @ Verifica se a posição está vazia
    beq write_proximity_callback          @ Se vazia, adiciona a CALLBACK

    mov r12, r12, lsr #1                  @ Shifta mask para proxima posicao
    add r11, r11, #1                      @ Incrementa index dos vetores
    cmp r12, #0                           @ Confere se passou todas as posicoes
    moveq r0, #-1
    beq end_register_proximity_callback   @ Se passou as posições, termina
    b loop_bit_write_proximity            @ Senão itera para proxima posicao

write_proximity_callback:
    @ Armazena parametros da callback
    ldr r5, =SONAR_CALLBACKS
    strb r0, [r5, r11]
    ldr r5, =DISTANCE_CALLBACKS
    str r1, [r5, r11, lsl #2]
    ldr r5, =ADDRESS_CALLBACKS
    str r2, [r5, r11, lsl #2]

    orr r4, r4, r12          @ Seta bit da nova posicao ocupada
    str r4, [r10]            @ Atualiza os Bits de posicao

end_register_proximity_callback:
    mov pc, lr

set_motor_speed:
@ Parametros:
@ R0 = Motor a ser iniciado
@ R1 = Velocidade do motor.
@ Variavel:
@ R4 = endereco base do GPIO
@ R5 = valor atual do GPIO_DR
@ R6 = Mask com novos valores do GPIO_DR
@ R7 = bit wise clear mask para nao afetar outros valores do DR

  @ Testa validade dos parametros
      cmp r1, #0
      movlo r0, #-2
      movlo pc, lr

      cmp r1, #64
      movhs r0, #-2
      movhs pc, lr

      cmp r0, #0
      movlo r0, #-1
      movlo pc, lr

      cmp r0, #2
      movhs r0, #-1
      movhs pc, lr

      mov r6, r1            @ Move a a velocidade para a Mask
      mov r6, r6, lsl #1    @ Desloca espaco para o bit do motor

      @ Testa qual o motor a ser configurado
      mov r7, #0b1111111              @ carrega maks pra limpar as posicoes do DR
      cmp r0, #0
      moveq r6, r6, lsl #18           @ Desloca para posicao MOTOR0_WRITE do DR
      moveq r7, r7, lsl #18           @ Ajusta mask pra limpar os bits do motor0
      cmp r0, #1
      moveq r6, r6, lsl #25           @ Desloca para posicao MOTOR1_WRITE do DR
      moveq r7, r7, lsl #25           @ Ajusta mask para limpar os bits do motor1

      ldr r4, =GPIO_BASE
      ldr r5, [r4, #GPIO_DR] @ Carrega o valor atual de DR em r5
      bic r5, r5, r7         @ Limpa os vlaores dos bits do motor selecionado
      orr r5, r5, r6         @ carrega os novos valores do motor e no DR antigo
      str r5, [r4, #GPIO_DR] @ Registra os valores atualizados no DR do GPIO

      mov r0, #0            @ Zera R0 para sinalizar execucao normal.
      mov pc, lr

set_motors_speed:
@ Parametros:
@ R0 = velocidade do motor0
@ R1 = velocidade do motor1
@ Variaveis:
@ R4 = endereco base do GPIO
@ R5 = valor atual do GPIO_DR
@ R6 = Mask com novos valores do GPIO_DR
@ R7 = bit wise clear mask para nao afetar outros valores do DR

@ Testa validade dos parametros
      cmp r0, #0
      movlo r0, #-1
      movlo pc, lr

      cmp r0, #64
      movhs r0, #-1
      movhs pc, lr

      cmp r1, #0
      movlo r0, #-2
      movlo pc, lr

      cmp r1, #64
      movhs r0, #-2
      movhs pc, lr


@ Configura mask do DR para escrever nos motores
      @ Seta bits do motor1
      mov r6, r1
      mov r6, r6, lsl #1      @ Separa bit do MOTOR1_WRITE
      mov r6, r6, lsl #6      @ Fornece espaco para os bits do motor0 (valor: 6 bits)

      @ Seta bits do motor0
      add r6, r6, r0          @ Merge os bits do motor0 e 1 na mesma mask
      mov r6, r6, lsl #1      @ Separa bit do MOTOR0_WRITE
      mov r6, r6, lsl #18     @ Move os bits para a posicao adequada do DR

      @ Cria a mask para limpar os 14 bits dos motores
      mov r7, #0b1111111
      mov r7, r7, lsl #7
      add r7, r7, #0b1111111
      mov r7, r7, lsl #18

      ldr r4, =GPIO_BASE
      ldr r5, [r4, #GPIO_DR]  @ Carrega o estado atual do DR em r5
      bic r5, r5, r7          @ Limpa os bits relacionados aos motores 0 e 1
      orr r5, r5, r6          @ Carrega os novos valores para ambos motores no DR antigo
      str r5, [r4, #GPIO_DR]  @ Registra os valores de escrita no DR do GPIO

      mov r0, #0              @ Zera R0 para sinalizar execucao normal.
      mov pc, lr

get_time: @ ID = 20
      @ Parametros: nenhum
      @ Retorno: R0 = USER_TIME
      ldr r1, =USER_TIME
      ldr r0, [r1]
      mov pc, lr

set_time: @ ID = 21
      @ Parametros: R0 = tempo do sistema
      @ Retorno: nenhum
      ldr r4, =USER_TIME
      str r0, [r4]
      mov pc, lr

set_alarm:
@ R0 = callback
@ R1 = time
    @Checa se o tempo passado é valido.
    ldr r2, =USER_TIME
    ldr r3, [r2]
    cmp r1, r3
    movlo r0, #-2
    blo end_set_alarm

    ldr r10, =POSITION_BITS_ALARM      @ Salva endereco do numero de CALLBACKS
    ldr r4, [r10]                      @ Carrega em R4 a quantia atual de CALLBACKs definidos

    @ Ajuste da mask para o vetor de bits
    mov r12, #1
    mov r12, r12, lsl #MAX_ALARMS         @ Itera pelas posições do vetores
    mov r12, r12, lsr #1                  @ Ajusta para posicao inicial do vetor

    mov r11, #0                           @ idexa as posicoes dos vetores

loop_bit_write_alarm:                     @ loop pelas posições do vetor
    and r5, r12, r4                       @ Isola bit da posicao r4
    cmp r5, #0                            @ Verifica se a posição está vazia
    beq write_set_alarm                   @ Se vazia, adiciona a CALLBACK

    mov r12, r12, lsr #1                  @ Shifta mask para proxima posicao
    add r11, r11, #1                      @ Incrementa index dos vetores
    cmp r12, #0                           @ Confere se passou todas as posicoes
    moveq r0, #-1
    beq end_set_alarm                     @ Se passou as posições, termina
    b loop_bit_write_alarm                @ Senão itera para proxima posicao

write_set_alarm:
    @ Armazena parametros da callback
    ldr r5, =ADDRESS_ALARM
    str r0, [r5, r11, lsl #2]
    ldr r5, =TIME_ALARM
    str r1, [r5, r11, lsl #2]

    orr r4, r4, r12          @ Seta bit da nova posicao ocupada
    str r4, [r10]            @ Atualiza os Bits de posicao

end_set_alarm:
    mov pc, lr

return_from_callback:
      msr CPSR_c, #0b00010010                 @ Retorna ao modo IRQ
      b return_from_proximity_user_code       @ Pula para a posicao onde parou

return_from_alarm:
      msr CPSR_c, #0b00010010                 @ Retorna ao modo IRQ
      b return_from_alarm_user_code       @ Pula para a posicao onde parou

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

UNDEFINED_HANDLER:
      b UNDEFINED_HANDLER

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

call_user_code:
    push {r1}
    blx r0          @ Pula para o codigo de usuario passado como parametro
    pop {r1}

    mov r7, r1      @ Retorna ao SO com uma syscall especial
    svc 0x0
