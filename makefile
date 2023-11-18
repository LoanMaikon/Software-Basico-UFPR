GCC=gcc
AS=as
LD=ld
LFLAG=-g 
EXEC=teste2

all: $(EXEC)

$(EXEC):  $(EXEC).o api.o
	$(GCC)  $(EXEC).o api.o -o $(EXEC)

$(EXEC).o: $(EXEC).c 
	$(GCC) -c $(EXEC).c -o $(EXEC).o

api.o: api.s api.h
	$(AS) api.s -o api.o

clean: 
	rm -f *.o

purge: clean 
	rm -f  $(EXEC)