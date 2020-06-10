main: main.o
	cc -o main main.o -lm

run: main
	./main 3 8 0.00001

main.o: main.c

clean:
	-@ rm -f main main.o

distclean: clean
	-@ rm -f *~

