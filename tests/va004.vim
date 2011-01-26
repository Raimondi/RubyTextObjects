" Test on Sample 6, go to second start of block and :norm varard
call vimtest#StartTap()
call vimtap#Plan(1)
edit sample_006.rb
runtime ftplugin/ruby/rubytextobjects.vim
3
normal 0varard
call vimtap#Ok(mapcheck('<Plug>RubyTextObjectsAll', 'v') != '', 'Check <Plug> mapping.')
call vimtap#Ok(maparg('ar', 'v') =~# '<Plug>RubyTextObjectsAll', 'Check ar mapping.')
call vimtap#Is(getline(1,4), ['# Sample 6', '', ''], 'Check if the selection was correct.')
call vimtest#SaveOut()
call vimtest#Quit()

