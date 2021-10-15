if exists('g:lispindent_autoloaded')
  finish
endif
let g:lispindent_autoloaded = 1

function! s:find_lispwords_file() "{{{
  let home = fnamemodify($HOME, ':p')
  let dir = ""

  while 1
    let file = dir . ".lispwords"
    if filereadable(file)
      return file
    endif
    if fnamemodify(dir, ':p') == home
      return ""
    endif
    let dir = "../" . dir
  endwhile
endfunction "}}}

function! lispindent#calc_indent_lvl(lnum) abort " {{{
    " Get the content of the current buffer
    "
    " Note: `lispindent` would not try to indent _empty_ lines (i.e. lines
    " containing whitespace only), so if the current line happens to be
    " _empty_, we replace it with something else (i.e. something that hopefully
    " would not break the syntax)
    let l:buff_lines = getline(1, '$')
    if l:buff_lines[a:lnum - 1] !~ '\v\S'
      let l:buff_lines[a:lnum - 1] = 'lispindent-was-here'
    endif
    let l:buff = join(l:buff_lines, "\n")

    " Send the current buffer to `lispindent` and extract the line
    " which we are trying to calculate the indentation level for
    let l:indented_line = systemlist(&equalprg, buff)[a:lnum - 1]

    " Return the position of the first non-whitespace character
    let l:level = 0
    while l:indented_line[l:level] == ' '
      let l:level += 1
    endwhile
    return l:level
endfunction " }}}

function! lispindent#init() "{{{
  if !executable('lispindent')
    " XXX check `lispindent`, and maybe download it?!
    echoerr "lispindent was not found: aborting..."
  elseif s:find_lispwords_file() == ""
    echom ".lispwords file was not found: skipping initialization..."
  else
    " Stop vim lisp mode from getting in the way (especially since
    " we are going to override both &equalprg and &indentexpr)
    setlocal nolisp
    setlocal equalprg=lispindent
    setlocal indentexpr=lispindent#calc_indent_lvl(v:lnum)
  endif
endfunction "}}}
