" set verbose=1

let s:suite = themis#suite('parse')
let s:assert = themis#helper('assert')

function! s:suite.parse_options_args() abort
  call s:assert.equals(ddx#commands#_parse_options_args(
        \ '-ui-option-foo=bar'),
        \ {
        \   'uiOptions': { '_': { 'foo': 'bar' } },
        \ })
  call s:assert.equals(ddx#commands#_parse_options_args(
        \ 'foo -ui-param-foo=bar'),
        \ {
        \   'uiParams': { '_': { 'foo': 'bar' } },
        \ })

  " If omit value, v:true is used
  call s:assert.equals(ddx#commands#_parse_options_args(
        \ '-resume'),
        \ {
        \   'resume': v:true,
        \ })
  call s:assert.equals(ddx#commands#_parse_options_args(
        \ '-ui-param-foo'),
        \ {
        \   'uiParams': { '_': { 'foo': v:true } },
        \ })
endfunction
