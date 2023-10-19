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

void teste_setup_brk(){
    header("Testando setup_brk");
    header("Globais :: ");
    show_global();
    msg("setup_brk()");
    setup_brk();
    header("Globais :: ");
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
    msg("Inserindo o primeiro registro");
    char *str[10];
    for (int i = 10; i < 20; i++) {
        str[i] = memory_alloc(i * sizeof(char));
        for (int j = 0; j < i - 1; j++){
            str[i][j] = 'a' + j;
        }
        str[i][i] = '\0';
    }
    msg("Imprimindo mensagem");
    for (int i = 0; i < 10; i++)
        printf("%s\n", str[i]);
        show_global();
}

int main(){
    teste_setup_brk();

    teste_memory_alloc();

    teste_dismiss_brk(0);

    return 0;
}