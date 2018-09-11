.org 0x0
.set USER_CODE,  0x77802000
.set USER_SP,    0x77804000
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
CONTADOR: .skip 8
@ Aloca espaco para pilha IRQ full-descendent
.skip 100
IRQ_SP:

IRQ_FILA: .skip 100

@ Aloca espaco para pilha SUPERVISOR full-descendent
.skip 100
SUPERVISOR_SP:

 @@@@@@@@ O .text JA NAO ATUALIZA O ENDERECO DE ESCRITA? PORQUE O .org NESSE CASO?
.text
@@@@@@@@ CONFIGURAR LR A PRIMEIRA VEZ PARA GARANTIR QUE PULE PARA O CODIGO DO USUARIO?
@@@@@@@@ OU O RESET EH ACESSADO APENAS UMA VEZ POR EXECUCAO?

RESET_HANDLER:

    @ Zera o contador
    ldr r2, =CONTADOR  @lembre-se de declarar esse contador em uma secao de dados!
    mov r0, #0
    str r0, [r2]

    @Faz o registrador que aponta para a tabela de interrup��es apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    msr CPSR_c, #0b00010010   @ Muda para o modo IRQ
    ldr sp, =IRQ_SP           @ Ajustar a pilha do modo IRQ.
    msr CPSR_c, #0b00010011   @ Retorna ao SUPERVISOR

    bl SET_GPT                @ Configura o GPT
    bl SET_TZIC               @ Cofigura TZIC

    msr CPSR_c, #0b00010000   @ Modo USER com interrupcoes ativas.
    ldr sp, =USER_SP          @ Inicializa a pilha do USER.

    ldr r0, =USER_CODE        @ Carrega USER_CODE em R0
    bx r0                     @ Salta para o USER_CODE

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_GPT:
    .set GPT_BASE, 		0x53FA0000
    .set GPT_CR,  		0x0000
    .set GPT_PR,	   	0x0004
    .set GPT_SR,		  0x0008
    .set GPT_IR,		  0x000C
    .set GPT_OCR1,		0x0010
    .set TIME_SZ,     100

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

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

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
    sub lr, lr, #4		          @ Ajusta o endereco de retorno.
    push {r0-r12, lr}           @ Salva os reg compartilhados e o estado previo.
    msr CPSR_c, #0b00010010     @ Reseta flag de interrupcao mantendo o modo IRQ

    ldr r0, =GPT_BASE

    mov r1, #1
    str r1, [r0, #GPT_SR]	      @ Sinaliza ao GPT que o processador identificou o interrupt do OC1

    @ incrementa contador do relogio..org 0x100
    ldr r0, =CONTADOR
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    pop {r0-r12, lr}            @ Recupera pilhas.
    movs pc, lr			            @ A FLAG "S" RECUPERA O SPSR NO CPSR (IMPORTANTE PARA MUDANCAS DE ESTADO)

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SUPERVISOR_HANDLER:
  @ Salvar r4-r12 do usuario na pilha
  push {r4-r12}

  @ Compares syscalls
  cmp r7, #16
  beq read_sonar
  cmp r7, #17
  beq register_proximity_callback
  cmp r7, #18
  beq set_motor_speed
  cmp r7, #19
  beq set_motors_speed
  cmp r7, #20
  beq get_time
  cmp r7, #21
  beq set_time
  cmp r7, #22
  beq set_alarm

read_sonar:
register_proximity_callback:

set_motor_speed: @@@@@@@@@@@ NAO ESTA ANDANDO. DR?
@ Parametros:
@ R0 = Motor a ser iniciado
@ R1 = Velocidade do motor.
@ Variavel:
@ R4 = Mask do DR do GPIO

@ Testa validade dos parametros
    cmp r1, #0
    movlo r0, #-2
    blo end_syscall

    cmp r1, #64
    movhs r0, #-2
    bhs end_syscall

    cmp r0, #0
    movlo r0, #-1
    blo end_syscall

    cmp r0, #2
    movhs r0, #-1
    bhs end_syscall

    mov r4, r1            @ Move a a velocidade para a Mask
    mov r4, r4, lsl #1    @ Desloca espaco para o bit do motor

    @ Testa qual o motor a ser configurado
    cmp r0, #0
    moveq r4, r4, lsl #18   @ Desloca para posicao MOTOR0_WRITE do DR
    cmp r0, #1
    moveq r4, r4, lsl #25   @ Desloca para posicao MOTOR1_WRITE do DR

    ldr r0, =GPIO_BASE
    str r4, [r0, #GPIO_DR] @ Registra os valores de escrita no DR do GPIO
    @@@@@@@@@@@@@@@@@@@@@@@ EH SO ESCREVER NO DR E BOA?
    b end_syscall

set_motors_speed: @@@@@@@@@@@ NAO ESTA ANDANDO. DR?
@ Parametros:
@ R0 = velocidade do motor0
@ R1 = velocidade do motor1
@ Variaveis:
@ R4 = mask do DR do GPIO

@ Testa validade dos parametros
    cmp r0, #0
    movlo r0, #-1
    blo end_syscall

    cmp r0, #64
    movhs r0, #-1
    bhs end_syscall

    cmp r1, #0
    movlo r0, #-2
    blo end_syscall

    cmp r1, #64
    movhs r0, #-2
    bhs end_syscall


@ Configura mask do DR para escrever nos motores
    @ Seta bits do motor1
    mov r4, r1
    mov r4, r4, lsl #1      @ Separa bit do MOTOR1_WRITE
    mov r4, r4, lsl #6      @ Fornece espaco para os bits do motor0 (valor: 6 bits)

    @ Seta bits do motor0
    add r4, r4, r0          @ Merge os bits do motor0 e 1 na mesma mask
    mov r4, r4, lsl #1      @ Separa bit do MOTOR0_WRITE
    mov r4, r4, lsl #18     @ Move os bits para a posicao adequada do DR

    ldr r0, =GPIO_BASE
    str r4, [r0, #GPIO_DR]  @ Registra os valores de escrita no DR do GPIO

    b end_syscall

get_time: @ ID = 20
    @ Parametros: nenhum
    @ Retorno: R0 = CONTADOR
    ldr r1, =CONTADOR
    ldr r0, [r1]
    b end_syscall

set_time: @ ID = 21
    @ Parametros: R0 = tempo do sistema
    @ Retorno: nenhum
    ldr r4, =CONTADOR
    str r0, [r4]
    b end_syscall

set_alarm:

end_syscall:
    pop {r4-r12}
    movs pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

UNDEFINED_HANDLER:
      b UNDEFINED_HANDLER
