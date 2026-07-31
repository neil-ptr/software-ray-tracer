SRCS := $(shell find . -name '*.odin')

run: build
	./bin/main

dev: build
	lldb -o run -o bt ./bin/main

build: $(SRCS) | bin
	odin build . -out:bin/main -debug

bin:
	mkdir -p bin


