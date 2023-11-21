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


        # Verifica se o espaço alocado é maior que 0
        cmp $0, %rdi
        jg _continue
        
            # Retorna 0
            movq $0, %rax
            popq %rbp
            ret
        
        _continue:


        # Posição inicial da heap
        lea brk_original(%rip), %rcx
        movq (%rcx), %rdx

        # O endereco de worst fit fica em %r10, mas ele não precisa ser iniciado
        # inicia o valor atual do tamanho extra do worst fit em %r9
        movq $-1, %r9

        # Verifica se brk <= indice atual da heap (%rdx)
        _loop:
        cmpq %rdx, 8(%rcx)
        jle _end_loop
            # Verifica se o espaço esta ocupado
            cmpq $0, (%rdx)
            jne _next_space

                # Mapeia tamanho do indice atual
                movq 8(%rdx), %r8

                # Verifica tamanho do espaço
                cmp %r8, %rdi
                jg _next_space

                    # Calcula quanto espaço esta desocupado
                    subq %rdi, %r8

                    # Verifica se espaço desocupado maior que do worst fit atual (%r9)
                    cmp %r8, %r9
                    jg _next_space

                        # tamanho do worst fit = tamanho do indice
                        movq %r8, %r9

                        # endereco worst fit = indice
                        movq %rdx, %r10

            _next_space:
            # Move o indice para o proximo registro da Heap
            addq $16, %rdx
            addq -8(%rdx), %rdx

            jmp _loop

        _end_loop:

        # Verifica se havia um worst fit valido 
        cmp $-1, %r9
        je _no_fit

            # Atualiza flag de worst_atual para 1
            movq $1, (%r10)

            # Calcula quanto espaço esta desocupado e diminui o custo do registro
            subq $16, %r9

            # Preparar para retorno
            movq %r10, %rdx

            # Verifica se espaço que sobra permite um novo registro
            cmp $0, %r9
            jle _end
                # Modifica o valor do tamanho do atual
                movq %rdi, 8(%r10)

                # Move indice para o novo registro
                addq $16 ,%r10
                addq %rdi ,%r10

                # Monta o novo registro
                movq $0, (%r10)
                movq %r9, 8(%r10)

                jmp _end

        _no_fit:
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
       
        _end:
        # Retorna a area alocada do indice atual
        addq $16, %rdx
        movq %rdx, %rax
        
        popq %rbp
        ret

    memory_free:
        pushq %rbp
        movq %rsp, %rbp

        # Diminui 16 do ponteiro passado, que é o valor para cair no registro
        subq $16, %rdi

        # Prepara o retorno caso a flag não seja modificada
        movq  $0, %rax

        # Verifica se a posição está depois ou no brk_original
        lea brk_original(%rip), %rcx
        movq (%rcx), %rdx
        cmpq %rdx, %rdi
        jl _out_of_heap
            # Verifica se o ponteiro passado está antes do brk_atual-17 (Valor minimo para ter uma flag )
            lea brk_current(%rip), %rcx
            movq (%rcx), %rdx
            subq $17, %rdx
            cmpq %rdx, %rdi
            jg _out_of_heap
                # Marca flag como livre
                movq $0, (%rdi)
                movq  $1, %rax

        # Retorna a area alocada do indice atual
        _out_of_heap:
        popq %rbp
        ret
        