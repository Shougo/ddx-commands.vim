" Test for ddx#commands module
" set verbose=1

function Test_parse_options_args() abort
  call assert_equal(
        \ ddx#commands#_parse_options_args('-ui-option-foo=bar'),
        \ #{
        \   uiOptions: #{ _: #{ foo: 'bar' } },
        \ })
  call assert_equal(
        \ ddx#commands#_parse_options_args('foo -ui-param-foo=bar'),
        \ #{
        \   uiParams: #{ _: #{ foo: 'bar' } },
        \ })

  " If omit value, v:true is used
  call assert_equal(
        \ ddx#commands#_parse_options_args('-resume'),
        \ #{
        \   resume: v:true,
        \ })
  call assert_equal(
        \ ddx#commands#_parse_options_args('-ui-param-foo'),
        \ #{
        \   uiParams: #{ _: #{ foo: v:true } },
        \ })
endfunction
