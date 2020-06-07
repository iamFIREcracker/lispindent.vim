if exists('g:lispindent_loaded')
  finish
endif
let g:lispindent_loaded = 1

if !exists('g:lispindent_filetypes')
  let g:lispindent_filetypes = 'clojure,scheme,lisp,timl'
endif

if !empty(g:lispindent_filetypes)
  augroup lispindent_filetypes
    autocmd!
    execute 'autocmd FileType ' . g:lispindent_filetypes . ' call lispindent#init()'
  augroup END
endif
