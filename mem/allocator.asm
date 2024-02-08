; https://arjunsreedharan.org/post/148675821737/memory-allocators-101-write-a-simple-memory
; header block
; [is_free: 1 byte ]
; [size   : 8 bytes]
; [next   : 8 bytes]
; [data   : n bytes]

; 0 1:2:3:4:5:6:7:8 9:10:11:12:13:14:15:16 17
section .data

; head and tail of free list
mem_head dq 0
mem_tail dq 0

section .text

; block header constants
HEADER_IS_FREE_OFFSET equ 0
HEADER_SIZE_OFFSET equ 1
HEADER_NEXT_OFFSET equ 9
HEADER_DATA_OFFSET equ 17

extern SYSCALL_BRK
extern SYSCALL_EXIT

extern FAIL_MEM

global asm_malloc
global asm_free
global asm_calloc
global asm_realloc

; rdi: amount of memory to be allocated
asm_malloc:
	enter 0, 0

	; ensure amount of memory requested is > 0
	cmp rdi, 0
	jle asm_malloc_done

	call get_free_block

	invalid_asm_malloc:
		mov rax, 0
	asm_malloc_done:
		leave
		ret

; rdi: pointer address returned from previous asm_malloc
asm_free:
	enter 0, 0

	leave
	ret

; returns  the first free block or 0 if none are available
get_free_block:
	enter 0, 0

	; represents the current header
	mov rdi, mem_head

	get_free_block_loop:
		; check if next is null
		cmp rdi, 0
		je get_free_block_done

		; get next header
		mov rdi, [rdi + HEADER_NEXT_OFFSET]
		jmp get_free_block_loop

	get_free_block_done:
		mov rax, rdi
		leave
		ret

; rdi: block size requested
create_block_header:
	enter 0, 0

	leave
	ret

fail:
	mov rax, SYSCALL_EXIT 
	mov rdi, FAIL_MEM
	syscall