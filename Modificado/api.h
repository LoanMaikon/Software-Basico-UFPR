#ifndef MEM_API_H_
#define MEM_API_H_

/* Variavaeis do Assembly */
extern void* brk_original;
extern void* brk_current;

/* Funções Assembly */

void* get_brk();

void setup_brk();

void dismiss_brk();

void* memory_alloc(unsigned long int bytes);

int memory_free(void *pointer);


#endif
