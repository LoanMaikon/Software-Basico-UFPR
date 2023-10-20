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
    .global get_brk
    
    # Função extra para retornar o brk
    get_brk:
        pushq %rbp
        movq %rsp, %rbp
        
        # Busca e Retorna BRK
        movq $0 , %rdi
        movq $12, %rax
        syscall

        popq %rbp
        ret

    setup_brk:
        pushq %rbp
        movq %rsp, %rbp
        
        # Busca BRK
        movq $0 , %rdi
        movq $12, %rax
        syscall

        # brk_original e brk_current recebem o valor de BRK
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

    memory_alloc:
        pushq %rbp
        movq %rsp, %rbp

        # Posição inicial da heap
        lea brk_original(%rip), %rcx
        movq (%rcx), %rdx

        # Verifica se brk > indice atual da heap (%rdx)
        _loop:
        cmpq %rdx, 8(%rcx)
        jg _before_brk

            # atualiza brk_current += (bytes+16)
            lea brk_current(%rip), %rax
            movq $16,  %rcx
            addq %rdi, %rcx
            addq %rcx, (%rax)

            # Salva valor de bytes
            pushq %rdi

            # Atualiza o BRK
            movq (%rax), %rdi
            movq $12, %rax
            syscall
            
            # Carrega o valor dos bytes 
            popq %rdi

            # Cria registro  
            movq $1, (%rdx)
            movq %rdi, 8(%rdx)
  
            jmp _end

        _before_brk:
        # Verifica se o espaço esta ocupado
        cmpq $0, (%rdx)
        jne _next_space
            
            # Mapeia tamanho do indice atual
            movq 8(%rdx), %rcx
            
            # Verifica tamanho do espaço
            cmp %rcx, %rdi
            jg _next_space

                # Coloca flag como ocupada
                movq $1, (%rdx)

                # Calcula quanto espaço esta desocupado e diminui o custo do registro
                subq %rdi, %rcx
                subq $16, %rcx

                # Verifica se espaço que sobra permite um novo registro
                cmp $0, %rcx
                jle _end

                    # Modifica o valor do tamanho do atual
                    movq %rdi, 8(%rdx)
                    
                    # Move indice para o novo registro
                    addq $16 ,%rdx
                    addq %rdi ,%rdx
                    
                    # Monta o novo registro
                    movq $0, (%rdx)
                    movq %rcx, 8(%rdx)
                    
                    # Volta o indice para o registro original
                    subq $16, %rdx
                    subq %rdi, %rdx

                    jmp _end
        
        _next_space:
        # Move o indice para o proximo registro da Heap
        addq $16, %rdx
        addq -8(%rdx), %rdx
    
        jmp _loop

        _end:
        # Retorna a area alocada do indice atual
        addq $16, %rdx
        movq %rdx, %rax
        
        popq %rbp
        ret

    memory_free:
        pushq %rbp
        movq %rsp, %rbp

        # Marca flag como livre
        movq $0, -16(%rdi)
        # Retorna a area alocada do indice atual

        popq %rbp
        ret
