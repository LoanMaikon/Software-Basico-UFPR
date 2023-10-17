.section .data
    # Isso tem que estar na BSS (Mudar depois)
    brk_original: .quad 0
    brk_current:  .quad 0
    
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

        popq %rbp
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
        
        popq %rbp
        ret


    # void* memory_alloc(unsigned long int bytes)
    memory_alloc:
        pushq %rbp
        movq %rsp, %rbp

        # Posição inicial da heap
        movq brk_original, %rdx

        # Verifica se brk <= posição atual da heap
        _loop:
        cmpq %rdx, brk_current
        jle _valid_position
        # Se sim
            # atualiza brk_current = brk_currentK + (bytes+16)
            addq $16, brk_current
            addq %rdi, brk_current

            # Salva valor de bytes
            movq %rdi,%rcx 

            # Atualiza o BRK
            movq brk_current, %rdi 
            movq $12, %rax
            syscall

            # Cria registro  
            movq $1, (%rdx)
            movq %rcx, 8(%rdx)
  
            # FIM
            jmp _end

        # Se não
        _valid_position:
        # Verifica se o espaço esta livre
        cmpq $0, (%rdx)
        je _livre
        # Se não está livre
            # rdx aponta pro proximo
            addq 8, %rdx
            addq (%rdx), %rdx
            
            # Repete
            jmp _loop

        # Se está livre
        _livre:

        # Verifica tamanho
            cmp 8(%rdx), %rdi
            jl _insuficiente
            # Se tamanho é suficiente
                # Flag que está ocupado agora
                movq $1, (%rdx)

                # Calcula quando espaço esta sobrando - 16
                movq 8(%rdx), %rcx
                subq %rdi, %rcx
                subq $16, %rcx

                # Verifica se espaço em sobra permite outro registro
                cmp $0, %rcx
                jle _no_space
                    # Se sobra o suficiente

                        # Modifica o valor do tamanho do atual
                        movq %rdi, 8(%rdx)
                    
                        # Move rdx para o novo registro
                        addq $16 ,%rdx
                        addq %rdi ,%rdx

                        # Cria o registro do proximo
                        movq $0, (%rdx)
                        movq %rcx, 8(%rdx)

                        # Volta para o registro alocado
                        subq 16, %rdx
                        subq %rdi, %rdx
                        
                    _no_space:
                    jmp _end
            # Se tamanho não é suficiente
            _insuficiente:

                # rdx aponta pro proximo
                addq 8, %rdx
                addq (%rdx), %rdx
            
                # Repete
                jmp _loop

        _end;
        # Retorna posição da area alocada (%rdx +16)
        addq $16, %rdx
        movq %rdx, %rax
        
        popq %rbp
        ret

    # void memory free(void *pointer)
    memory_free:
        pushq %rbp
        movq %rsp, %rbp

        # pointer[-16] = 0 
        movq $0, -16(%rdi), 

        popq %rbp
        ret