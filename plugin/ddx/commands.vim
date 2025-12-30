if 'g:loaded_ddx_commands'->exists()
  finish
endif
let g:loaded_ddx_commands = 1

command -nargs=* -range -bar -complete=customlist,ddx#commands#complete
      \ Ddx call ddx#commands#call(<q-args>)
