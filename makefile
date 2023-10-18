GCC=gcc
AS=as
LD=ld
LFLAG=-g 

all: teste

teste:  teste.c api.s
	$(GCC)  teste.c api.s -o teste


clean: 
	rm -f *.o

purge: clean 
	rm -f  teste