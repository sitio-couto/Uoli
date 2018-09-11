.globl _start

.text
proximity_callback_teste_loop:

  mov r7, #19
  mov r0, #63
  mov r1, #63
  svc 0x0

  mov r7, #22
  ldr r0, =end_motors
  ldr r1, =5000
  svc 0x0

  second_loop:
  mov r0, r0
    b second_loop

end_motors:
  mov r7, #19
  mov r0, #63
  mov r1, #0
  svc 0x0

  mov pc, lr
