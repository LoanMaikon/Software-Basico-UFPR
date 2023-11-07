GCC=gcc
AS=as
LD=ld
LFLAG=-g 

all: teste2

teste2:  teste2.c api.s
	$(GCC) -g teste2.c api.s -o teste2


clean: 
	rm -f *.o

purge: clean 
	rm -f  teste2