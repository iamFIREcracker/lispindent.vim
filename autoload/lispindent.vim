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
      return
    endif
    let dir = "../" . dir
  endwhile
endfunction "}}}

function! s:parse_lin_rule(string) "{{{
  let parts = split(a:string, '[()]', 1)

  if len(parts) == 5
    "((foo bar baz) 1) => ['', '', 'foo bar baz', ' 1', '']
    let keywords = split(parts[2])
    let lin = str2nr(parts[3])
  else
    let rule = parts[1]
    if rule =~ '\v^\a'
      "(foo 1) => ['', 'foo 1', '']
      let parts = split(rule)
      let keywords = [parts[0]]
      let lin = str2nr(parts[1])
    else
      "(1 foo bar baz) => ['', '1 foo bar baz', '']
      let parts = split(rule)
      let keywords = parts[1:]
      let lin = str2nr(parts[0])
    endif
  endif

  if lin >= 1
    return keywords
  else
    return []
  endif
endfunction "}}}

function! s:parse_lispwords_file(file) "{{{
  let lispwords = []

  if filereadable(a:file)
    let buffer = ""
    let i = 0
    let inside_parens = 0

    for line in readfile(a:file)
      let buffer .= line

      while i < len(buffer)
        let c = buffer[i]

        if c == ';'
          let buffer = i == 0 ? "" : buffer[0:i - 1]
          break
        elseif c == '('
          let inside_parens += 1
        elseif c == ')'
          let inside_parens -= 1
          if !inside_parens
            let lispwords += s:parse_lin_rule(buffer[0:i])
            let buffer = buffer[i + 1:]
            let i = 0
            continue
          endif
        endif

        let i += 1
      endwhile
    endfor
  endif

  return lispwords
endfunction "}}}

function! s:set_lispwords() "{{{
  let file = ""

  if exists($LISPWORDS)
    let file = $LISPWORDS
  else
    let file = s:find_lispwords_file()
  end

  for keyword in s:parse_lispwords_file(file)
    execute "setlocal lispwords+=" . keyword
  endfor
endfunction "}}}

function! lispindent#init() "{{{
  " XXX check `lispindent`, and maybe download it?!
  setlocal lisp
  setlocal equalprg=lispindent
  call s:set_lispwords()
endfunction "}}}
