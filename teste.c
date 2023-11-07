#include <stdio.h>

/* Variavaeis do Assembly */
extern void* brk_original;
extern void* brk_current;

/* Funções Assembly */
void* get_brk();
void setup_brk();
void dismiss_brk();
void* memory_alloc(unsigned long int bytes);
int memory_free(void *pointer);

/* Funções de apresentação  */
void show_global(){
    printf("BRK_CURRENT  :: %p\n",brk_current);
    printf("BRK_ORIGINAL :: %p\n",brk_original);
    printf("BRK REAL     :: %p\n",get_brk());
}

void header(char *str){
    printf("\n\n######### %s #########\n",str);
}

void msg(char *str){
    printf("!! %s \n",str);
}

/* Funções de teste */
void teste_setup_brk(){
    header("Testando setup_brk");
    show_global();
    msg("setup_brk()");
    setup_brk();
    show_global();
}

void teste_memory_alloc(){
    char *str_0, *str_1, *str_2, *str_3,*str_4;
    
    /*
    header("Inserindo primeiro elemento na heap");
    msg("Inserindo registro");
    str_0 = memory_alloc( 5 * sizeof(char));
    str_0[0] = 'T';
    str_0[1] = 'A';
    str_0[2] = 'T';
    str_0[3] = 'U';
    str_0[4] = '\0';
    printf("%s\n",str_0);
    show_global();

    header("Inserindo segundo elemento na heap");
    str_1 = memory_alloc( 4 * sizeof(char));
    str_1[0] = 'O';
    str_1[1] = 'L';
    str_1[2] = 'A';
    str_1[3] = '\0';
    printf("%s\n",str_1);
    show_global();
    */

    header("Teste de reaproveitamento de memoria, sem novo registro");
    show_global();
    msg("Alocando e desalocando elementos");
    int *v;
    for(int i = 0; i < 100; i++){
        v = memory_alloc(sizeof(int)*5);
        memory_free(v);

    }

    show_global();

    header("Teste de reaproveitamento de memoria, com novo registro");
    msg("Alocando elemento");
    str_2 = memory_alloc(sizeof(char)*40);

    printf("!! Elemento na posição : %p\n", str_2);
    show_global();
    msg("memory_free()");
    memory_free(str_2);
    msg("Alocando dois elementos que cabem no espaço do anterior");
    /* memory_alloc anterior alocou 40, mais os 16 do registro temos 56 bytes na heap   */
    /* Aloca espaços de 10 e 14 mais os 2 registros de 16 -> 10+14+2*16=56 bytes na heap*/
    str_3 = memory_alloc( 10 * sizeof(char));
    str_4 = memory_alloc( 14 * sizeof(char));
    printf("!! Elemento 1 na posição : %p\n", str_3);
    printf("!! Elemento 2 na posição : %p\n", str_4);
    show_global();
}

void teste_memory_free(){
    header("Teste de liberação de memoria");
    msg("Alocando elemento");
    char *str = memory_alloc( 5 * sizeof(char));
    int flag_1 = (int)(str[-16]);
    printf("!! Flag de ocupação do elemento : %i\n",flag_1);
    msg("memory_free()");
    memory_free(str);
    int flag_2 = (int)(str[-16]);
    printf("!! Flag de ocupação do elemento : %i\n",flag_2);

    header("Teste de posição invalida");
    printf("!! Resposta de desalocação invalida: %i\n", memory_free(&brk_current) );
    printf("!! Resposta de desalocação invalida em posição MIN: %i\n", memory_free(brk_original+15) );
    printf("!! Resposta de desalocação invalida em posição MAX: %i\n", memory_free(brk_current) );
    printf("!! Resposta de desalocação valida em posição MAX: %i\n", memory_free(brk_current-1) );
    printf("!! Resposta de desalocação valida em posição MIN: %i\n", memory_free(brk_original+16) );


}



void teste_dismiss_brk(){
    header("Testando dismiss_brk");
    show_global();
    msg("dismiss_brk()");
    dismiss_brk();
    show_global();
}

int main(){
    teste_setup_brk();
    teste_memory_alloc();
    teste_memory_free();
    teste_dismiss_brk();
    return 0;
}