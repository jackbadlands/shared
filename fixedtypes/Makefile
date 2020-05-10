build: main.o
	cc -o fixedtypes main.o

run: build
	./fixedtypes

main.o: main.c

clean:
	-@ rm -f ./fixedtypes main.o

distclean: clean
	-@ rm -f fixedsizetypes.h
	-@ rm -f *~
	-@ rm -f *.o

