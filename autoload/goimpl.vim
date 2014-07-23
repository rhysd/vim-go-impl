let s:save_cpo = &cpo
set cpo&vim

let g:goimpl#cmd = get(g:, 'goimpl#cmd', 'impl')

function! s:error(msg)
    echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function! s:has_vimproc()
    if !exists('s:exists_vimproc')
        try
            silent call vimproc#version()
            let s:exists_vimproc = 1
        catch
            let s:exists_vimproc = 0
        endtry
    endif
    return s:exists_vimproc
endfunction

function! s:system(str, ...)
    let command = a:str
    let input = a:0 >= 1 ? a:1 : ''

    if a:0 == 0
        let output = s:has_vimproc() ?
                    \ vimproc#system(command) : system(command)
    elseif a:0 == 1
        let output = s:has_vimproc() ?
                    \ vimproc#system(command, input) : system(command, input)
    else
        " ignores 3rd argument unless you have vimproc.
        let output = s:has_vimproc() ?
                    \ vimproc#system(command, input, a:2) : system(command, input)
    endif

    return output
endfunction

function! goimpl#impl(recv, iface)
    if !executable(g:goimpl#cmd)
        call s:error(g:goimpl#cmd . ' command is not found. Please check g:goimpl#cmd')
        return ''
    endif

    let result = s:system(join([g:goimpl#cmd, string(a:recv), string(a:iface)], " "))

    if s:has_vimproc() ? vimproc#get_last_status() : v:shell_error
         call s:error(g:goimpl#cmd . ' command failed: ' . result)
         return ''
    endif

    return result
endfunction

function! goimpl#do(...)
    if a:0 < 2
        call s:error('GoImpl {receiver} {interface}')
        return
    endif

    let recv = join(a:000[:-2], ' ')
    let iface = a:000[-1]

    put =goimpl#impl(recv, iface)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

