TARGET := asmerver
BUILD := build

NASM_FLAGS := -f elf64 -I src/

# Default build is release (top most at the file)
release: $(BUILD)
	nasm $(NASM_FLAGS) src/main.asm -o $(BUILD)/main.o
	ld $(BUILD)/main.o -o $(TARGET)
	strip -s $(TARGET)

debug: $(BUILD)
	nasm -gdwarf $(NASM_FLAGS) src/main.asm -o $(BUILD)/main.o
	ld $(BUILD)/main.o -o $(TARGET)

$(BUILD):
	mkdir $(BUILD)

clean:
	rm -rf $(BUILD)

.PHONY: release debug clean
