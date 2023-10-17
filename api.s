.section .data
    # Isso tem que estar na BSS (Mudar depois)
    brk_original: .quad 0
    brk_current:    .quad 0
    
.section .text
    # void setup_brk 
    setup_brk:
        pushq %rbp
        movq %rsp, %rbp
        
        # Busca BRK
        movq $0 , %rdi
        movq $12, %rax
        syscall

        # brk_original = brk_current = BRK
        movq %rax, brk_original
        movq brk_original, brk_current

        ret

    # void dismiss_brk()
    dismiss_brk:
        pushq %rbp
        movq %rsp, %rbp

        # reseta  brk_current
        movq brk_original, brk_current

        # Atualiza BRK
        movq brk_original, %rdi 
        movq $12, %rax
        syscall
        ret

    # void* memory_alloc(unsigned long int bytes)
    memory_alloc:
        pushq %rbp
        movq %rsp, %rbp

        # Verifica se brk <= posição atual da heap
        movq brk_original, %rbx
        cmpq %rbx, brk_current
        jle valid_position
            # Se sim, atualiza BRK = BRK + (Tamanho+16)
            addq %rdi, brk_current
            addq $16, brk_current
                # Cria registro  
                # FIM
            # Se não
            valid_position:
                # Verifica se o espaço esta livre
                    # Se sim, verifica tamanho
                        # Flag que está ocupado agora
                        # Verifica se espaço em sobra permite outro registro
                            # Sobra o suficiente
                                # Modifica o valor do tamanho do atual
                                # Cria o registro do proximo
                                # Tamanho = sobra - 16 (Foi calculado na verificação, da pra reusar)
                                # FIM
                            # Não sobra o suficiente 
                                # FIM 
                    # Se não vai para o proximo
                    # Repete

        ret

    # void memory free(void *pointer)
    memory_free:
        pushq %rbp
        movq %rsp, %rbp

        # POINTER - 16 = 0 
        
        movq $0, -16(%rdi), 
        ret