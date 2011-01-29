" Test on Sample 6, go to last end and norm dir
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
12
normal ^dir
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'o') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
