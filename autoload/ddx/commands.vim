function! ddx#commands#complete(arglead, cmdline, cursorpos) abort
  " Option names completion.
  let options = keys(filter(ddx#custom#get_default_options(),
        \ { _, val -> type(val) == v:t_bool || type(val) == v:t_string }))
  let _ = map(options, { _, val -> '-' . val . '=' }) + [
        \ '-ui-option-', '-ui-param-',
        \ ]

  return uniq(sort(filter(_, { _, val -> stridx(val, a:arglead) == 0 })))
endfunction

function! ddx#commands#call(args) abort
  let options = ddx#commands#_parse_options_args(a:args)
  call ddx#start(options)
endfunction

function! ddx#commands#_parse_options_args(cmdline) abort
  let ui_options = {}
  let ui_params = {}
  let [args, options] = s:parse_options(a:cmdline)

  for arg in args
    if arg =~# '^-\w\+-\%(option\|param\)-\w\+'
      " options/params
      let a = substitute(arg, '^-\w\+-\w\+-', '', '')
      let name = substitute(a, '=.*$', '', '')
      let value = (a =~# '=.*$') ?
          \ s:remove_quote_pairs(a[len(name) + 1 :]) : v:true
      if value ==# 'v:true' || value ==# 'v:false'
        " Use boolean instead
        let value = value ==# 'v:true' ? v:true : v:false
      endif

      let dest = matchstr(arg, '^-\zs\w\+\ze-')
      let option_or_param = matchstr(arg, '^-\w\+-\zs\%(option\|param\)')

      if dest ==# 'ui'
        let ui_{option_or_param}s[name] = value
      endif
    elseif arg[0] ==# '-'
      call s:print_error(printf('option "%s": is invalid.', arg))
    endif
  endfor

  if !empty(ui_options)
    let options.uiOptions = { '_': ui_options }
  endif
  if !empty(ui_params)
    let options.uiParams = { '_': ui_params }

    if has_key(options, 'ui')
      let options.uiParams[options.ui] = ui_params
    endif
  endif

  return options
endfunction
function! s:re_unquoted_match(match) abort
  " Don't match a:match if it is located in-between unescaped single or double
  " quotes
  return a:match . '\v\ze([^"' . "'" . '\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"|'
        \ . "'" . '([^' . "'" . '\\]*\\.)*[^' . "'" . '\\]*' . "'" . '))*[^"'
        \ . "'" . ']*$'
endfunction
function! s:remove_quote_pairs(s) abort
  " remove leading/ending quote pairs
  let s = a:s
  if s[0] ==# '"' && s[len(s) - 1] ==# '"'
    let s = s[1: len(s) - 2]
  elseif s[0] ==# "'" && s[len(s) - 1] ==# "'"
    let s = s[1: len(s) - 2]
  else
    let s = substitute(a:s, '\\\(.\)', "\\1", 'g')
  endif
  return s
endfunction
function! s:parse_options(cmdline) abort
  let args = []
  let options = {}

  " Eval
  let cmdline = (a:cmdline =~# '\\\@<!`.*\\\@<!`') ?
        \ s:eval_cmdline(a:cmdline) : a:cmdline

  for s in split(cmdline, s:re_unquoted_match('\%(\\\@<!\s\)\+'))
    let arg = substitute(s, '\\\( \)', '\1', 'g')
    let arg_key = substitute(arg, '=\zs.*$', '', '')

    let name = substitute(tr(arg_key, '-', '_'), '=$', '', '')[1:]
    let value = (arg_key =~# '=$') ?
          \ s:remove_quote_pairs(arg[len(arg_key) :]) : v:true
    if value ==# 'v:true' || value ==# 'v:false'
      " Use boolean instead
      let value = value ==# 'v:true' ? v:true : v:false
    endif

    if arg_key[0] ==# '-' && arg_key !~# '-option-\|-param-'
      let options[name] = value
    else
      call add(args, arg)
    endif
  endfor

  return [args, options]
endfunction
function! s:eval_cmdline(cmdline) abort
  let cmdline = ''
  let prev_match = 0
  let eval_pos = match(a:cmdline, '\\\@<!`.\{-}\\\@<!`')
  while eval_pos >= 0
    if eval_pos - prev_match > 0
      let cmdline .= a:cmdline[prev_match : eval_pos - 1]
    endif
    let prev_match = matchend(a:cmdline,
          \ '\\\@<!`.\{-}\\\@<!`', eval_pos)
    silent! let cmdline .= escape(
          \ eval(a:cmdline[eval_pos+1 : prev_match - 2]), '\ ')

    let eval_pos = match(a:cmdline, '\\\@<!`.\{-}\\\@<!`', prev_match)
  endwhile
  if prev_match >= 0
    let cmdline .= a:cmdline[prev_match :]
  endif

  return cmdline
endfunction

function! s:print_error(string, ...) abort
  let name = a:0 ? a:1 : 'ddx'
  echohl Error
  echomsg printf('[%s] %s', name,
        \ type(a:string) ==# v:t_string ? a:string : string(a:string))
  echohl None
endfunction
