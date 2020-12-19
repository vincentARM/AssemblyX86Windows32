# Makefile

# The directory in which source files are stored.
SOURCE = src

# The name of the output file to generate.
#TARGET = nompgm


# The intermediate directory for compiled object files.
BUILD = build

# The names of all object files that must be generated. Deduced from the 
# assembly code files in source.
OBJECTS = $(patsubst $(SOURCE)/%.asm,$(BUILD)/%.obj,$(wildcard $(SOURCE)/*.asm))

# Rule to make everything.
all: $(TARGET)


 
# Rule to make the exe file.
$(TARGET):  $(OBJECTS)
	D:\Logiciels\Golink\GoLink.exe   /fo $(BUILD)/$(TARGET) $(OBJECTS) /console Kernel32.dll User32.dll Gdi32.dll Comdlg32.dll Shell32.dll OleAut32.dll /entry:Main 

# Rule to make the object files.
$(BUILD)/%.obj: $(SOURCE)/%.asm
	D:\Logiciels\NASM\nasm.exe -f win32 $< -o $@   