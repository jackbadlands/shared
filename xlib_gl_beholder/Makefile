ALLAPPMODULES = sdl_main.o pmalloc.o

build: $(ALLAPPMODULES)
	cc -o main $(ALLAPPMODULES) -lSDL -lGL -lGLU -lm

run: build
	./main

sdl_main.o: sdl_main.c pmalloc.h

clean:
	-@ rm -f ./main
	-@ rm -f ./main.exe
	-@ rm -f *.o
	-@ rm -f *~

