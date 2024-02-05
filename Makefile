SRC = entry.asm
OUTPUT = comm_asm
ASM = nasm
LINKER = ld
FILE_OBJECT_TYPE = elf64
FILE_OUTPUT_TYPE = elf_x86_64

all: $(OUTPUT)

$(OUTPUT): $(SRC)
	$(ASM) -f $(FILE_OBJECT_TYPE) -F dwarf -g -o $(OUTPUT).o $(SRC)
	gcc -nostartfiles -m64 -no-pie -g -o $(OUTPUT) $(OUTPUT).o

clean:
	rm -f $(OUTPUT).o $(OUTPUT)
