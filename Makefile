SRC = entry
OUTPUT = comm_asm
ASM = nasm
LINKER = gcc
FILE_OBJECT_TYPE = -felf64

all: $(OUTPUT)

$(OUTPUT): $(addsuffix .o,$(SRC))
	$(LINKER) -o $(OUTPUT) $(addsuffix .o,$(SRC)) -no-pie

%.o: %.asm
	$(ASM) -g $(FILE_OBJECT_TYPE) $< -o $@

clean:
	rm -f -f $(addsuffix .o,$(SRC)) $(OUTPUT)


