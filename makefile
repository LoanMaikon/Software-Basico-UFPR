GCC=gcc
AS=as
LD=ld
LFLAG=-g 

all: teste2 teste

teste2:  teste2.c api.o
	$(GCC) teste2.c api.o -o teste2

teste:  teste.c api.o
	$(GCC)  teste.c api.o -o teste

api.o: api.s
	$(AS) api.s -o api.o


clean: 
	rm -f *.o

purge: clean 
	rm -f  teste2