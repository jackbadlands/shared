LIBS= -lm 

main: main.o
	cc -o main main.o $(LIBS)

run: main
	./main -c

main.o: main.c

clean:
	-@ rm -f main main.o

distclean: clean
	-@ rm -f *~

