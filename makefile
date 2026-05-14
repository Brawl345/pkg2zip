ifeq ($(OS),Windows_NT)
  RM := del /q
  EXE := .exe
else
  EXE :=
endif

BIN=pkg2zip${EXE}

# Detect architecture
UNAME_M := $(shell uname -m 2>/dev/null || echo unknown)

# Base source files
BASE_SRC := $(filter-out %_x86.c,$(wildcard pkg2zip*.c)) miniz_tdef.c puff.c

# Add x86-specific files only on x86/x86_64 architectures
ifneq ($(filter i386 i686 x86_64,$(UNAME_M)),)
SRC := $(BASE_SRC) $(wildcard pkg2zip*_x86.c)
else
SRC := $(BASE_SRC)
endif

OBJ=${SRC:.c=.o}
DEP=${SRC:.c=.d}

CFLAGS=-std=c99 -pipe -fvisibility=hidden -Wall -Wextra -Werror -DNDEBUG -D_GNU_SOURCE -O2
LDFLAGS=-s

.PHONY: all clean

all: ${BIN}

clean:
	@${RM} ${BIN} ${OBJ} ${DEP}

${BIN}: ${OBJ}
	@echo [L] $@
	@${CC} ${LDFLAGS} -o $@ $^

# x86-specific compilation rules (only on x86/x86_64)
ifneq ($(filter i386 i686 x86_64,$(UNAME_M)),)
%aes_x86.o: %aes_x86.c
	@echo [C] $<
	@${CC} ${CFLAGS} -maes -mssse3 -MMD -c -o $@ $<

%crc32_x86.o: %crc32_x86.c
	@echo [C] $<
	@${CC} ${CFLAGS} -mpclmul -msse4 -MMD -c -o $@ $<
endif

%.o: %.c
	@echo [C] $<
	@${CC} ${CFLAGS} -MMD -c -o $@ $<

-include ${DEP}
