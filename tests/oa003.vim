" Test on Sample 6, go to the middle and :norm dar
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
7
normal 0dar
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'o') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,13), ['# Sample 6', 'module Foo', '  class bar', '    catch :quitRequested do', '    def baz', '      [1,2,3].each ', '    end', '    end', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
