; Author: Noah Lewis 02/03/2024
; Email: nlewi26@lsu.edu
; Sys Call Table: https://filippo.io/linux-syscall-table/
; System V Calling Conventions: https://wiki.osdev.org/System_V_ABI

bits 64

section .data
  ; str constants
  STR_TERM equ 0
  STR_NEW_LINE equ 0xA

  ; input output constants
  STD_OUT equ 1 

  ; syscalls constants
  SYS_READ equ 0 
  SYS_WRITE equ 1 
  SYS_EXIT equ 60

  init_message_prompt db "Welcome to comm_asm!!!", STR_NEW_LINE, STR_TERM
  init_message_prompt_length equ $ - init_message_prompt

  debug_message db "debug message!", STR_NEW_LINE, STR_TERM
  debug_message_length equ $ - debug_message

section .bss
  char_buffer resb 1

section .text
  global _start 

_start:
  mov rdi, init_message_prompt
  mov rsi, init_message_prompt_length
  call print_plain_str
  
  call print_debug

  mov rdi, 300
  call print_unsigned_int

  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall

print_debug:
  enter 0, 0

  mov rdi, debug_message
  call print_str 

  leave
  ret


; print plain str to stdout
; rdi: STR_TERM terminated str pointer
; rsi: str length
print_plain_str:
  enter 0, 0

  ; str length 
  mov rcx, rsi 
  ; str pointer
  mov r8, rdi

  mov rax, SYS_WRITE
  mov rdi, STD_OUT
  mov rsi, r8
  mov rdx, rcx
  syscall

  leave
  ret

; prints unsigned int to stdout
; rdi: int to be printed
; TODO: need to validate the number
print_unsigned_int:
  enter 0, 0
  
  ; checking whether the number is zero
  test rdi, rdi 
  je print_int_zero_done 

  ; loading number to dividend
  mov rax, rdi
  mov r8, 10

  next_digit:
    div r8 
    
    ; save registers to print digit
    push rax
    push rdi
    push rsi
    push rdx

    ; print character
    add dl, '0' 
    mov byte [char_buffer], dl 

    ; restore registeres from printing digit
    pop rdx
    pop rsi
    pop rdi
    pop rax
     
    test rax, rax
    jne next_digit
    jmp print_int_done
    
  
  print_int_zero_done:
    mov byte [char_buffer], '0'
    mov rax, SYS_WRITE
    mov rdi, STD_OUT
    mov rsi, char_buffer
    mov rdx, 1
    syscall

  print_int_done:
    leave
    ret

; prints to stdout
; rdi: STR_TERM terminated str pointer
print_str:
  enter 0, 0

  ; counter
  xor r8, r8
  
  ; iterate through str
  not_str_term:
    xor r9, r9
    add r9, r8
    add r9, rdi
    mov rsi, r9 
    lodsb

    cmp al, STR_TERM 
    je print_str_done 

    ; mov character into buffer
    mov [char_buffer], al

    ; save regisers used in syscall
    push rax
    push rdi
    push rsi
    push rdx

    ; we have a character to print
    mov rax, SYS_WRITE
    mov rdi, STD_OUT
    mov rsi, char_buffer
    mov rdx, 1 
    syscall

    ; restoring restisters used in syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    inc r8
    jmp not_str_term

  print_str_done:
    leave
    ret
