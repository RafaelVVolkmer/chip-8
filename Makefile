CC ?= gcc
CFLAGS ?= -O2 -Wall -I./inc -std=c11
LDFLAGS ?=
SDL_LIBS ?= -lSDL2 -lSDL2_ttf

SRCDIR ?= src
OBJDIR ?= obj
BINDIR ?= bin
HDRDIR ?= inc

TARGET ?= $(BINDIR)/chip8

SRCS := $(wildcard $(SRCDIR)/*.c)
OBJS := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCS))

all: sdl

build: CFLAGS += -DHEADLESS
build: prepare clean_objs $(TARGET)

# OS-specific flags for SDL
ifeq ($(shell uname), Darwin)
    # macOS and Homebrew
    SDL_CFLAGS := -I$(shell brew --prefix)/include
    SDL_LDFLAGS := -L$(shell brew --prefix)/lib
else
    # Linux and sdl2-config
    SDL_CFLAGS := $(shell sdl2-config --cflags)
    SDL_LDFLAGS := $(shell sdl2-config --libs)
endif

sdl: CFLAGS += -DUSE_SDL $(SDL_CFLAGS)
sdl: LDFLAGS += $(SDL_LDFLAGS) $(SDL_LIBS)
sdl: prepare clean_objs $(TARGET)

prepare:
	@mkdir -p $(OBJDIR) $(BINDIR)

clean_objs:
	@rm -f $(OBJDIR)/*.o

format:
	@clang-format -i $(SRCDIR)/*.c $(HDRDIR)/*.h

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS)
	@echo "Linking $@..."
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	@rm -rf $(OBJDIR) $(BINDIR)

.PHONY: all build sdl clean prepare clean_objs format
