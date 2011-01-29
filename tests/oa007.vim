" Test on Sample 5, go to first line inside nested block and :norm dar, needs
" syntax on to ignore keywords inside strings and comments
call vimtest#StartTap()
call vimtap#Plan(3)
syntax on
edit sample_005.rb
runtime ftplugin/ruby/rubytextobjects.vim
6
normal ^dar
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'o') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 5', 'class Foo', '  # [cursor]', '  # vir/var should select Foo class', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
