.globl _start


.text

mov r4, #69

laco:
mov r7, #21
mov r0, r4
svc 0x0

laco2:
  mov r7, #20
  svc 0x0
  cmp r0, r4
  beq laco2

  mov r4, r0
b laco
