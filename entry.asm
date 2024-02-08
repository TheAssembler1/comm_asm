bits 64

global main

section .text

; external functions
extern malloc
extern free
extern printf

extern asm_malloc
extern asm_free

extern SYSCALL_EXIT

extern FAIL_ENTRY

extern asm_malloc

main:
  enter 0, 0

  call asm_malloc

  mov rax, SYSCALL_EXIT 
  xor rdi, rdi
  syscall

fail:
  mov rax, SYSCALL_EXIT 
  mov rdi, FAIL_ENTRY
  syscall
