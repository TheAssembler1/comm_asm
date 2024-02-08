SRC = entry mem/allocator const/syscall const/fail
OBJECT = entry.o mem/allocator.o const/syscall.o const/fail.o
OUTPUT = comm_asm
ASM = nasm
LINKER = gcc
FILE_OBJECT_TYPE = -felf64

$(info SRC: $(SRC))
$(info OBJECT: $(OBJECT))
$(info OUTPUT: $(OUTPUT))
$(info ASM: $(ASM))
$(info LINKER: $(LINKER))
$(info FILE_OBJECT_TYPE: $(FILE_OBJECT_TYPE))

all: $(OUTPUT)

$(OUTPUT): $(OBJECT)
	$(LINKER) -o $(OUTPUT) $(OBJECT) -no-pie

%.o: %.asm
	$(ASM) -g $(FILE_OBJECT_TYPE) $< -o $@

clean:
	rm -f -f $(OBJECT) $(OUTPUT)
