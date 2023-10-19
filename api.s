.section .bss
    .global brk_original
    .global brk_current

    .lcomm brk_original 8
    .lcomm brk_current 8
    
.section .text
    .global setup_brk
    .global dismiss_brk
    .global memory_alloc
    .global memory_free

    setup_brk:
        pushq %rbp
        movq %rsp, %rbp
        
        # Busca BRK
        movq $0 , %rdi
        movq $12, %rax
        syscall

        # brk_original = brk_current = BRK
        lea brk_original(%rip), %rcx
        movq %rax, (%rcx)
        movq %rax, 8(%rcx) 

        popq %rbp
        ret

    dismiss_brk:
        pushq %rbp
        movq %rsp, %rbp

        # reseta  brk_current
        lea brk_original(%rip), %rdi
        movq (%rdi), %rcx
        movq %rcx, 8(%rdi)

        # Atualiza BRK
        movq (%rdi), %rdi 
        movq $12, %rax
        syscall
        
        popq %rbp
        ret
/*
    memory_alloc:
        pushq %rbp
        movq %rsp, %rbp

        ###### bytes em %rdi

        # Posição inicial da heap
        movq brk_original, %rdx        ######## lea brk_original(%rip), %rdx

        # Verifica se brk <= posição atual da heap
        _loop:
        cmpq %rdx, brk_current
        jle _valid_position     ######## jl _valid_position
        # Se sim                                 ###### vai sempre cair nessa condição?
            # atualiza brk_current = brk_currentK + (bytes+16)
            addq $16, brk_current
            addq %rdi, brk_current

            # Salva valor de bytes
            movq %rdi,%rcx 

            ##### %rcx guarda bytes

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
            # rdx aponta pro proximo          #### pro próximo o que?
            addq 8, %rdx           ####### addq $8, %rdx
            addq (%rdx), %rdx     ### que porra é essa
            
            # Repete
            jmp _loop

        # Se está livre
        _livre:

        # Verifica tamanho
            cmp 8(%rdx), %rdi
            jl _insuficiente     ###### jge _insuficiente
            # Se tamanho é suficiente
                # Flag que está ocupado agora
                movq $1, (%rdx)

                # Calcula quanto espaço esta sobrando - 16 - bytes
                movq 8(%rdx), %rcx
                subq %rdi, %rcx
                subq $16, %rcx

                # Verifica se espaço em sobra permite outro registro
                cmp $0, %rcx
                jle _no_space      ########  jl _no_space
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
                        subq 16, %rdx                  ##### subq $16, %rdx
                        subq %rdi, %rdx
                        
                    _no_space:
                    jmp _end
            # Se tamanho não é suficiente
            _insuficiente:

                # rdx aponta pro proximo      #### pro próximo o que?
                addq 8, %rdx          #### addq $8, %rdx
                addq (%rdx), %rdx
            
                # Repete
                jmp _loop

        _end;
        # Retorna posição da area alocada (%rdx +16)
        addq $16, %rdx
        movq %rdx, %rax
        
        popq %rbp
        ret

    memory_free:
        pushq %rbp
        movq %rsp, %rbp

        # pointer[-16] = 0 
        movq $0, -16(%rdi), brk_current
        popq %rbp
        ret
*/