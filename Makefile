CC := clang
RM := rm

main: main.m
	$(CC) main.m -framework CoreMIDI -framework CoreServices -framework Foundation -o main

.PHONY: all clean

all: main

clean:
	$(RM) -f main
