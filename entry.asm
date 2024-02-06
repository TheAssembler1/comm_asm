bits 64

global main
extern malloc

section .text
main:
  call print_unsigned_int

  mov rax, 60 
  xor rdi, rdi
  syscall

print_unsigned_int:
  mov rdi, 10
  call malloc ; NOTE: seg faults here
  jz exit_failure

  ret

exit_failure:
  mov rax, 60 
  mov rdi, -1
  syscall
