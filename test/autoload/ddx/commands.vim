" Test for ddx#commands module
" set verbose=1

function Test_parse_options_args() abort
  call assert_equal(
        \ #{
        \   uiOptions: #{ _: #{ foo: 'bar' } },
        \ },
        \ ddx#commands#_parse_options_args('-ui-option-foo=bar'))
  call assert_equal(
        \ #{
        \   uiParams: #{ _: #{ foo: 'bar' } },
        \ },
        \ ddx#commands#_parse_options_args('foo -ui-param-foo=bar'))

  " If omit value, v:true is used
  call assert_equal(
        \ #{
        \   resume: v:true,
        \ },
        \ ddx#commands#_parse_options_args('-resume'))
  call assert_equal(
        \ #{
        \   uiParams: #{ _: #{ foo: v:true } },
        \ },
        \ ddx#commands#_parse_options_args('-ui-param-foo'))
endfunction
