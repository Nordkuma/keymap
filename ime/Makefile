CXX      = x86_64-w64-mingw32-g++
CXXFLAGS = -O2 -Wall -Wextra -std=c++17
LDFLAGS  = -luser32 -static-libgcc -static-libstdc++
SOURCE   = main.cc
BINARY   = ime.exe
PREFIX  ?= /usr/local/bin

.PHONY: all install uninstall clean

all: $(BINARY)

$(BINARY): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $(BINARY) $(SOURCE) $(LDFLAGS)

install: $(BINARY)
	sudo install -m 755 $(BINARY) $(PREFIX)/$(basename $(BINARY))
	@echo "Installed to $(PREFIX)/$(basename $(BINARY))"

uninstall:
	sudo rm -f $(PREFIX)/$(basename $(BINARY))
	@echo "Uninstalled $(PREFIX)/$(basename $(BINARY))"

clean:
	rm -f $(BINARY)
