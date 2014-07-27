if exists('g:loaded_goimpl')
    finish
endif

command! -nargs=+ -complete=customlist,goimpl#complete GoImpl call goimpl#do(<f-args>)

let g:loaded_goimpl = 1
