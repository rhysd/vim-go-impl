let s:save_cpo = &cpo
set cpo&vim

let g:goimpl#gocmd = get(g:, 'goimpl#gocmd', 'go')
let g:goimpl#cmd = get(g:, 'goimpl#cmd', 'impl')

function! s:chomp(str)
    return a:str[len(a:str)-1] ==# "\n" ? a:str[:len(a:str)-2] : a:str
endfunction

function! s:os_arch()
    let os = s:chomp(system(g:goimpl#gocmd . ' env GOOS'))
    if v:shell_error
        return ''
    endif

    let arch = s:chomp(system(g:goimpl#gocmd . ' env GOARCH'))
    if v:shell_error
        return ''
    endif

    return os . '_' . arch
endfunction

let g:goimpl#os_arch = get(g:, 'goimpl#os_arch', s:os_arch())

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

function! s:shell_error()
    return s:has_vimproc() ? vimproc#get_last_status() : v:shell_error
endfunction

function! goimpl#impl(recv, iface)
    if !executable(g:goimpl#cmd)
        call s:error(g:goimpl#cmd . ' command is not found. Please check g:goimpl#cmd')
        return ''
    endif

    let result = s:system(join([g:goimpl#cmd, string(a:recv), string(a:iface)], " "))

    if s:shell_error()
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

if exists('*uniq')
    function! s:uniq(list)
        return uniq(a:list)
    endfunction
else
    " Note: Believe that the list is sorted
    function! s:uniq(list)
        let i = len(a:list) - 1
        while 0 < i
            if a:list[i-1] ==# a:list[i]
                call remove(a:list, i)
                let i -= 2
            else
                let i -= 1
            endif
        endwhile
        return a:list
    endfunction
endif

function! s:root_dirs()
    let dirs = []

    let root = substitute(s:chomp(system(g:goimpl#gocmd . ' env GOROOT')), '\\', '/', 'g')
    if v:shell_error
        return []
    endif

    if root !=# '' && isdirectory(root)
        call add(dirs, root)
    endif

    let path_sep = has('win32') || has('win64') ? ';' : ':'
    let paths = map(split(s:chomp(system(g:goimpl#gocmd . ' env GOPATH')), path_sep), "substitute(v:val, '\\', '/', 'g')")
    if v:shell_error
        return []
    endif

    if !empty(filter(paths, 'isdirectory(v:val)'))
        call extend(dirs, paths)
    endif

    return dirs
endfunction

function! s:go_packages(dirs)
    let pkgs = []
    for d in a:dirs
        let pkg_root = expand(d . '/pkg/' . s:os_arch())
        call extend(pkgs, split(globpath(pkg_root, '**/*.a', 1), "\n"))
    endfor
    return map(pkgs, "fnamemodify(v:val, ':t:r')")
endfunction

function! s:interface_list(pkg)
    let contents = split(s:system('godoc ' . a:pkg), "\n")
    if s:shell_error()
        return []
    endif

    call filter(contents, 'v:val =~# ''^type\s\+\h\w*\s\+interface''')
    return map(contents, 'a:pkg . "." . matchstr(v:val, ''^type\s\+\zs\h\w*\ze\s\+interface'')')
endfunction

" Complete after '.' as interface
function! goimpl#complete(arglead, cmdline, cursorpos)
    if !executable('godoc')
        return []
    endif

    let words = split(a:cmdline, '\s\+', 1)
    if len(words) <= 3
        " TODO
        return []
    endif

    if a:cmdline =~# '\s\+$'
        return s:uniq(sort(s:go_packages(s:root_dirs())))
    elseif words[-1] =~# '^\h\w*$'
        return s:uniq(sort(filter(s:go_packages(s:root_dirs()), 'stridx(v:val, words[-1]) == 0')))
    elseif words[-1] =~# '^\h\w*\.\%(\h\w*\)\=$'
        let [pkg, interface] = split(words[-1], '\.', 1)
        echomsg pkg
        return s:uniq(sort(filter(s:interface_list(pkg), 'stridx(v:val, words[-1]) == 0')))
    else
        return []
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

