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
HEADER_FREE_OFFSET equ 0
HEADER_SIZE_OFFSET equ 1
HEADER_NEXT_OFFSET equ 9
HEADER_DATA_OFFSET equ 17

HEADER_IS_FREE equ 0
HEADER_IS_NOT_FREE equ 1

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

	; find if the next viable free block
	push rdi
	call get_free_block
	pop rdi

	; check if there was a viable free block
	cmp rax, 0
	je extend_heap

	; there was a valid free block
	mov byte [rax + HEADER_FREE_OFFSET], HEADER_IS_NOT_FREE
	jmp asm_malloc_done

	extend_heap:
		; calc total block size
		mov rsi, rdi
		add rsi, HEADER_DATA_OFFSET

		; extend heap by block size 
		push rdi
		; get location of current heap
		mov rax, SYSCALL_BRK
		xor rdi, rdi
		syscall
		; check the status of sys call
		cmp rax, -1
		je fail
		; save current heap location
		mov rdx, rax
		; resize heap
		mov rax, SYSCALL_BRK
		mov rdi, rdx
		add rdi, rsi
		syscall
		; check the status of sys call
		cmp rax, -1
		je fail
		pop rdi

		; mov current heap location
		mov rax, rdx

		; initializing block
		mov byte [rax + HEADER_FREE_OFFSET], HEADER_IS_NOT_FREE
		mov [rax + HEADER_SIZE_OFFSET], rdi
		mov qword [rax + HEADER_NEXT_OFFSET], 0

		; adjusting linked list pointers
		cmp qword [mem_head], 0
		jne check_tail

		; the head is not set
		; set head to current block
		mov [mem_head], rax

	check_tail:
		; check if tail is set
		mov rdx, [mem_tail]
		cmp rdx, 0
		je set_tail

		; set the last block to the new last block
		mov rdx, [mem_tail]
		mov [rdx + HEADER_NEXT_OFFSET], rax

	set_tail:
		mov [mem_tail], rax

	list_finished:
		add rax, HEADER_DATA_OFFSET 
		jmp asm_malloc_done

	invalid_asm_malloc:
		mov rax, 0
	asm_malloc_done:
		leave
		ret

; rdi: pointer address returned from previous asm_malloc
asm_free:
	enter 0, 0

	; ensure pointer is > 0
	cmp rdi, 0
	jle asm_free_done
	; get location of heap
	push rdi
	mov rax, SYSCALL_BRK
	xor rdi, rdi
	syscall
	; check the status of sys call
	cmp rax, -1
	je fail
	pop rdi

	; get header of block
	mov rsi, rdi
	sub rsi, HEADER_DATA_OFFSET

	; get end location of last block
	; add offset of data in block
	mov rdx, rdi
	; add offset of block header
	add rdx, HEADER_DATA_OFFSET


	; at this point 
	; rax: pointer to current heap location
	; rdi: pointer to allocated memory
	; rsi: pointer to header block
	; rdx: pointer to end block

	; check if block is tail
	cmp rdx, rax
	je tail_block

	; setting block to be not free
	mov byte [rsi + HEADER_FREE_OFFSET], HEADER_IS_NOT_FREE
	leave 
	ret

	tail_block:
		; check if this the last block
		mov r9, [mem_tail]
		cmp [mem_head], r9
		je reduce_heap_size

	; more than one block in block list
	; reset tail to block before hours
	find_block_before:
		mov r9, [mem_head]
		add r9, HEADER_NEXT_OFFSET
		mov rdx, [r9]
		cmp rdx, [mem_tail]

		; r9 is the block before the tail

		je is_tail_block
		jmp find_block_before

	is_tail_block:
		; null the next for the block before the last
		mov qword [r9 + HEADER_NEXT_OFFSET], 0
		; set tail equal to new last
		mov [mem_tail], r9

	reduce_heap_size:
		mov rax, SYSCALL_BRK
		mov rdi, rax
		sub rdi, HEADER_DATA_OFFSET
		sub rdi, [rsi + HEADER_SIZE_OFFSET]
		here:
		syscall
		; check the status of sys call
		cmp rax, -1
		je fail

	asm_free_done:
		leave
		ret

; rdi: size of allocation
; returns  the first free block or 0 if none are available
get_free_block:
	enter 0, 0

	; setting default return value
	xor rax, rax
	; represents the size of the allocation
	mov rsi, rdi
	; represents the current header
	mov rdi, [mem_head]

	get_free_block_loop:
		; check if next is null
		cmp rdi, 0
		je get_free_block_done

		; check if block is free
		mov rdx, [rdi + HEADER_FREE_OFFSET]
		cmp rdx, HEADER_IS_FREE
		jne next_block

		; check if block is large enough
		mov rcx, [rdi + HEADER_SIZE_OFFSET]
		cmp rsi, rcx
		jl next_block

		; block is free and large enough set return value
		mov rax, rdi
		jmp get_free_block_done

	next_block:
		mov rdi, [rdi + HEADER_NEXT_OFFSET]
		jmp get_free_block_loop

	get_free_block_done:
		leave
		ret

fail:
	mov rax, SYSCALL_EXIT 
	mov rdi, FAIL_MEM
	syscall