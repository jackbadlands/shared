build: main.o
	cc -o nextip main.o

run: build
	./nextip

main.o: main.c

clean:
	-@ rm -f ./nextip main.o

distclean: clean
	-@ rm -f *~
	-@ rm -f *.o

