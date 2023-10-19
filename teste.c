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
    printf("\n\n######### %s #########\n",str);
}

void msg(char *str){
    printf("!! %s \n",str);
}

void teste_setup_brk(){
    header("Testando setup_brk");
    msg("Globais :: ");
    show_global();
    msg("setup_brk()");
    setup_brk();
    msg("Globais :: ");
    show_global();
}

void teste_dismiss_brk(int valor_manual){
    header("Testando dismiss_brk");
    if (valor_manual){
        msg("Modificando brk_current manualmente");
        brk_current += valor_manual;
    }
    show_global();
    msg("dismiss_brk()");
    dismiss_brk();
    show_global();
}

void teste_memory_alloc(){
    char *str_0, *str_1, *str_2, *str_3,*str_4;
    header("Inserindo primeiro elemento na heap");
    msg("Inserindo registro");
    str_0 = memory_alloc( 5 * sizeof(char));
    str_0[0] = 'T';
    str_0[1] = 'A';
    str_0[2] = 'T';
    str_0[3] = 'U';
    str_0[4] = '\0';
    printf("%s\n",str_0);

    header("Inserindo segundo elemento na heap");
    /* Teste avanço na heap com vericação de _livre falso*/
    str_1 = memory_alloc( 3 * sizeof(char));
    str_1[0] = 'O';
    str_1[1] = 'L';
    str_1[2] = 'A';
    str_1[3] = '\0';
    printf("%s\n",str_1);
    show_global();

    header("Teste de reaproveitamento de memoria, sem novo registro");
    msg("Inserindo elemento");
    str_2 = memory_alloc( 40 * sizeof(char));
    show_global();
    printf("!! str_2 alocado na posição : %p\n", str_2);
    //msg("memory_free()");
    //memory_free(str_2);
    str_2 = memory_alloc( 40 * sizeof(char));
    printf("!! realocação de str_2: %p\n", str_2);
    show_global();

    header("Teste de reaproveitamento de memoria, com novo registro");
    msg("Desalocando str_2");
    memory_free(str_2);
    msg("Alocando duas posições dentro da antiga de str_2");
    str_3 = memory_alloc( 10 * sizeof(char));
    str_4 = memory_alloc( 14 * sizeof(char));
    printf("!! posição str_3  : %p\n", str_3);
    printf("!! posição str_4  : %p\n", str_4);


}

void rapid_memory_alloc(){
    char *str_0;
    str_0 = memory_alloc( 40 * sizeof(char));
    printf("!! Alocado em : %p\n", str_0);
    show_global();
    str_0 = memory_alloc( 40 * sizeof(char));
    printf("!! Alocado em : %p\n", str_0);
    
    str_0 = memory_alloc( 40 * sizeof(char));
    printf("!! Alocado em : %p\n", str_0);
    
    str_0 = memory_alloc( 40 * sizeof(char));
    printf("!! Alocado em : %p\n", str_0);
   
    str_0 = memory_alloc( 40 * sizeof(char));
    printf("!! Alocado em : %p\n", str_0);
   
    str_0 = memory_alloc( 40 * sizeof(char));
    printf("!! Alocado em : %p\n", str_0);

}

int main(){
    teste_setup_brk();

    //teste_memory_alloc();
    rapid_memory_alloc();
    teste_dismiss_brk(0);

    return 0;
}