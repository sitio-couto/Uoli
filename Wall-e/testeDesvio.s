@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Codigo de exemplo para controle basico de um robo.
@ Este codigo le os valores de 2 sonares frontais para decidir se o
@ robo deve parar ou seguir em frente.
@ 2 syscalls serao utilizadas para controlar o robo:
@   write_motors  (syscall de numero 124)
@                 Parametros:
@                       r0 : velocidade para o motor 0  (valor de 6 bits)
@                       r1 : velocidade para o motor 1  (valor de 6 bits)
@
@  read_sonar (syscall de numero 125)
@                 Parametros:
@                       r0 : identificador do sonar   (valor de 4 bits)
@                 Retorno:
@                       r0 : distancia capturada pelo sonar consultado (valor de 12 bits)
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


.text
.align 4
.globl _start

_start:                         @ main

        mov r0, #0              @ Carrega em r0 a velocidade do motor 0.
                                @ Lembre-se: apenas os 6 bits menos significativos
                                @ serao utilizados.
        mov r1, #0              @ Carrega em r1 a velocidade do motor 1.
        mov r7, #19             @ Identifica a syscall 124 (write_motors).
        svc 0x0                 @ Faz a chamada da syscall.

        ldr r6, =1200           @ r6 <- 1200 (Limiar para parar o robo)

loop:
        mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
        mov r7, #16            @ Identifica a syscall 125 (read_sonar).
        svc 0x0
        mov r5, r0              @ Armazena o retorno do sensor esquerdo da syscall.

        mov r0, #4              @ Define em r0 o sonar.
        mov r7, #16
        svc 0x0
        mov r7, r0              @ Armazena o retorno do sensor direito em r7.

        mov r0, #10             @ Velocidade motor direito.
        mov r1, #0              @ Velocidade motor esquerdo.
        cmp r7, r5              @ Compara o retorno (em r7) com r5.
        blo min                 @ Se SD < SE: Salta pra min

        mov r0, #0             @ Velocidade motor direito.
        mov r1, #10              @ Velocidade motor esquerdo.
        mov r7, r5              @ Senao: r7 <- r5

min:
        cmp r7, r6              @ Compara r7 com r6
        blo turn                @ Se r7 menor que o limiar: Salta para turn

        @ Senao mantem a direcao.
        mov r0, #30
        mov r1, #30
        mov r7, #19
        svc 0x0

        b loop                  @ Refaz toda a logica

@ r0 = velocidade motor direito (0).
@ r1 = velocidade motor esquerdo (1).
turn:                            @ Parar o robo
        mov r7, #19
        svc 0x0

keep_turning:
        mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
        mov r7, #16             @ Identifica a syscall 125 (read_sonar).
        svc 0x0
        mov r5, r0              @ Armazena o retorno do sensor esquerdo da syscall.

        mov r0, #0              @ Define em r0 o sonar.
        mov r7, #16
        svc 0x0
        mov r7, r0              @ Armazena o retorno do sensor direito em r7.

        cmp r7, r5
        movhi r7, r5

        cmp r7, r6
        bhi loop

        b keep_turning

      @  mov r7, #1              @ syscall exit
      @  svc 0x0
