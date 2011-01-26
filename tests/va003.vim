" Test on Sample 6, go to second to last 'end' and :norm varard
call vimtest#StartTap()
call vimtap#Plan(3)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
11
normal 0varard
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'v') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,4), ['# Sample 6', '', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()
