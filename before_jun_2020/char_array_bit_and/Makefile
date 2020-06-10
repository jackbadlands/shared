build: main.o
	cc -o main main.o

run: build
	./main

main.o: main.c

clean:
	-@ rm -f ./main main.o

distclean: clean
	-@ rm -f *~
	-@ rm -f *.o

