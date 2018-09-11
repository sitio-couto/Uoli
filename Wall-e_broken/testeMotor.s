.globl _start


.text


  mov r7, #18
  mov r0, #-1
  mov r1, #50
  svc 0x0

  mov r7, #18
  mov r0, #1
  mov r1, #0b1000000
  svc 0x0

  mov r7, #18
  mov r0, #2
  mov r1, #0
  svc 0x0

  mov r7, #18
  mov r0, #1
  mov r1, #-1
  svc 0x0

laco:
b laco
