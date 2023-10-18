#include <stdio.h>

extern void* brk_original;
extern void* brk_current;

/* Funções Assembly */
void* setup_brk();
void dismiss_brk();
void* memory_alloc(unsigned long int bytes);
void memory_free(void *pointer);

/* Funções de apresentação  */
void show_global(){
    printf("%p\n",brk_current);
    printf("%p\n",brk_original);
}

void header(char *str){
    printf("## %s \n",str);
}

void msg(char *str){
    printf("!! %s \n",str);
}

int main(){
    // setup 
    header("Globais :: ");
    show_global();
    msg("setup_brk()");
    setup_brk();
    header("Globais :: ");
    show_global();

    msg("Modificando brk_current manualmente");
    brk_current += 20;
    show_global();
    msg("dismiss_brk()");
    dismiss_brk();
    show_global();


    return 0;
}