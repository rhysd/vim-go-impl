command! -nargs=+ -buffer -complete=customlist,goimpl#complete GoImpl call goimpl#do(<f-args>)
command! -nargs=+ -buffer -complete=customlist,goimpl#complete Impl GoImpl <args>
