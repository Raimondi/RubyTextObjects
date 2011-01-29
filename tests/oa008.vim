
" Test on Sample 6, go to second to last 'end' and :norm vGard
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
11
normal vGard
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'v') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', '  ', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
