" Test on Sample 6, go to the middle and :norm varard
call vimtest#StartTap()
call vimtap#Plan(1)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
7
normal 0varard
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'v') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,13), ['# Sample 6', 'module Foo', '  class bar', '    catch :quitRequested do', '    ', '    end', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()

