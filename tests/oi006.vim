" Test on Sample 11, go to first line inside block and :norm dir
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_011.rb
runtime ftplugin/ruby/rubytextobjects.vim
3
normal 0dir
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsIn', 'o') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ir', 'o') =~# '<Plug>RubyTextObjectsIn', 'Check ir mapping.')
call vimtap#Is(getline(1,line('$')), ['# Sample 11', 'catch :quitRequested do', 'end', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
