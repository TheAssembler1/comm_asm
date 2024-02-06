bits 64

global main

section .text

; FIXME: external functions
extern malloc
extern free

main:
  enter 0, 0
  
  mov rdi, 16
  call print_unsigned_int
  add rsp, 16

  mov rax, 60 
  xor rdi, rdi
  syscall

  leave
  ret

; rdi: unsigned in
print_unsigned_int:
  enter 0, 0
  
  ; allocate 10 char buffer
  mov r11, rdi
  mov rdi, 10
  call malloc

  ; store pointer to buffer
  mov r9, rax

  mov byte [r9 + 0], '-'
  mov byte [r9 + 1], '-'
  mov byte [r9 + 2], '-'
  mov byte [r9 + 3], '-'
  mov byte [r9 + 4], '-'
  mov byte [r9 + 5], '-'
  mov byte [r9 + 6], '-'
  mov byte [r9 + 7], '-'
  mov byte [r9 + 8], '-'
  mov byte [r9 + 9], '-'
  
  ; get modulus
  ; counter
  mov r8, 9 
  cont_store_dig:
    ; getting the modulus of number
    mov edx, 0 
    mov rax, r11 
    mov ecx, 10
    div ecx
    mov r11, rax 
   
    ; converting to asscci and storing digit
    add edx, '0'
    mov [r9 + r8], edx

    ; decrementing counter
    dec r8
  
    ; checking if there are more digits
    cmp r11, 0
    je print_digits 


  ; counter to print through buffer
  print_digits:
  mov r8, 0
  cont_print_dig:
    mov rax, 1
    mov rdi, 1
    mov r10, r9
    add r10, r8
    mov rsi, r10
    mov rdx, 1
    syscall

    inc r8

    cmp r8, 10
    jne cont_print_dig

  ; free 10 char buffer
  mov rdi, r9
  call free

  leave
  ret

exit_failure:
  mov rax, 60 
  mov rdi, -1
  syscall
