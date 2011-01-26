" Test on Sample 6, go to second to last 'end' and :norm virird
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
11
normal 0virird
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'v') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', '  class bar', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
