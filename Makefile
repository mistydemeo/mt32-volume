CC := clang
RM := rm

mt32-volume: main.m
	$(CC) main.m -framework CoreMIDI -framework CoreServices -framework Foundation -o $@

.PHONY: all clean

all: mt32-volume

clean:
	$(RM) -f mt32-volume
