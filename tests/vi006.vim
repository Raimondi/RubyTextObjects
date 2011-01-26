" Test on Sample 6, go to the middle and :norm virird
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
7
normal 0virird
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'v') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', '  class bar', '    catch :quitRequested do', '    def baz', '    end', '    end', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
