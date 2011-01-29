" Test on Sample 6, go to first line outside block and :norm dir
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
$
normal 0dir
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'o') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 6', 'module Foo', '  class bar', '    catch :quitRequested do', '    def baz', '      [1,2,3].each do |i|', '        i + 1', '      end', '    end', '    end', '  end', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
