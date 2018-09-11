.globl _start

.text
proximity_callback_teste_loop:

  mov r7, #22
  ldr r0, =stop
  ldr r1, =1000
  svc 0x0

  mov r7, #19
  mov r0, #63
  mov r1, #63
  svc 0x0

  mov r7, #17
  mov r0, #3
  mov r1, #1000
  ldr r2, =end_motors
  svc 0x0

  @mov r7, #17
  @mov r0, #4
  @mov r1, #1000
  @ldr r2, =end_motors
  @svc 0x0

  second_loop:
    b second_loop

end_motors:
    mov r7, #16
    mov r0, #3
    svc 0x0
    mov r4, r0

    @mov r7, #16
    @mov r0, #4
    @svc 0x0
    @mov r5, r0

    cmp r4, r5
    bhs turn_left
    b turn_right

turn_left:
    mov r7, #19
    mov r0, #10
    mov r1, #0
    svc 0x0
    b continue_

turn_right:
    mov r7, #19
    mov r0, #0
    mov r1, #10
    svc 0x0
    b continue_

continue_:
    mov r8, #0

    mov r7, #16
    mov r0, #3
    svc 0x0
    mov r4, r0

    mov r7, #16
    mov r0, #4
    svc 0x0
    mov r5, r0

    cmp r5, #1200
    addhs r8, r8, #1

    cmp r4, #1200
    addhs r8, r8, #1

    cmp r8, #2
    bne continue_

    mov r7, #19
    mov r0, #63
    mov r1, #63
    svc 0x0

    @mov r7, #17s
    @mov r0, #3
    @mov r1, #1000
    @ldr r2, =end_motors
    @svc 0x0

    @mov r7, #17
    @mov r0, #4
    @mov r1, #1000
    @ldr r2, =end_motors
    @svc 0x0

    mov pc, lr

stop:
    mov r7, #19
    mov r0, #0
    mov r1, #0
    svc 0x0

    mov pc, lr




  @
  @mov r7, #17
  @mov r0, #0
  @mov r1, #1200
  @mov r2, #100
  @svc 0x0
  @
  @mov r0, #1
  @mov r1, #1201
  @mov r2, #101
  @svc 0x0
  @
  @mov r0, #2
  @mov r1, #1202
  @mov r2, #102
  @svc 0x0
  @
  @mov r0, #3
  @mov r1, #1203
  @mov r2, #103
  @svc 0x0
  @
  @mov r0, #4
  @mov r1, #1204
  @mov r2, #104
  @svc 0x0
  @
  @mov r0, #5
  @mov r1, #1205
  @mov r2, #105
  @svc 0x0
  @
  @mov r0, #6
  @mov r1, #1206
  @mov r2, #106
  @svc 0x0
  @
  @mov r0, #7
  @mov r1, #1207
  @mov r2, #107
  @svc 0x0
  @
