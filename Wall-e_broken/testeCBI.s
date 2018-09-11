.globl _start

.data
.skip 4
COUNTER: .word 0

.text
  mov r7, #19
  mov r0, #63
  mov r1, #63
  svc 0x0

  mov r7, #17
  mov r0, #3
  mov r1, #1000
  ldr r2, =turn_
  svc 0x0

  mov r7, #17
  mov r0, #4
  mov r1, #1000
  ldr r2, =turn_
  svc 0x0

  mov r7, #22
  ldr r0, =alarm
  ldr r1, =5
  svc 0x0

  loop22_:
  b loop22_

  mov r7, #21
  mov r0, #0
  svc 0x0

alarm:
  mov r7, #19
  mov r0, #0
  mov r1, #63
  svc 0x0

  mov r7, #21
  ldr r0, =0
  svc 0x0

loop:
  mov r7, #20
  ldr r0, =COUNTER
  svc 0x0

  ldr r0, =COUNTER
  ldr r0, [r0]
  cmp r0, #300
  bne loop

  mov r7, #19
  mov r0, #63
  mov r1, #63
  svc 0x0

  mov r7, #21
  ldr r0, =0
  svc 0x0

  mov r7, #22
  ldr r0, =alarm
  ldr r1, =5
  svc 0x0

  mov pc, lr

turn_:
  mov pc, lr
