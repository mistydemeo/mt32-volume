CC := clang
RM := rm

CFLAGS :=
UNAME_S := $(shell uname -s)

# If we're building under cargo-dist, we may be cross-compiling;
# check cargo-dist's CARGO_DIST_TARGET to find out what architecture
# we're meant to build for, and add Apple's architecture flags to the
# CFLAGS appropriately.
ifeq ($(UNAME_S), Darwin)
	ifneq (,$(findstring x86_64,$(CARGO_DIST_TARGET)))
		CFLAGS += -arch x86_64
	endif
	ifneq (,$(findstring aarch64,$(CARGO_DIST_TARGET)))
		CFLAGS += -arch arm64
	endif
endif

mt32-volume: main.m
	$(CC) main.m -framework CoreMIDI -framework CoreServices -framework Foundation $(CFLAGS) -o $@

.PHONY: all clean

all: mt32-volume

clean:
	$(RM) -f mt32-volume
